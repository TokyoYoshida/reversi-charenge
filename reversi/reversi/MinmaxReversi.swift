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
    var position: Int
    init(_ position: Int, _ value: Int) {
        self.position = position
        self.value = value
    }
}

var globalId = 0
class ReversiModel: NSObject, GKGameModel {
    let strategy = BlockingBetaReversi()
    let aiStrategy = BetaReversi()
    let _players: [Player] = [
        Player(playerId: 1),
        Player(playerId: 2)
    ]
    var board = Board()
    let targetPlayerIndex = 0
    lazy var currentPlayerIndex = targetPlayerIndex // current player in the minmax tree
    var targetPlayer: State = .pointNone // target player to predict
    var id = 0
    
    func convertPlayerToState(_ player: Player) -> State {
        if player.playerId == _players[targetPlayerIndex].playerId {
            return targetPlayer
        } else {
            return targetPlayer.opponent
        }
    }
    
    func printState() {
        board.printState()
    }

    func updateState(_ state: [State], _ targetPlayer: State) {
        self.board._state = state
        self.targetPlayer = targetPlayer
    }

    func score(for player: GKGameModelPlayer) -> Int {
        func getValue(_ player: State) -> Float32 {
            let predict = strategy.predict(board._state, player)
            assert(predict.count == 64, "wrong range.")
            let eval = BetaReversi.ReversiPredictionDecoder.eval(predict, board._state, player)
            return eval
        }
        let player = convertPlayerToState(player as! Player)
        let playerValue = getValue(player)
        let opponentValue = getValue(player.opponent)
        let rawScore = playerValue - opponentValue
        print("\(player.description) Score = \(Int(floor(rawScore*1000000000)))")
        let score = Int(floor(rawScore*1000000000))
        return score
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let player = convertPlayerToState(player as! Player)
        let isWin = board.isWin(player)
        print("\(player.description) isWin = \(isWin)")
        return isWin
    }

    var players: [GKGameModelPlayer]? {
        return _players
    }
    
    var activePlayer: GKGameModelPlayer? {
        return _players[currentPlayerIndex]
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let model = gameModel as? ReversiModel{
            updateState(model.board._state, model.targetPlayer)
            self.currentPlayerIndex = model.currentPlayerIndex
        }
    }
        
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let player = convertPlayerToState(player as! Player)
        let predict = strategy.predict(board._state, player)
        assert(predict.count == 64, "wrong range.")
        let moves = BetaReversi.ReversiPredictionDecoder.decode(predict, board._state, player)
        let upd = moves.map { Update($0, 0) }
        return upd
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        func getCurrentPlayer() -> State {
            currentPlayerIndex == targetPlayerIndex ? targetPlayer : targetPlayer.opponent
        }
        func switchCurrentPlayer() {
            currentPlayerIndex = 1 - currentPlayerIndex
        }
        guard let update = gameModelUpdate as? Update else {return}
        let currentPlayer = getCurrentPlayer()
        print("apply -----")
        print("current player: \(currentPlayer.description)")
        print("update value = \(update.position)")
        board.putWithReverse(update.position, currentPlayer)
        printState()
        switchCurrentPlayer()
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
//    let strategist = GKMinmaxStrategist()
    let strategist = GKMonteCarloStrategist()
    let gameModel = ReversiModel()
    init() {
        strategist.gameModel = gameModel
        strategist.explorationParameter = 1
//        strategist.maxLookAheadDepth = 2
    }
    func predict(_ board: [State],  _ targetPlayer: State, completion: ([Float32]) -> Void) {
        gameModel.updateState(board, targetPlayer)
        var resBoard = Array(repeating: Float32(0), count: 64)
        if let result = strategist.bestMoveForActivePlayer() as? Update {
            print(result)
            resBoard[result.position] = 1
        }
        completion(resBoard)
    }
}
