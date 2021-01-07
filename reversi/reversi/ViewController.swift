//
//  ViewController.swift
//  reversi
//
//  Created by Yoshiki Izumi on 2020/11/23.
//
//

import UIKit

class ViewController: UIViewController {

    var turn: Int = 0
    let _board = Board()
    let strategy = MinmaxReversi()
    @IBOutlet weak var board: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var maintenanceSwitch: UISwitch!
    @IBOutlet weak var autoSwitch: UISwitch!
    
    var maintenanceMode: Bool {
        maintenanceSwitch.isOn
    }
    
    var autoMode: Bool {
        autoSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearScreen()
        renderState()
    }
    
    func renderState() {
        var count = 0
        for stack in board.subviews {
            for button in stack.subviews {
                let b = button as! UIButton
                b.tag = count
                b.titleLabel?.font = UIFont.systemFont(ofSize: 48)
                b.backgroundColor = UIColor.init(cgColor: CGColor(red: 0.0, green: 0.3, blue: 0.0, alpha: 1.0))
                let state = _board.getState(b.tag)
                switch state {
                case .pointBlack:
                    b.setTitleColor(.black, for: .normal)
                    b.setTitle("●", for: .normal)
                case .pointWhite:
                    b.setTitleColor(.white, for: .normal)
                    b.setTitle("●", for: .normal)
                case .pointNone:
                    b.setTitle("", for: .normal)
                    break
                }
                count += 1
                b.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
            }
        }
    }
    
    func clearScreen() {
        messageLabel.text = ""
    }
    
    @objc func tapButton(_ sender: UIButton) {
        func putToBoardIfNotMaintenanceMode() {
            switch _board.getState(sender.tag) {
            case .pointNone:
                if _board.canPut(.pointBlack, sender.tag) {
                    _board.putWithReverse(sender.tag, .pointBlack)
                }
                renderState()
            case .pointBlack, .pointWhite:
                break
            }
            turn += 1
        }
        func putToBoardIfMaintenanceMode() {
            switch _board.getState(sender.tag) {
            case .pointNone:
                _board.putWithoutReverse(sender.tag, .pointBlack)
            case .pointBlack:
                _board.putWithoutReverse(sender.tag, .pointWhite)
            case .pointWhite:
                _board.putWithoutReverse(sender.tag, .pointNone)
                break
            }
            renderState()
        }
        func putToBoard() {
            if maintenanceMode {
                putToBoardIfMaintenanceMode()
            } else {
                putToBoardIfNotMaintenanceMode()
            }
        }
        clearScreen()
        putToBoard()
        if autoMode {
            putByAI()
        }
        print("@@@" + sender.tag.description)
    }
    
    @IBAction func tappedAIPut(_ sender: Any) {
        clearScreen()
        putByAI()
    }
    func putByAI() {
        strategy.predict(_board._state, .pointWhite) {
            (predict) in
            assert(predict.count == 64, "wrong range.")
            let results = BetaReversi.ReversiPredictionDecoder.decode(predict, _board._state, .pointWhite)
            if results.isEmpty {
                messageLabel.text = "Pass"
                return
            }
            var nextMove = results[0]
            print(nextMove)
            _board.putWithReverse(nextMove, .pointWhite)
            renderState()
            for stack in board.subviews {
                for button in stack.subviews {
                    if nextMove == 0 {
                        let b = button as! UIButton
                        b.setTitle("●", for: .normal)
                        b.setTitleColor(.white, for: .normal)
                        return
                    }
                    nextMove -= 1
                }
            }
        }
    }
}

