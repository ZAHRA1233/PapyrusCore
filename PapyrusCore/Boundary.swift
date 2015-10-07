//
//  Boundary.swift
//  PapyrusCore
//
//  Created by Chris Nevin on 14/08/2015.
//  Copyright © 2015 CJNevin. All rights reserved.
//

import Foundation

public func == (lhs: Boundary, rhs: Boundary) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public struct Boundary: CustomDebugStringConvertible, Hashable {
    public let start: Position
    public let end: Position
    
    public var horizontal: Bool {
        return start.horizontal
    }
    public var length: Int {
        return iterableRange.endIndex - iterableRange.startIndex
    }
    public var iterableRange: Range<Int> {
        return start.iterable...end.iterable
    }
    public var hashValue: Int {
        return debugDescription.hashValue
    }
    public var debugDescription: String {
        let h = start.horizontal ? "H" : "V"
        return "[\(start.iterable),\(start.fixed) - \(end.iterable),\(end.fixed) - \(h)]"
    }
    
    public init?(start: Position?, end: Position?) {
        if start == nil || end == nil { return nil }
        self.start = start!
        self.end = end!
        if !isValid { return nil }
    }
    
    public init?(positions: [Position]) {
        guard let first = positions.first, last = positions.last else { return nil }
        self.start = first
        self.end = last
        if !isValid { return nil }
    }
    
    /// - returns: Inverted positions for this boundary.
    public func invertedPositions() -> [Position] {
        return iterableRange.mapFilter { (index) -> (Position?) in
            Position(horizontal: !horizontal, iterable: start.fixed, fixed: index)
        }
    }
    
    /// - returns: All positions for this boundary.
    public func positions() -> [Position] {
        return iterableRange.mapFilter { (index) -> (Position?) in
            Position(horizontal: horizontal, iterable: index, fixed: start.fixed)
        }
    }
    
    /// - returns: Whether this boundary appears to contain valid positions.
    private var isValid: Bool {
        let valid = start.fixed == end.fixed &&
            start.iterable <= end.iterable &&
            start.horizontal == end.horizontal
        return valid
    }
    
    /// - returns: True if the axis and fixed values match and the iterable value intersects the given boundary.
    public func containedIn(boundary: Boundary) -> Bool {
        return boundary.contains(self)
    }
    
    /// - returns: True if the given boundary is contained in this boundary.
    public func contains(boundary: Boundary) -> Bool {
        // Check if same axis and same fixed value.
        if boundary.horizontal == horizontal && boundary.start.fixed == start.fixed {
            // If they coexist on the same fixed line, check if there is any iterable intersection.
            return
                start.iterable <= boundary.start.iterable &&
                end.iterable >= boundary.end.iterable
        }
        return false
    }
    
    /// - returns: True if position is within this boundary's range.
    public func contains(position: Position) -> Bool {
        // If different axis, swap
        if position.horizontal != horizontal {
            return contains(position.positionWithHorizontal(horizontal)!)
        }
        // If different fixed position it cannot be contained
        if position.fixed != start.fixed { return false }
        return iterableRange.contains(position.iterable)
    }
    
    /// - returns: True if boundary intersects another boundary on opposite axis.
    public func intersects(boundary: Boundary) -> Bool {
        // Check if different axis
        if horizontal == boundary.start.horizontal { return false }
        // FIXME: Check if same fixed value ??
        if start.fixed != boundary.start.fixed { return false }
        // Check if iterable value intersects on either range
        return iterableRange.contains({boundary.iterableRange.contains($0)}) ||
            boundary.iterableRange.contains({iterableRange.contains($0)})
    }
    
    /// Currently unused.
    /// - returns: Boundary at previous fixed index or nil.
    public func previous() -> Boundary? {
        return Boundary(start: start.positionWithFixed(start.fixed - 1),
            end: end.positionWithFixed(end.fixed - 1))
    }
    
    /// Currently unused.
    /// - returns: Boundary at next fixed index or nil.
    public func next() -> Boundary? {
        return Boundary(start: start.positionWithFixed(start.fixed + 1),
            end: end.positionWithFixed(end.fixed + 1))
    }
    
    /// - returns: True if on adjacent fixed value and iterable seems to be in the same range.
    /// i.e. At least end position of the given boundary falls within the start-end range of this
    /// boundary. Or the start position of the given boundary falls within the start-end range
    /// of this boundary.
    public func adjacentTo(boundary: Boundary) -> Bool {
        if boundary.start.horizontal == start.horizontal &&
            ((boundary.start.fixed + 1) == start.fixed ||
                (boundary.start.fixed - 1) == start.fixed) {
            return
                (boundary.start.iterable >= start.iterable &&
                    boundary.start.iterable <= end.iterable) ||
                (boundary.end.iterable > start.iterable &&
                    boundary.start.iterable <= start.iterable)
        }
        return false
    }
    
    // MARK: Shrink
    // These methods favour the lesser values of the two (min/max).
    
    /// - returns: New boundary encompassing the new start and end iterable values.
    public func shrink(startIterable: Int, endIterable: Int) -> Boundary? {
        if startIterable == start.iterable && endIterable == end.iterable { return self }
        return Boundary(
            start: start.positionWithMaxIterable(startIterable),
            end: end.positionWithMinIterable(endIterable))
    }
    
    /// Shrinks the current Boundary to encompass the given start and end iterable values.
    public mutating func shrinkInPlace(startIterable: Int, endIterable: Int) {
        if let newBoundary = shrink(startIterable, endIterable: endIterable) {
            self = newBoundary
        }
    }
    
    /// - returns: New boundary encompassing the new start and end positions.
    public func shrink(newStart: Position, newEnd: Position) -> Boundary? {
        return shrink(newStart.iterable, endIterable: newEnd.iterable)
    }
    
    /// Shrinks the current Boundary to encompass the given start and end positions.
    public mutating func shrinkInPlace(newStart: Position, newEnd: Position) {
        if let newBoundary = shrink(newStart, newEnd: newEnd) {
            self = newBoundary
        }
    }
    
    // MARK: Stretch
    // These methods favour the greater values of the two (min/max).
    
    /// - returns: New boundary encompassing the new start and end iterable values.
    public func stretch(startIterable: Int, endIterable: Int) -> Boundary? {
        if startIterable == start.iterable && endIterable == end.iterable { return self }
        return Boundary(
            start: start.positionWithMinIterable(startIterable),
            end: end.positionWithMaxIterable(endIterable))
    }
    
    /// Stretches the current Boundary to encompass the given start and end iterable values.
    public mutating func stretchInPlace(startIterable: Int, endIterable: Int) {
        if let newBoundary = stretch(startIterable, endIterable: endIterable) {
            self = newBoundary
        }
    }
    
    /// - returns: New boundary encompassing the new start and end positions.
    public func stretch(newStart: Position, newEnd: Position) -> Boundary? {
        return stretch(newStart.iterable, endIterable: newEnd.iterable)
    }
    
    /// Stretches the current Boundary to encompass the given start and end positions.
    public mutating func stretchInPlace(newStart: Position, newEnd: Position) {
        if let newBoundary = stretch(newStart, newEnd: newEnd) {
            self = newBoundary
        }
    }
}

