//
//  BetaReversi.swift
//  reversi
//
//  Created by TokyoYoshida on 2020/12/10.
//

import Foundation
import CoreML

struct BetaReversi: ReversiStrategy {
    struct boardConverter {
        static func convert(_ board: [State], _ targetPlayer: State) -> MLMultiArray {
            func put(_ array: MLMultiArray, _ index: Int, _ targetState: State) {
                for j in 0..<8{
                    for k in 0..<8{
                        if board[j*8 + k] == targetState {
                            mlArray[8*8*index + 8*j + k] = 1
                        } else {
                            mlArray[8*8*index + 8*j + k] = 0
                        }
                    }
                }
            }
            let mlArray = try! MLMultiArray(shape: [1,2,8,8], dataType: .float32)
            put(mlArray, 0, targetPlayer)
            put(mlArray, 1, targetPlayer.opponent)
            print(ReversiModelDecoder.decode(mlArray))
            return mlArray
        }
    }
    struct ReversiModelDecoder {
        static func decode(_ coreMLResult: MLMultiArray, offset: Int = 0) -> [Float32] {
            var resBoard = Array(repeating: Float32(0), count: 64)
            for i in 0..<64 {
                resBoard[i] = coreMLResult[i + offset] as! Float32
            }
            return resBoard
        }
    }
    struct ReversiPredictionDecoder {
        static func sorted(_ prediction: [Float32], _ board: [State], _ ownState: State) -> [(index: Int, value: Float32)] {
            assert(prediction.count == 64, "wrong range.")
            let enumerated = prediction.enumerated().map { (index: $0.0,value: $0.1) }
            let sorted = enumerated.sorted {$0.value > $1.value }
            var results: [(Int, Float32)] = []
            let _board = Board()
            _board._state = board
            for i in 0..<64 {
                if _board.canPut(ownState, sorted[i].index) {
                    results.append(sorted[i])
                }
            }
            return results
        }

        static func decode(_ prediction: [Float32], _ board: [State], _ ownState: State) -> [Int] {
            let filtered = sorted(prediction, board, ownState)
            return filtered.map {$0.index}
        }

        static func eval(_ prediction: [Float32], _ board: [State], _ ownState: State) -> Float32 {
            let filtered = sorted(prediction, board, ownState)
            if filtered.isEmpty {
                return -1
            }
            return filtered[0].value
        }
    }


    func predict(_ board: [State], _ targetPlayer: State, completion: ([Float32]) -> Void)  {
        let model = try reversi()
        let mlArray = boardConverter.convert(board, targetPlayer)
        let inputToModel: reversiInput = reversiInput(permute_input: mlArray)
        if let prediction = try? model.prediction(input: inputToModel) {
            let resArray = try? prediction.Identity
            let results = ReversiModelDecoder.decode(resArray!)
            completion(results)
        }
    }
}

struct BlockingBetaReversi: BlockingReversiStrategy {
    class Box {
        var moves: [Float32] = []
    }
    let strategy = BetaReversi()
    func predict(_ board: [State], _ targetPlayer: State) -> [Float32] {
        let semaphore  = DispatchSemaphore(value: 0)
        let resultBox = Box()
        strategy.predict(board, targetPlayer) {
            (predict) in
            resultBox.moves = predict
            semaphore.signal()
        }
        semaphore.wait()
        return resultBox.moves
    }
}
