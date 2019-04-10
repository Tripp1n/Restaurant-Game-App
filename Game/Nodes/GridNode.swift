//
//  GridNode.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-03-14.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class GridNode : SKNode
{
    public var gridHeight: Int {
        get { return gridData.count }
    }
    public var gridWidth: Int {
        get { return gridData[0].count }
    }
    private var isPlacable = false
    
    var offsetX = 0
    var offsetY = 0
    
    // 0 means empty spot, -1 means spot is occupied by solid object, -2 means occupied but walkable spot
    var gridData: [[Int]]! = nil

    public func addObjectToGrid(obj: Obj, at: Pos, isSolid: Bool)
    {
        // Mark positions as used
        for row in at.row...(obj.width+at.row-1) {
            for col in at.col...(obj.height+at.col-1) {
                if isSolid {
                    gridData[row][col] = -1
                } else {
                    gridData[row][col] = -2
                }
            }
        }
    
        // Other stuff
        //obj.isPlaced = true
    }
    
    public func isObjectPlaceable(object obj: Obj, at pos: Pos) -> Bool
    {
        for row in pos.row...(pos.row + obj.height-1) {
            for col in pos.col...(obj.width+pos.col-1) {
                if isCordUsed(at: Pos(col: col, row: row)) {
                    return false
                }
            }
        }
        return true
    }
    
    public func isCordUsed(at pos: Pos) -> Bool
    {
        let value = gridData[pos.row][pos.col]
        
        if value == -1 || value == -2 {
            return true
        } else {
            return false
        }
    }
    
    public func isPosAllowed(at pos: Pos) -> Bool {
        if pos.col < 0 || pos.row < 0 || pos.col > gridWidth-1 || pos.row > gridHeight-1 {
            return false
        } else {
            return true
        }
    }
    
    public func isRectAllowed(at rect: Rect) -> Bool {
        if rect.col < 0 || rect.row < 0 || rect.col+rect.width > gridWidth || rect.row+rect.height > gridHeight {
            return false
        } else {
            return true
        }
    }
    
    public func setupGrid (gameScene: GameScene, floorSize: Int, rows: Int, cols: Int)
    {
        self.alpha = 0
        self.gridData = Array(repeating: Array(repeating: 0, count: cols), count: rows)
        
        // Create the grid node lines
        offsetX = (floorSize/2)/rows
        offsetY = (floorSize/4)/cols
        
        for i in 0...Int(rows)
        {
            let path4 = CGMutablePath()
            path4.move(to: CGPoint(x: -floorSize/2 + offsetX*i, y: 0 - offsetY*i)) // Move to edge of diamond shape
            path4.addLine(to: CGPoint(x: 0 + offsetX*i, y: floorSize/4 - offsetY*i))
            let lineNode = SKShapeNode(path: path4)
            lineNode.strokeColor = .white
            lineNode.zPosition = 100
            lineNode.isUserInteractionEnabled = false
            addChild(lineNode)
            
            let path5 = CGMutablePath()
            path5.move(to: CGPoint(x: -floorSize/2 + offsetX*i, y: 0 + offsetY*i)) // Move to edge of diamond shape
            path5.addLine(to: CGPoint(x: 0 + offsetX*i, y: -floorSize/4 + offsetY*i))
            let lineNode2 = SKShapeNode(path: path5)
            lineNode2.strokeColor = .white
            lineNode2.zPosition = 100
            lineNode2.isUserInteractionEnabled = false
            addChild(lineNode2)
        }
    }
    
    public func hide() {
        self.alpha = 0
    }
    
    public func show() {
        self.alpha = 0.25
    }
}
