//
//  BetaReversi.swift
//  reversi
//
//  Created by TokyoYoshida on 2020/12/10.
//

import Foundation
import CoreML

struct BetaReversi {
    struct boardConverter {
        static func convert(_ board: [State]) -> MLMultiArray {
            let mlArray = try! MLMultiArray(shape: [1,2,8,8], dataType: .float32)
            let board = [
                [
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,1,0,0,0],
                    [0,0,0,1,0,1,0,0],
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,0,0,0,0],
                ]
                ,
                [
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,1,0,0,0,0],
                    [0,0,0,0,1,0,0,0],
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,0,0,0,0],
                    [0,0,0,0,0,0,0,0],
                ]
            ]
            for i in 0..<2 {
                for j in 0..<8{
                    for k in 0..<8{
                        mlArray[8*8*i + 8*j + k] = board[i][j][k] as NSNumber
                    }
                }
            }
            return mlArray
        }
    }
    struct ReversiModelDecoder {
        static func decode(_ coreMLResult: MLMultiArray) -> [Float32] {
            var resBoard = Array(repeating: Float32(0), count: 64)
            for i in 0..<64{
                resBoard[i] = coreMLResult[i] as! Float32
            }
            return resBoard
        }
    }
    struct ReversiPredictionDecoder {
        static func descode(_ prediction: [Float32]) -> Int {
            let enumerated = prediction.enumerated().map { (index: $0.0,value: $0.1) }
            let sorted = enumerated.sorted {$0.value > $1.value }
            return sorted[0].index
        }
    }
    static func predict(_ board: [State], completion: ([Float32]) -> Void) {
        let model = reversi()
        let mlArray = boardConverter.convert(board)
        let inputToModel: reversiInput = reversiInput(permute_2_input: mlArray)
        if let prediction = try? model.prediction(input: inputToModel) {
            let resArray = try? prediction.Identity
            let result = ReversiModelDecoder.decode(resArray!)
            completion(result)
        }
    }
}
