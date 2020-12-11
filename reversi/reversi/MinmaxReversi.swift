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

    func score(for player: GKGameModelPlayer) -> Int {
        return 1
    }

    var players: [GKGameModelPlayer]? {
        return _players
    }
    
    var activePlayer: GKGameModelPlayer? {
        return _players.last
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        let ar = Array(repeating: Int(1), count: 64)
        let upd = ar.map { Update($0) }
        return upd
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}

struct MinmaxReversi: ReversiStrategy {
    let strategist = GKMinmaxStrategist()
    init() {
        strategist.gameModel = ReversiModel()
        strategist.maxLookAheadDepth = 3
    }
    func predict(_ board: [State], completion: (Int?) -> Void) {
        let result = strategist.bestMoveForActivePlayer()
        print(result)
        completion(result?.value)
    }
}
