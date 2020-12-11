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
    
    func updateState(_ board: [State]) {
        self.board = board
    }

    func score(for player: GKGameModelPlayer) -> Int {
        return 1
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
        currentPlayer = 1 - currentPlayer
        let ar = Array(0..<64)
        let upd = ar.map { Update($0) }
        return upd
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        board[gameModelUpdate.value] = .pointBlack
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
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
