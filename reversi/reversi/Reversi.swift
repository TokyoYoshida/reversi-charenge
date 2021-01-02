//
//  Reversi.swift
//  reversi
//
//  Created by TokyoYoshida on 2021/01/03.
//

import Foundation

enum State {
    case pointNone
    case pointBlack
    case pointWhite
    var opponent: State {
        switch self {
        case .pointWhite:
            return .pointBlack
        case .pointBlack:
            return .pointWhite
        case .pointNone:
            assertionFailure("This condition is not expected")
            return .pointNone
        }
    }
    
    var description: String {
        switch self {
        case .pointWhite:
            return "white"
        case .pointBlack:
            return "black"
        case .pointNone:
            return "none"
        }
    }
}

class Board {
    let directions = [-9, -8, -7, -1, 1, 7, 8, 9]

    var _state: [State] = Array<State>(repeating: .pointNone, count: 64)
    
    init() {
        func buildInitialState() {
            _state[27] = .pointWhite
            _state[36] = .pointWhite
            _state[28] = .pointBlack
            _state[35] = .pointBlack
        }
        
        buildInitialState()
    }

    func getState(_ position: Int) -> State {
        return _state[position]
    }
    
    func putWithReverse(_ position: Int, _ state: State) {
        _state[position] = state
        reverse(state, position)
    }

    func putWithoutReverse(_ position: Int, _ state: State) {
        _state[position] = state
    }

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

    func canPutToDirection(_ ownState: State, _ index: Int, _ direction: Int) -> Bool {
        var i = index
        while isinBoard(i, direction) {
            i += direction
            switch _state[i] {
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
    
    func canPut(_ ownState: State, _ index: Int) -> Bool {
        guard _state[index] == .pointNone else {
            return false
        }
        for d in directions {
            if canPutToDirection(ownState, index, d) {
                return true
            }
        }
        return false
    }
    
    func reverseToDirection(_ ownState: State, _ index: Int, _ direction: Int) {
        var i = index
        while isinBoard(i, direction) {
            i += direction
            switch _state[i] {
            case ownState:
                return
            case .pointNone:
                return
            default:
                // is enemy, so reverse
                _state[i] = ownState
                break
            }
        }
        return
    }

    func reverse(_ ownState: State, _ index: Int) {
        for d in directions {
            if canPutToDirection(ownState, index, d) {
                reverseToDirection(ownState, index ,d)
            }
        }
        return
    }
}
