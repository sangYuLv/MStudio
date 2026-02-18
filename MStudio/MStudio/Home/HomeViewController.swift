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
        setBinding()

    @IBAction func tappedPasteButton() {
        // TODO: 붙여넣기 기능
    }
    
    @IBAction func tappedPlayButton() {
        // TODO: 영상 재생 화면으로 전환
    }

    // MARK: - Set up
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
    }

}

