//
//  SolverTests.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 24/04/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import XCTest
@testable import PapyrusCore

class SolverTests: XCTestCase {
    
    var solver: Solver!
    let distribution = ScrabbleDistribution()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        solver = Solver(board: Board(config: ScrabbleBoardConfig()), anagramDictionary: AnagramDictionary.singleton, dictionary: Dawg.singleton, distribution: distribution)
        // Setup default state
        let intersection = Word(word: "cart", x: 6, y: 7, horizontal: false)
        solver.play(Solution(word: "cart", x: 5, y: 7, horizontal: true, score: 0, intersections: [], blanks: []))
        solver.play(Solution(word: "asked", x: 6, y: 7, horizontal: false, score: 0, intersections: [intersection], blanks: []))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        solver = nil
    }
    
    func testUnvalidatedWords() {
        measureBlock {
            XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "r", "c", "h", "o", "n", "s"], fixedLetters: [:], length: 7)!, ["anchors", "archons", "ranchos"])
        }
    }
    
    func testUnvalidatedWordsWithFixedLetter() {
        measureBlock {
            XCTAssertEqual(self.solver.unvalidatedWords(forLetters: ["a", "c", "h", "o", "n", "s"], fixedLetters: [0:"r"], length: 7)!, ["ranchos"])
        }
    }
    
    func compareSolution(solution: Solution, expected: Solution) {
        XCTAssertEqual(expected.word, solution.word)
        XCTAssertEqual(expected.score, solution.score)
        XCTAssertEqual(expected.horizontal, solution.horizontal)
        XCTAssertEqual(expected.x, solution.x)
        XCTAssertEqual(expected.y, solution.y)
        for (left, right) in zip(solution.intersections, expected.intersections) {
            XCTAssertEqual(left.word, right.word)
            XCTAssertEqual(left.horizontal, right.horizontal)
            XCTAssertEqual(left.x, right.x)
            XCTAssertEqual(left.y, right.y)
            XCTAssertNotEqual(left.horizontal, solution.horizontal)
        }
    }
    
    func multipleRacksTest(racks: [[RackTile]], solutions: [Solution]) {
        for (index, rack) in racks.enumerate() {
            let expectation = solutions[index]
            solver.solutions(rack, serial: true, completion: { (solutions) in
                let best = self.solver.solve(solutions!)!
                self.compareSolution(best, expected: expectation)
                self.solver.play(best)
            })
        }
    }
    
    func testScaling() {
            let rack: [RackTile] = ["c", "a", "r", "t", "e", "d"].map({ ($0, false) })
            self.solver.solutions(rack, serial: true) { (solutions) in
                guard let solutions = solutions else { XCTAssert(false); return }
                let hard = self.solver.solve(solutions)!
                let medium = self.solver.solve(solutions, difficulty: .Medium)!
                let easy = self.solver.solve(solutions, difficulty: .Easy)!
                let veryEasy = self.solver.solve(solutions, difficulty: .VeryEasy)!
                
                let hardExpectation = Solution(word: "raced", x: 7, y: 10, horizontal: false, score: 33, intersections: [
                    Word(word: "er", x: 6, y: 10, horizontal: true),
                    Word(word: "da", x: 6, y: 11, horizontal: true)], blanks: [])
                
                let mediumExpectation = Solution(word: "crated", x: 9, y: 5, horizontal: false, score: 24, intersections: [
                    Word(word: "carta", x: 5, y: 7, horizontal: true)], blanks: [])
                
                let easyExpectation = Solution(word: "recta", x: 9, y: 6, horizontal: false, score: 16, intersections: [
                    Word(word: "carte", x: 5, y: 7, horizontal: true)], blanks: [])
                
                let veryEasyExpectation = Solution(word: "aret", x: 8, y: 8, horizontal: true, score: 8, intersections: [
                    Word(word: "ta", x: 8, y: 7, horizontal: false)], blanks: [])

                
                self.compareSolution(hard, expected: hardExpectation)
                self.compareSolution(medium, expected: mediumExpectation)
                self.compareSolution(easy, expected: easyExpectation)
                self.compareSolution(veryEasy, expected: veryEasyExpectation)
            }
    }
    
    func testZeroTilesSolution() {
        solver.solutions([], serial: true, completion: { (solutions) in
            XCTAssertNil(solutions)
        })
    }
    
    func testBestSolution() {
        var racks = [[RackTile]]()
        racks.append([("a", false), ("r", false), ("t", false), ("i", false), ("s", false), ("t", false)])
        racks.append([("b", false), ("a", false), ("t", false), ("h", false), ("e", false), ("r", false)])
        racks.append([("c", false), ("e", false), ("l", false), ("i", false), ("a", false), ("c", false)])
        racks.append([("z", false), ("e", false), ("b", false), ("r", false), ("a", false), ("s", false)])
        racks.append([("q", false), ("u", false), ("e", false), ("e", false), ("n", false), ("y", false)])
        racks.append([("s", false), ("t", false), ("a", false), ("g", false), ("e", false), ("d", false)])
        racks.append([("r", false), ("a", false), ("t", false), ("i", false), ("n", false), ("g", false)])
        racks.append([("?", true), ("a", false), ("t", false), ("?", true), ("n", false), ("g", false)])    // Double wildcard is very slow, CPU should not get two wildcards, if it does lets randomize one of them to a specific value
        racks.append([("?", true), ("a", false), ("t", false), ("i", false), ("n", false), ("g", false)])    // Single wildcard is also slow, just not as bad
        racks.append([("c", false), ("a", false), ("t", false)])
    
        
        let expectations = [
            Solution(word: "tiars", x: 7, y: 10, horizontal: false, score: 24, intersections: [Word(word: "et", x: 6, y: 10, horizontal: true), Word(word: "di", x: 6, y: 11, horizontal: true)], blanks: []),
            Solution(word: "beath", x: 6, y: 6, horizontal: true, score: 35, intersections: [Word(word: "basked", x: 6, y: 6, horizontal: false), Word(word: "er", x: 7, y: 6, horizontal: false), Word(word: "at", x: 8, y: 6, horizontal: false)], blanks: []),
            Solution(word: "cicale", x: 8, y: 5, horizontal: true, score: 30, intersections: [Word(word: "cat", x: 8, y: 5, horizontal: false), Word(word: "it", x: 9, y: 5, horizontal: false), Word(word: "ch", x: 10, y: 5, horizontal: false)], blanks: []),
            Solution(word: "bez", x: 9, y: 4, horizontal: true, score: 60, intersections: [Word(word: "bit", x: 9, y: 4, horizontal: false), Word(word: "ech", x: 10, y: 4, horizontal: false), Word(word: "za", x: 11, y: 4, horizontal: false)], blanks: []),
            Solution(word: "nye", x: 8, y: 11, horizontal: false, score: 25, intersections: [Word(word: "din", x: 6, y: 11, horizontal: true), Word(word: "ay", x: 7, y: 12, horizontal: true), Word(word: "re", x: 7, y: 13, horizontal: true)], blanks: []),
            Solution(word: "egads", x: 10, y: 7, horizontal: true, score: 36, intersections: [Word(word: "eche", x: 10, y: 4, horizontal: false)], blanks: []),
            Solution(word: "git", x: 12, y: 8, horizontal: true, score: 16, intersections: [Word(word: "ag", x: 12, y: 7, horizontal: false), Word(word: "di", x: 13, y: 7, horizontal: false), Word(word: "st", x: 14, y: 7, horizontal: false)], blanks: []),
            Solution(word: "nag", x: 11, y: 9, horizontal: true, score: 21, intersections: [Word(word: "aga", x: 12, y: 7, horizontal: false), Word(word: "dig", x: 13, y: 7, horizontal: false)], blanks: []),
            Solution(word: "gi", x: 9, y: 13, horizontal: false, score: 15, intersections: [Word(word: "reg", x: 7, y: 13, horizontal: true)], blanks: []),
            Solution(word: "cat", x: 9, y: 9, horizontal: false, score: 16, intersections: [Word(word: "dint", x: 6, y: 11, horizontal: true)], blanks: [])]
        
        multipleRacksTest(racks, solutions: expectations)
        
        print(solver.board)
        print(solver.boardState)
    }
}
