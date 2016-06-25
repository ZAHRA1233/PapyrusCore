//
//  SuperScrabbleBag.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 25/06/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import Foundation

public struct SuperScrabbleBag: Bag {
    public static let vowels: [Character] = ["a", "e", "i", "o", "u"]
    public static let total = 200
    public static let letterPoints: [Character: Int] = [
        Game.blankLetter: 0, "a": 1, "b": 3, "c": 3, "d": 2,
        "e": 1, "f": 4, "g": 2, "h": 4, "i": 1,
        "j": 8, "k": 5, "l": 1, "m": 3, "n": 1,
        "o": 1, "p": 3, "q": 10, "r": 1, "s": 1,
        "t": 1, "u": 1, "v": 4, "w": 4, "x": 8,
        "y": 4, "z": 10]
    public static let letterCounts: [Character: Int] = [
        Game.blankLetter: 4, "a": 16, "b": 4, "c": 6, "d": 8,
        "e": 24, "f": 4, "g": 5, "h": 5, "i": 13,
        "j": 2, "k": 2, "l": 7, "m": 6, "n": 13,
        "o": 15, "p": 4, "q": 2, "r": 13, "s": 10,
        "t": 15, "u": 7, "v": 3, "w": 4, "x": 2,
        "y": 4, "z": 2]
    
    public var remaining = [Character]()
    public init() {
        prepare()
    }
}