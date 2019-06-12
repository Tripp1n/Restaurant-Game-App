//
//  Rect.swift
//  Game
//
//  Created by Torben Nordtorp on 2019-04-02.
//  Copyright © 2019 Torben Nordtorp. All rights reserved.
//

/**
 Describes an rectangle (with orgin at the bottom left) in a grid ,
 where row and col describe the position of the bottom left corner of the rectangle
 and width and height how many squares this rect occupies from that position.
 */
import SpriteKit

public struct Rect: Codable {
    var col: Int = 0
    var row: Int = 0
    var ncol: Int = 1
    var nrow: Int = 1
    
    var pos: Pos {
        get { return Pos(c: col, r: row) }
        set { col = newValue.col; row = newValue.row }
    }
    var size: (Int, Int) {
        get { return (ncol, nrow) }
        set { ncol = newValue.0; nrow = newValue.1 }
    }
    var colRng: Range<Int> {
        get {
            return col..<col+ncol
        }
    }
    var rowRng: Range<Int> {
        get {
            return row..<row+nrow
        }
    }
    
    init(blc: Int = 0, blr: Int = 0, nc: Int = 1, nr: Int = 1) {
        //assert(c >= 0, "colum must be positive")
        //assert(c >= 0, "row must be positive")
        //assert(c >= 0, "colums must be positive")
        //assert(c >= 0, "rows must be positive")

        self.col = blc
        self.row = blr
        self.ncol = nc
        self.nrow = nr
    }
    
    /** Checks if position pos is next to the given rect, and returns what direction one would
     need to go to get to the rect from that position. If not next to this rect, nil will
     be returned. */
    func isNextTo(pos p: Pos) -> Dir? {
             if p.col == col-1    && rowRng.contains(p.row) { return .east  }
        else if p.col == col+ncol && rowRng.contains(p.row) { return .west  }
        else if p.row == row-1    && colRng.contains(p.col) { return .north }
        else if p.row == row+nrow && colRng.contains(p.col) { return .south }
        else                                                { return nil    }
    }
    
    /** Check if other rect is next to this one, and return that cardinal direction or none, if not
     next to eachother. */
    func isNextTo(_ other: Rect) -> Dir? {
        if !self.overlaps(other) {
            for r in other.rowRng {
                for c in other.colRng {
                    if let val = isNextTo(pos: Pos(c: c, r: r)) {
                        return val
                    }
                }
            }
        }
        return nil
    }
    
    func getOverlappingEdges(in p: Pos) -> [Dir?] {
        var rtnArr: [Dir?] = []
        if p.col == col        && rowRng.contains(p.row) { rtnArr.append(.west ) }
        if p.col == col+ncol-1 && rowRng.contains(p.row) { rtnArr.append(.east ) }
        if p.row == row        && colRng.contains(p.col) { rtnArr.append(.south) }
        if p.row == row+nrow-1 && colRng.contains(p.col) { rtnArr.append(.north) }
        return rtnArr
    }
    /*
     r
     5  ---141--
     4  777141--
     3  --2113--
     2  -55--66-
     1  -55-----
     0  --2-----
     
     01234567 --> c
     
     XCTAssertEqual(rect3.getOverlappingEdges(of: rect1), [.east, .north])
     */
    
    /** Gets the directions in which "self" touches the "other" inner edges. */
    func getOverlappingEdges(in other: Rect) -> Set<Dir?> {
        var rtnArr: Set<Dir?> = []
        for r in rowRng {
            for c in colRng {
                let arr = other.getOverlappingEdges(in: Pos(c: c, r: r))
                if !arr.isEmpty {
                    rtnArr = rtnArr.union(arr)
                }
            }
        }
        return rtnArr
    }
    
    func overlaps(_ rect: Rect) -> Bool {
        // For every position in first rectangle
        for x1 in row...row+nrow-1 {
            for y1 in col...col+ncol-1 {
                
                // For every position in second rectangle
                for x2 in rect.row...rect.row+rect.nrow-1 {
                    for y2 in rect.col...rect.col+rect.ncol-1 {
                        
                        // If the positions overlap, return true.
                        if x1 == x2 && y1 == y2 { return true }
                    }
                }
            }
        }
        return false
    }
    
    func contains(pos: Pos) -> Bool {
        if pos.row >= row && pos.row <= row+nrow-1 && pos.col >= col && pos.col <= col+ncol-1 {
            return true
        }
        return false
    }
    
    func contains(_ rect: Rect) -> Bool {

        // For every position in the other rectangle
        for row in rect.rowRng {
            for col in rect.colRng {
                
                // If any positions don't overlap, return false.
                if !contains(pos: Pos(c: col, r: row)) { return false }
            }
        }
        return true
    }
    
    static func == (lhs: Rect, rhs: Rect) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col && lhs.ncol == rhs.ncol && lhs.nrow == rhs.nrow
    }
    
    static func != (lhs: Rect, rhs: Rect) -> Bool {
        return !(lhs == rhs)
    }
    
    func toStr() -> String {
        return "[c: \(col), r: \(row), w: \(ncol), h: \(nrow)]"
    }
}
