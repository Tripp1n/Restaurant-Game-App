//
//  Object.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-03-16.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

let gridWidth : CGFloat = 40
let gridHeight: CGFloat = 20

enum ObjectType {
    case symetric
    case semisymetric
    case direction
}

public class Object: SKSpriteNode
{
    var rect: Rect          // Position and size of object in room-grid.
    var dir: Dir = .north   // Direction object is facing.
    var panStart: Pos?      // Nil unless user is moving the object. Represents pos when pan began.
    var type: ObjectType    // What type of object is it?
    var pos: Pos {
        get { return rect.pos }
        set {
            zPosition = CGFloat(10 + newValue.col - newValue.row)
            rect.pos = newValue
        }
    }
    var width: Int {
        get { return rect.ncol }
        set { rect.ncol = newValue }
    }
    var height: Int {
        get { return rect.nrow }
        set { rect.nrow = newValue }
    }
    
    // Create a new Object and move it to the correct spot
    init(img: SKTexture, rect: Rect, type: ObjectType = .symetric) {
        self.rect = rect
        self.type = type
        img.filteringMode = .nearest
        super.init(texture: img, color: .clear, size: img.size())
        
        setAnchor()
        move(to: pos)
        isUserInteractionEnabled = true
    }
    
    private func setAnchor(point: CGPoint? = nil) {
        if let point = point {
            anchorPoint = point
        } else {
            let size = texture!.size()
            anchorPoint = CGPoint(
                x: gridWidth / size.width,
                y: (CGFloat(rect.ncol) * (gridHeight)) / (2 * size.height)
            )
        }
    }
    
    convenience init(named: String, rect: Rect, type: ObjectType) {
        let img = Object.getTexture(named: named, type: type)
        self.init(img: img, rect: rect, type: type)
        name = named
    }
    
    static private func getTexture(named: String, type: ObjectType, dir: Dir = .north) -> SKTexture{
        switch type {
        case .symetric:
            return SKTexture(imageNamed: named)
        case .semisymetric:
            if dir == .east || dir == .north {
                return SKTexture(imageNamed: "\(named)_east")
            }
            else {
                return SKTexture(imageNamed: "\(named)_west")
            }
        case .direction:
            return SKTexture(imageNamed: "\(named)_\(dir)")
        }
    }
    required    init?(coder aDecoder: NSCoder) {
        self.rect = Rect()
        self.type = .symetric

        super.init(coder: aDecoder)
    }
    
    // Checks if this object rect is interfering with other rects
    public func isOverlapping(with r: Rect) -> Bool {
        return rect.overlaps(rect: r)
    }
    public func isOverlapping(with obj: Object) -> Bool {
        return isOverlapping(with: obj.rect)
    }
    public func isOverlapping(with objects: [Object]?) -> Bool {
        if let objs = objects {
            for obj in objs {
                if isOverlapping(with: obj) { return true }
            }
        }
        return false
    }
    
    // Checks if this object rect is compleatly inside the other rect
    public func isContained(by r: Rect) -> Bool {
        return rect.contains(rect: r)
    }
    
    /** Moves this object delta steps from the current position */
    public func move(delta pos: Pos) {
        let dist = Int(gridHeight)
        let offset = CGPoint(
            x: pos.col * dist + pos.row * dist + dist,
            y: pos.row * dist/2 - pos.col * dist/2
        )
        
        rect.pos = Pos(col: rect.col + pos.col, row: rect.row + pos.row)
        zPosition += CGFloat(pos.col - pos.row)
        position.x = position.x + offset.x
        position.y = position.y + offset.y
        
        printObj()
    }
    
    /** Moves this object to the given position.
     This function first calculates the anchorpoint to be in the center of the leftmost square
     in the object texture, then calls move(delta:) to move it to the correct position.
     */
    public func move(to pos: Pos) {
        // Move to (0,0)
        position = CGPoint()
        position.x = -gridWidth * 4
        zPosition = 10
        self.pos = Pos(col: 0, row: 0)
        
        // Move to correct position
        move(delta: pos)
    }
    
    /** Helper funktion that displays color below the object.
     This is used to indicate status or range of placement. */
    public func displayRadius(color c: SKColor) {
        removeAllChildren()

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 20, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -10))
        path.addLine(to: CGPoint(x: -20, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 10))
        path.close()
        
        for col in 0..<rect.ncol {
            for row in 0..<rect.nrow {
                let radiusNode = SKShapeNode(path: path.cgPath)
                radiusNode.fillColor = c
                radiusNode.lineWidth = 1
                radiusNode.strokeColor = c
                radiusNode.zPosition = -1       // Based on current nodes z pos i think, this makes sure its always lower
                radiusNode.alpha = 0.5
                
                radiusNode.position.x += -gridWidth/2 + CGFloat(col)*gridWidth/2 + CGFloat(row)*gridWidth/2
                radiusNode.position.y +=  CGFloat(row)*gridHeight/2 + CGFloat(col)*gridHeight/2
                
                addChild(radiusNode)
            }
        }
        
    }
    public func removeRadius() {
        removeAllChildren()
    }
    
    public func interact(p: Person) {
        print("\(p.name ?? "person") interacted with \(name ?? "obj")")
    }
    
    public func printObj() {
        print("Object: \(String(describing: name)), " +
            "PosX: \(position.x), PosY: \(position.y). Rect: \(rect.toStr()), zPos: \(zPosition)")
    }
    
    public func rotate(to dir: Dir) {
        self.dir = dir
        texture = Object.getTexture(named: name!, type: type, dir: dir)
        setAnchor()
        move(to: pos)
    }
    public func rotateClockW() {
        var n = dir.rawValue + 1;
        if n == 4 { n = 0 }
        rotate(to: Dir(rawValue: n)!)
    }
    public func rotateAntiCW() {
        var n = dir.rawValue - 1;
        if n == -1 { n = 3 }
        rotate(to: Dir(rawValue: n)!)
    }
    
    /** Sets the right texture for the current dir. Assumes both texture and dir are correct */
    private func updateTexture() {
        let size = texture!.size().width / texture!.textureRect().width
        let xSquares = Int((size / 20).rounded())
        let length = rect.ncol >= rect.nrow ? rect.ncol : rect.nrow
        var imgRect: CGRect = CGRect()
        
        switch length+1 {
        case xSquares/2:
            let xRatio = Double(dir.rawValue).truncatingRemainder(dividingBy: 2)/4
            imgRect = CGRect(x: xRatio, y: 0, width: 0.5, height: 1)
        case xSquares/4:
            imgRect = CGRect(x: Double(dir.rawValue)/4, y: 0, width: 0.25, height: 1)
        default:
            imgRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        
        texture = SKTexture(rect: imgRect, in: texture!)
    }
    
    /** Override this if object should be placed next to something specific for example. */
    public func isCorrectlyPlaced(objs: [Object]) -> Bool {
        return true
    }
}
