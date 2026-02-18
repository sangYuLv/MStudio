//
//  HomeViewModel.swift
//  MStudio
//
//  Created by 이상유 on 2026-02-19.
//

import Combine

final class HomeViewModel {

    @Published var showInvalidNote: Bool = false
    @Published var enablePlayButton: Bool = false
    @Published var enableClearButton: Bool = false

    private var urlState: ValidationState = .none {
        didSet {
            handleValidationResult()
        }
    }
    private var enteredURL: String = ""

    private var validationTask: Task<Void, Never>?

    func updateURL(_ str: String) {
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

    private func validateURL(_ str: String) async -> ValidationState {
        guard !str.isEmpty else { return .none }
        // TODO: url 검사
        return .invalid
    }

    private func handleValidationResult() {
        showInvalidNote = urlState == .invalid
        enablePlayButton = urlState == .valid
        enableClearButton = urlState != .none
    }

}
