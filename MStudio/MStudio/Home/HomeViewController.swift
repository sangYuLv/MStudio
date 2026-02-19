//
//  HomeViewController.swift
//  MStudio
//
//  Created by 이상유 on 2026-02-19.
//

import Combine
import UIKit

final class HomeViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var invalidNote: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!

    private var viewModel: HomeViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.urlTextField.delegate = self
        setBinding()
        setGesture()
        setTextField()
    }

    @IBAction func tappedPasteButton() {
        urlTextField.insertText(UIPasteboard.general.string ?? "")
    }
    
    @IBAction func tappedPlayButton() {
        // TODO: 영상 재생 화면으로 전환
    }

    // MARK: - Set up
    private func setTextField() {
        urlTextField.autocorrectionType = .no
        urlTextField.spellCheckingType = .no
        urlTextField.autocapitalizationType = .none
        urlTextField.clearButtonMode = .always
        urlTextField.returnKeyType = .done
        urlTextField.keyboardType = .URL
        urlTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    private func setBinding() {
        viewModel.$showInvalidNote
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.invalidNote.isHidden = !state
            }
            .store(in: &cancellables)

        viewModel.$enablePlayButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.playButton.isEnabled = state
            }
            .store(in: &cancellables)
    }

    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(view.endEditing(_:)))
        view.addGestureRecognizer(tapGesture)
    }

}

// MARK: - Text Field
extension HomeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        urlTextField.becomeFirstResponder()
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.updateURL(nil)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.updateURL(textField.text)
    }
}
