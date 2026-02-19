//
//  HomeViewModel.swift
//  MStudio
//
//  Created by 이상유 on 2026-02-19.
//

import Combine
import Foundation

final class HomeViewModel {

    @Published var showInvalidNote: Bool = false
    @Published var enablePlayButton: Bool = false
    var validURL: URL?

    private var urlState: ValidationState = .none {
        didSet {
            handleValidationResult()
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
        else { return .none }
        validURL = await URLValidator.isValidVideoURL(str)
        return validURL == nil ? .invalid : .valid
    }

    private func handleValidationResult() {
        showInvalidNote = urlState == .invalid
        enablePlayButton = urlState == .valid
    }

}
