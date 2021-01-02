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
        static let directions = [-9, -8, -7, -1, 1, 7, 8, 9]
        static func sorted(_ prediction: [Float32], _ board: [State], _ ownState: State) -> [(index: Int, value: Float32)] {
            func isinBoard(_ index: Int, _ direction: Int) -> Bool {
                func calcRow( _ index: Int) -> Int {
                    return index / 8
                }
                func calcCol(_ index: Int) -> Int {
                    return index - calcRow(index) * 8
                }
                guard case 0..<64 = index + direction else {
                    return false
                }
                let basecol = calcCol(index)
                let nextcol = calcCol(index + direction)

                if nextcol != basecol {
                    if direction > 0 {
                        return basecol != 7
                    } else {
                        return basecol != 0
                    }
                }
                return true
            }
            func canPutToDirection(_ index: Int, _ direction: Int) -> Bool {
                var i = index
                while isinBoard(i, direction) {
                    i += direction
                    switch board[i] {
                    case ownState:
                        return abs(i - index) > abs(direction)
                    case .pointNone:
                        return false
                    default: // is enemy
                        break
                    }
                }
                return false
            }
            func canPut(_ index: Int) -> Bool {
                guard board[index] == .pointNone else {
                    return false
                }
                for d in directions {
                    if canPutToDirection(index, d) {
                        return true
                    }
                }
                return false
            }
            assert(prediction.count == 64, "wrong range.")
            let enumerated = prediction.enumerated().map { (index: $0.0,value: $0.1) }
            let sorted = enumerated.sorted {$0.value > $1.value }
            var results: [(Int, Float32)] = []
            for i in 0..<64 {
                if canPut(sorted[i].index) {
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
