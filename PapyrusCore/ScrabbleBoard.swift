//
//  ScrabbleBoard.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 25/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public func ==(lhs: ScrabbleBoard, rhs: ScrabbleBoard) -> Bool {
    return compareBoards(lhs, rhs)
}

public struct ScrabbleBoard: Board, Equatable {
    public let empty = Character(" ")
    public let center = 7
    public let size = 15
    public var layout = Array(count: 15, repeatedValue: Array(count: 15, repeatedValue: Character(" ")))
    public var blanks = [(x: Int, y: Int)]()
    public let letterMultipliers = [
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,1,1,1,3,1,1,1,3,1,1,1,1,1],
        [1,1,1,1,1,1,2,1,2,1,1,1,1,1,1],
        [2,1,1,1,1,1,1,2,1,1,1,1,1,1,2],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,3,1,1,1,3,1,1,1,3,1,1,1,3,1],
        [1,1,2,1,1,1,2,1,2,1,1,1,2,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,2,1,1,1,2,1,2,1,1,1,2,1,1],
        [1,3,1,1,1,3,1,1,1,3,1,1,1,3,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [2,1,1,1,1,1,1,2,1,1,1,1,1,1,2],
        [1,1,1,1,1,1,2,1,2,1,1,1,1,1,1],
        [1,1,1,1,1,3,1,1,1,3,1,1,1,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1]]
    public let wordMultipliers = [
        [3,1,1,1,1,1,1,3,1,1,1,1,1,1,3],
        [1,2,1,1,1,1,1,1,1,1,1,1,1,2,1],
        [1,1,2,1,1,1,1,1,1,1,1,1,2,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,1,1,2,1,1,1,1,1,2,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [3,1,1,1,1,1,1,2,1,1,1,1,1,1,3],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,1,1,1,2,1,1,1,1,1,2,1,1,1,1],
        [1,1,1,2,1,1,1,1,1,1,1,2,1,1,1],
        [1,1,2,1,1,1,1,1,1,1,1,1,2,1,1],
        [1,2,1,1,1,1,1,1,1,1,1,1,1,2,1],
        [3,1,1,1,1,1,1,3,1,1,1,1,1,1,3]]
}
