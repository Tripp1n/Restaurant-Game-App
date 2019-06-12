//
//  Pos.swift
//  Game
//
//  Created by Torben Nordtorp on 2019-04-02.
//  Copyright © 2019 Torben Nordtorp. All rights reserved.
//

import Foundation

public struct Pos: Codable {
    var col: Int
    var row: Int
    
    init(c: Int = 0, r: Int = 0) {
        self.col = c
        self.row = r
    }
    
    static func == (lhs: Pos, rhs: Pos) -> Bool {
        return lhs.row == rhs.row && lhs.col == rhs.col
    }
    
    static func != (lhs: Pos, rhs: Pos) -> Bool {
        return !(lhs == rhs)
    }
    
    static func + (lhs: Pos, rhs: Pos) -> Pos {
        return Pos(c: lhs.col + rhs.col, r: lhs.row + rhs.row)
    }
    
    static func += (left: inout Pos, right: Pos) {
        left = left + right
    }
    
    static func - (lhs: Pos, rhs: Pos) -> Pos {
        return Pos(c: lhs.col - rhs.col, r: lhs.row - rhs.row)
    }
    
    public func toRect(width: Int = 1, height: Int = 1) -> Rect {
        return Rect(blc: col, blr: row, nc: width, nr: height)
    }
}