extension Papyrus {
    
    // MARK:- Stretch
    // These methods favour the greater values of the two (min/max).
    
    /// - returns: All boundaries for filled tiles in both axes.
    public func filledBoundaries() -> [Boundary] {
        func getBoundaries(withHorizontal horizontal: Bool, fixed: Int) -> [Boundary] {
            func iterate(iterable: Int) -> Boundary? {
                let start = nextWhileEmpty(
                    Position(horizontal: horizontal, iterable: iterable, fixed: fixed))?.next()
                let end = nextWhileFilled(start)
                return Boundary(start: start, end: end)
            }
            var i = 0
            var lineBoundaries = [Boundary]()
            while let boundary = iterate(i) {
                lineBoundaries.append(boundary)
                i = boundary.end.iterable + 1
            }
            return lineBoundaries
        }
        var boundaries = Set<Boundary>()
        (0..<PapyrusDimensions).forEach({ (fixed) in
            boundaries.unionInPlace(getBoundaries(withHorizontal: false, fixed: fixed))
            boundaries.unionInPlace(getBoundaries(withHorizontal: true, fixed: fixed))
        })
        return Array(boundaries)
    }
    
    /// Stretch in either direction until the start/end postions are not filled.
    public func stretchIfFilled(boundary: Boundary?) -> Boundary? {
        return Boundary(
            start: previousWhileFilled(boundary?.start) ?? boundary?.start,
            end: nextWhileFilled(boundary?.end) ?? boundary?.end)
    }
    
