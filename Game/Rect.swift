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
    var width: Int
    var height: Int
    
    var colRange: Range<Int> {
        get {
            return col..<col+width
        }
    }
    var rowRange: Range<Int> {
        get {
            return row..<row+height
        }
    }
    
    init(col: Int = 0, row: Int = 0, width: Int = 1, height: Int = 1) {
        self.col = col
        self.row = row
        self.width = width
        self.height = height
    }
    
    func isNextTo(pos p: Pos) -> Bool {
        if (p.col == col-1 || p.col == col+width) && (p.row == row-1 || p.row == row+height) {
            return true
        }
        else { return false }
    }
    
    func overlaps(rect: Rect) -> Bool {
        // For every position in first rectangle
        for x1 in row...row+height-1 {
            for y1 in col...col+width-1 {
                
                // For every position in second rectangle
                for x2 in rect.row...rect.row+rect.height-1 {
                    for y2 in rect.col...rect.col+rect.width-1 {
                        
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
        if pos.row >= row && pos.row <= row+height-1 && pos.col >= col && pos.col <= col+width-1 {
            return true
        }
        return false
    }
    func contains(rect: Rect) -> Bool {

        // For every position in the other rectangle
        for row in rect.row...rect.row+rect.width-1 {
            for col in rect.col...rect.col+rect.height-1 {
                
                // If any positions don't overlap, return false.
                if !contains(pos: Pos(col: col, row: row)) { return false }
                
            }
        }
        return true
    }
    
    func toPos() -> Pos {
        return Pos(col: col, row: row)
    }

    mutating func setPos(pos: Pos) {
        self.row = pos.row
        self.col = pos.col
    }
    mutating func setPos(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    static func == (lhs: Rect, rhs: Rect) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col && lhs.width == rhs.width && lhs.height == rhs.height
    }
    
    static func != (lhs: Rect, rhs: Rect) -> Bool {
        return !(lhs == rhs)
    }
    
    func toStr() -> String {
        return "[c: \(col), r: \(row), w: \(width), h: \(height)]"
    }
}
