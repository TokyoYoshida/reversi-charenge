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
    let strategy = BlockingBetaReversi()
    let aiStrategy = BetaReversi()
    let _players: [GKGameModelPlayer] = [
        Player(playerId: 1),
        Player(playerId: 2)
    ]
    var board: [State] = []
    var currentPlayer = 0
    
    func printState() {
        guard board.count == 64 else {return}
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
        printState()
        return 2
    }

    var players: [GKGameModelPlayer]? {
        return _players
    }
    
    var activePlayer: GKGameModelPlayer? {
        return _players[currentPlayer]
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let model = gameModel as? ReversiModel{
            updateState(model.board)
        }
    }
    
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let ar = [1,2,3]
        let upd = ar.map { Update($0) }
        return upd
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        let value: State = currentPlayer == 0 ? .pointBlack : .pointWhite
        let current = currentPlayer == 0 ? "black" : "white"
        print("current player: \(current)")
        print("update value = \(gameModelUpdate.value)")
        board[gameModelUpdate.value] = value
        currentPlayer = 1 - currentPlayer
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ReversiModel()
        copy.setGameModel(self)
        return copy
    }
}
    
struct MinmaxReversi: ReversiStrategy {
    let strategist = GKMinmaxStrategist()
    let gameModel = ReversiModel()
    init() {
        strategist.gameModel = gameModel
        strategist.maxLookAheadDepth = 3
    }
    func predict(_ board: [State], completion: ([Float32]) -> Void) {
        gameModel.updateState(board)
        var resBoard = Array(repeating: Float32(0), count: 64*2)
        if let result = strategist.bestMoveForActivePlayer() {
            print(result)
            resBoard[result.value] = 1
        }
        completion(resBoard)
    }
}
