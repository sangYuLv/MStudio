//
//  HomeViewController.swift
//  MStudio
//
//  Created by 이상유 on 2026-02-19.
//

import UIKit

final class HomeViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var invalidNote: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pasteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    @IBAction func tappedPasteButton() {
        // TODO: 붙여넣기 기능
    }
    
    @IBAction func tappedPlayButton() {
        // TODO: 영상 재생 화면으로 전환
    }
    }

}

