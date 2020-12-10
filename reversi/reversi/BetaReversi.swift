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
        static func decode(_ coreMLResult: MLMultiArray) -> Int {
            var res_board = Array(repeating: Array(repeating: Float32(0), count: 8), count: 8)
            for j in 0..<8{
                for k in 0..<8{
                    res_board[j][k] = round(coreMLResult[8*j + k] as! Float32)
                }
            }
            print(res_board)
            return 11
        }
    }
    static func thinkNextMove(_ board: [State], completion: (Int) -> Void) {
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
