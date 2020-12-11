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
    let strategy = MinmaxReversi()
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
            sender.setTitle("●", for: .normal)
        case .pointBlack:
            sender.setTitleColor(.white, for: .normal)
            state[sender.tag] = .pointWhite
            sender.setTitle("●", for: .normal)
        case .pointWhite:
            state[sender.tag] = .pointNone
            sender.setTitle("", for: .normal)
        }
        turn += 1
    }
    
    @IBAction func tappedAIPut(_ sender: Any) {
        putByAI()
    }
    func putByAI() {
        strategy.predict(state) {
            (result) in
            if result == nil {
                print("pass")
                return
            }
            var nextMove = result!
            print(nextMove)
            state[nextMove] = .pointWhite
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

