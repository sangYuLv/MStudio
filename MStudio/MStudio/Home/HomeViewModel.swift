//
//  HomeViewModel.swift
//  MStudio
//
//  Created by 이상유 on 2026-02-19.
//

import Combine
import Foundation

final class HomeViewModel {

    @Published var warningNote: String = ""
    @Published var enablePlayButton: Bool = false
    var validURL: URL?

    private var urlState: ValidationState = .none {
        didSet {
            enablePlayButton = urlState == .valid
        }
    }
    private var enteredURL: String?

    private var validationTask: Task<Void, Never>?

    func updateURL(_ str: String?) {
        enteredURL = str
        urlState = .validating
        validationTask?.cancel()
        validationTask = Task { [weak self] in
            guard let self else { return }

            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }

            let currentURL = self.enteredURL
            let result = await self.validateURL(str)

            guard currentURL == self.enteredURL else { return }
            self.urlState = result
        }
    }

    private func validateURL(_ str: String?) async -> ValidationState {
        guard let str,
              !str.isEmpty
        else {
            warningNote = ""
            return .none
        }

        do {
            validURL = try await URLValidator.isValidVideoURL(str)
            warningNote = ""
        } catch let error as VideoURLValidationError {
            warningNote = error.message
            validURL = nil
        } catch {
            warningNote = "알 수 없는 오류가 발생했습니다."
            validURL = nil
        }

        return validURL == nil ? .invalid : .valid
    }

}
