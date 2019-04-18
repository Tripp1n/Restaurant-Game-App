//
//  Rect.swift
//  Game
//
//  Created by Torben Nordtorp on 2019-04-02.
//  Copyright © 2019 Torben Nordtorp. All rights reserved.
//

/**
 Describes an rectangle in a grid (that starts at (0,0) in bottomleft),
 where row and col describe the position of the bottom left corner of the rectangle
 and width and height how many squares this rect occupies from that position.
 */
public struct Rect {
    var col: Int
    var row: Int
    var ncol: Int
    var nrow: Int
    var pos: Pos {
        get { return Pos(col: col, row: row) }
        set { col = newValue.col; row = newValue.row }
    }
    var size: (Int, Int) {
        get { return (ncol, nrow) }
        set { ncol = newValue.0; nrow = newValue.1 }
    }
    
    var colRange: Range<Int> {
        get {
            return col..<col+ncol
        }
    }
    var rowRange: Range<Int> {
        get {
            return row..<row+nrow
        }
    }
    
    init(c: Int = 0, r: Int = 0, nc: Int = 1, nr: Int = 1) {
        self.col = c
        self.row = r
        self.ncol = nc
        self.nrow = nr
    }
    
    /** Checks if position pos is next to the given rect, and returns what direction one would
     need to go to get to the rect from that position. If not next to this rect, nil will
     be returned. */
    func isNextTo(pos p: Pos) -> Dir? {
        if      p.col == col-1    && p.row == row { return .east  }
        else if p.col == col+ncol && p.row == row { return .west }
        else if p.row == row-1    && p.col == col { return .north }
        else if p.row == row+nrow && p.col == col { return .south }
        else                                      { return nil    }
    }
    
    func overlaps(rect: Rect) -> Bool {
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
        
        // Else return false
        return false
    }
    func contains(pos: Pos) -> Bool {
        if pos.row >= row && pos.row <= row+nrow-1 && pos.col >= col && pos.col <= col+ncol-1 {
            return true
        }
        return false
    }
    func contains(rect: Rect) -> Bool {

        // For every position in the other rectangle
        for row in rect.row...rect.row+rect.ncol-1 {
            for col in rect.col...rect.col+rect.nrow-1 {
                
                // If any positions don't overlap, return false.
                if !contains(pos: Pos(col: col, row: row)) { return false }
                
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
