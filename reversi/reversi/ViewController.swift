//
//  ViewController.swift
//  reversi
//
//  Created by Yoshiki Izumi on 2020/11/23.
//

import UIKit
enum State {
    case pointNone
    case pointBlack
    case pointWhite
}

class ViewController: UIViewController {

    var turn: Int = 0
    var state: [State] = []
    @IBOutlet weak var board: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var count = 0
        for stack in board.subviews {
            for button in stack.subviews {
                state.append(.pointNone)
                let b = button as! UIButton
                b.tag = count
                count += 1
                b.setTitle("", for: .normal)
                b.titleLabel?.font = UIFont.systemFont(ofSize: 48)
                b.backgroundColor = UIColor.init(cgColor: CGColor(red: 0.0, green: 0.3, blue: 0.0, alpha: 1.0))
                b.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
            }
        }
    }
    
    @objc func tapButton(_ sender: UIButton) {
        print("@@@" + sender.tag.description)
        switch state[sender.tag] {
        case .pointNone:
            sender.setTitleColor(.black, for: .normal)
            state[sender.tag] = .pointBlack
        case .pointBlack:
            sender.setTitleColor(.white, for: .normal)
            state[sender.tag] = .pointWhite
        case .pointWhite:
            sender.setTitleColor(.black, for: .normal)
            state[sender.tag] = .pointBlack
        }
        turn += 1
        sender.setTitle("●", for: .normal)
        putByAI()
    }
    
    func putByAI() {
        BetaReversi.predict(state) {
            (predict) in
            var nextMove = BetaReversi.ReversiPredictionDecoder.descode(predict)
            print(nextMove)
            for stack in board.subviews {
                for button in stack.subviews {
                    if nextMove == 0 {
                        let b = button as! UIButton
                        state[nextMove] = .pointWhite
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

