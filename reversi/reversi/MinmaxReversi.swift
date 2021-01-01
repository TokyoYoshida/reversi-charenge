//
//  ReversiStrategy.swift
//  reversi
//
//  Created by TokyoYoshida on 2020/12/11.
//

import Foundation
import GameKit

class Player: NSObject, GKGameModelPlayer {
    let playerId: Int
    init(playerId: Int) {
        self.playerId = playerId
    }
}

class Update: NSObject, GKGameModelUpdate {
    var value: Int
    init(_ value: Int) {
        self.value = value
    }
}

class ReversiModel: NSObject, GKGameModel {
    let aiStrategy = BetaReversi()
    let _players: [GKGameModelPlayer] = [
        Player(playerId: 1),
        Player(playerId: 2)
    ]
    var board: [State] = []
    var currentPlayer = 0
    
    func printState() {
        guard board.count == 64 else {return}
        let current = currentPlayer == 0 ? "black" : "white"
        print("current player: \(current)")
        for row in 0..<8 {
            var str = ""
            for col in 0..<8 {
                switch board[row*8 + col] {
                case .pointBlack:
                   str += "●"
                case .pointWhite:
                    str += "○"
                case .pointNone:
                    str += " "
                }
            }
            print(str)
        }
        print("----")
    }

    func updateState(_ board: [State]) {
        self.board = board
    }

    func score(for player: GKGameModelPlayer) -> Int {
        return 2
    }

    var players: [GKGameModelPlayer]? {
        return _players
    }
    
    var activePlayer: GKGameModelPlayer? {
        return _players[currentPlayer]
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let ar = Array(1..<3)
        let upd = ar.map { Update($0) }
        return upd
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        let value: State = currentPlayer == 0 ? .pointBlack : .pointWhite
        print("update value = \(gameModelUpdate.value)")
        board[gameModelUpdate.value] = value
        printState()
        currentPlayer = 1 - currentPlayer
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
//        let copy = ReversiModel()
//        copy.updateState(board)
//        return copy
    }
}
    
struct MinmaxReversi: ReversiStrategy {
    let strategist = GKMinmaxStrategist()
    let gameModel = ReversiModel()
    init() {
        strategist.gameModel = gameModel
        strategist.maxLookAheadDepth = 3
    }
    func predict(_ board: [State], completion: (Int?) -> Void) {
        gameModel.updateState(board)
        let result = strategist.bestMoveForActivePlayer()
        print(result)
        completion(result?.value)
    }
}
