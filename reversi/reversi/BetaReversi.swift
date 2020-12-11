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
        static func convert(_ board: [State]) -> MLMultiArray {
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
            put(mlArray, 0, .pointWhite)
            put(mlArray, 1, .pointBlack)
            print(ReversiModelDecoder.decode(mlArray))
            print(ReversiModelDecoder.decode(mlArray, offset: 64))
            return mlArray
        }
    }
    struct ReversiModelDecoder {
        static func decode(_ coreMLResult: MLMultiArray, offset: Int = 0) -> [Float32] {
            var resBoard = Array(repeating: Float32(0), count: 64*2)
            for i in 0..<64 {
                resBoard[i] = coreMLResult[i + offset] as! Float32
            }
            return resBoard
        }
    }
    struct ReversiPredictionDecoder {
        static let directions = [-9, -8, -7, -1, 1, 7, 8, 9]
        static func descode(_ prediction: [Float32], _ board: [State], _ ownState: State) -> Int? {
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
            let enumerated = prediction.enumerated().map { (index: $0.0,value: $0.1) }
            let sorted = enumerated.sorted {$0.value > $1.value }
            for i in 0..<64 {
                if canPut(sorted[i].index) {
                    return sorted[i].index
                }
            }
            return nil
        }
    }

    func predict(_ board: [State], completion: ([Float32]) -> Void)  {
        let model = try reversi()
        let mlArray = boardConverter.convert(board)
        let inputToModel: reversiInput = reversiInput(permute_2_input: mlArray)
        if let prediction = try? model.prediction(input: inputToModel) {
            let resArray = try? prediction.Identity
            let result = ReversiModelDecoder.decode(resArray!)
            completion(result)
        }
    }
}
