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

var globalId = 0
class ReversiModel: NSObject, GKGameModel {
    let strategy = BlockingBetaReversi()
    let aiStrategy = BetaReversi()
    let _players: [GKGameModelPlayer] = [
        Player(playerId: 1),
        Player(playerId: 2)
    ]
    var board: [State] = []
    var currentPlayer = 0
    var targetPlayer: State = .pointNone
    var id = 0
    
    func printState() {
        guard board.count == 64 else {return}
        print("id = \(id)")
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

    func updateState(_ board: [State], _ targetPlayer: State) {
        self.board = board
        self.targetPlayer = targetPlayer
    }

    func score(for player: GKGameModelPlayer) -> Int {
        let player = currentPlayer == 0 ? targetPlayer : targetPlayer.opponent
        let predict = strategy.predict(board, player)
        assert(predict.count == 64, "wrong range.")
        let eval = BetaReversi.ReversiPredictionDecoder.eval(predict, board, targetPlayer)
        print("Score = \(Int(floor(eval*100)))")
        let res = Int(floor(eval*100))
        return 0..<64 ~= res ? res : 0
    }

    var players: [GKGameModelPlayer]? {
        return _players
    }
    
    var activePlayer: GKGameModelPlayer? {
        return _players[currentPlayer]
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let model = gameModel as? ReversiModel{
            updateState(model.board, model.targetPlayer)
            self.currentPlayer = model.currentPlayer
        }
    }
        
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let player = currentPlayer == 0 ? targetPlayer : targetPlayer.opponent
        let predict = strategy.predict(board, player)
        assert(predict.count == 64, "wrong range.")
        let moves = BetaReversi.ReversiPredictionDecoder.decode(predict, board, targetPlayer)
        let upd = moves.map { Update($0) }
        return upd
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        let value: State = currentPlayer == 0 ? targetPlayer : targetPlayer.opponent
        print("current player: \(value.description)")
        print("update value = \(gameModelUpdate.value)")
        board[gameModelUpdate.value] = value
        printState()
        currentPlayer = 1 - currentPlayer
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        print("copy from id = \(id)")
        let copy = ReversiModel()
        copy.setGameModel(self)
        globalId += 1
        copy.id = globalId
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
    func predict(_ board: [State],  _ targetPlayer: State, completion: ([Float32]) -> Void) {
        gameModel.updateState(board, targetPlayer)
        var resBoard = Array(repeating: Float32(0), count: 64)
        if let result = strategist.bestMoveForActivePlayer() {
            print(result)
            resBoard[result.value] = 1
        }
        completion(resBoard)
    }
}
