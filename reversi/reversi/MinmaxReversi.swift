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
    var value = 10
}

class ReversiModel: NSObject, GKGameModel {
    var players: [GKGameModelPlayer]?
    
    var activePlayer: GKGameModelPlayer?
    
    func setGameModel(_ gameModel: GKGameModel) {
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        return [Update()]
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
    func predict(_ board: [State], completion: ([Float32]) -> Void) {
        let result = strategist.bestMoveForActivePlayer()
        print(result)
        let array = Array(repeating: Float32(1), count: 64)
        completion(array)
    }
}