    /// Stretch in either direction while the start/end positions are filled.
    public func stretchWhileFilled(boundary: Boundary?) -> Boundary? {
        guard let
            boundary = boundary,
            adjustedStart = previousWhileFilled(boundary.start),
            adjustedEnd = nextWhileFilled(boundary.end),
            adjustedBoundary = Boundary(start: adjustedStart, end: adjustedEnd) else {
                return nil
        }
        return adjustedBoundary
    }
    
    /// - parameter boundary: Boundary containing tiles that have been dropped on the board.
    /// - returns: Array of word boundaries that intersect the supplied boundary.
    func findIntersections(forBoundary boundary: Boundary) -> [Boundary] {
        return boundary.invertedPositions().mapFilter({ (position) -> (Boundary?) in
            guard let wordStart = previousWhileFilled(position),
                wordEnd = nextWhileFilled(position),
                wordBoundary = Boundary(start: wordStart, end: wordEnd) else { return nil }
            return wordBoundary
        })
    }
    
    /// Calculate score for a given boundary.
    /// - parameter boundary: The boundary you want the score of.
    func score(boundary: Boundary) throws -> Int {
        guard let player = player else { throw ValidationError.NoPlayer }
        let affectedSquares = squaresIn(boundary)
        var value = affectedSquares.mapFilter({$0.letterValue}).reduce(0, combine: +)
        value = affectedSquares.mapFilter({$0.wordMultiplier}).reduce(value, combine: *)
        let dropped = tilesIn(affectedSquares).filter({$0.placement == Placement.Board && player.tiles.contains($0)})
        if dropped.count == PapyrusRackAmount {
            // Add bonus
            value += 50
        }
        return value
    }
    
    // MARK: - Playable
    
    /// - parameter boundary: Find filled tiles then return the index and characters for the boundary.
    /// - returns: Array of indexes and characters.
    func allLetters(inBoundary boundary: Boundary) -> [Int: Character] {
        var positionValues = [Int: Character]()
        boundary.positions().forEach { (position) in
            guard let letter = letterAt(position) else { return }
            positionValues[position.iterable - boundary.start.iterable] = letter
        }
        return positionValues
    }
    
    /// - returns: All possible boundaries we may be able to place tiles in, stemming off of all existing words.
    // FIXME: Seems to not return all possibilities, we should make tiles glow to provide visual
    // while debugging.
    public func allPlayableBoundaries() -> [Boundary] {
        var allBoundaries = Set<Boundary>()
        filledBoundaries().forEach { (boundary) in
            // Main boundary already includes all possible tiles.
            if let mainBoundaries = playableBoundaries(forBoundary: boundary) {
                allBoundaries.unionInPlace(mainBoundaries)
            }
            // Adjacent boundaries do not, so we should pad them.
            if let adjacentPrevious = stretchIfFilled(boundary.previous()),
                adjacentBoundaries = playableBoundaries(forBoundary: adjacentPrevious) {
                allBoundaries.unionInPlace(adjacentBoundaries)
            }
            if let adjacentNext = stretchIfFilled(boundary.next()),
                adjacentBoundaries = playableBoundaries(forBoundary: adjacentNext) {
                allBoundaries.unionInPlace(adjacentBoundaries)
            }
        }
        return Array(allBoundaries)
    }
    
    /// - returns: All possible boundaries we may be able to place tiles in, stemming off of a given boundary.
    func playableBoundaries(forBoundary boundary: Boundary) -> [Boundary]? {
        guard let
            newStart = previousWhileTilesInRack(boundary.start),
            newEnd = nextWhileTilesInRack(boundary.end),
            newBoundary = boundary.stretch(newStart, newEnd: newEnd) else
        {
            return nil
        }
        let rackCount = player!.rackTiles.count
        let boundaryTileCount = tilesIn(boundary).count

        // Get maximum word size, then shift the iterable index
        var maxLength = boundary.length + rackCount
        // Adjust for existing tiles on the board
        maxLength += tilesIn(newBoundary).count - boundaryTileCount
        
        let lengthRange = 0..<maxLength
        return newBoundary.iterableRange.flatMap({ (startIterable) -> ([Boundary]) in
            lengthRange.mapFilter({ (length) -> (Boundary?) in
                let endIterable = startIterable + length
                guard let stretched = boundary.stretch(startIterable,
                    endIterable: endIterable) else { return nil }
                
                return stretched
            })
        })
    }
}
