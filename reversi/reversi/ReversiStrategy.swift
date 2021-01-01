//
//  ReversiStrategy.swift
//  reversi
//
//  Created by TokyoYoshida on 2020/12/11.
//

import Foundation

protocol ReversiStrategy {
    func predict(_ board: [State], completion: ([Float32]) -> Void)
}

protocol BlockingReversiStrategy {
    func predict(_ board: [State]) -> [Int]
}
