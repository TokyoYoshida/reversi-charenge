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
        func getColumnIncreaseInDirection(_ direction: Int) -> Int {
            switch direction {
            case -9, -1 ,7:
                return -1
            case -7 ,1, 9:
                return 1
            case -8 ,8:
                return 0
            default:
                assertionFailure("wrong direction")
                return 0
            }
        }
        func calcRow( _ index: Int) -> Int {
            return index / 8
        }
        func calcCol(_ index: Int) -> Int {
            return index - calcRow(index) * 8
        }
        func checkByRow() -> Bool {
            if case 0..<64 = index + direction {
                return true
            }
            return false
        }
        func checkByCol() -> Bool {
            let basecol = calcCol(index)

            switch getColumnIncreaseInDirection(direction) {
            case 1:
                return basecol != 7
            case -1:
                return basecol != 0
            case 0:
                return true
            default:
                assertionFailure("wrong direction")
                return false
            }
        }
        return checkByRow() && checkByCol()
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
