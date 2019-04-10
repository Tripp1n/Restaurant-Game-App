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
    case chair
    case table
    case door
    case guest
    case waiter
    case other
}

public class Object: SKSpriteNode
{
    var rect: Rect          // Position and size of object in room-grid.
    var dir: Dir = .north   // Direction object is facing.
    var panStart: Pos?      // Nil unless user is moving the object. Represents pos when pan began.
    var radius: Int = 0     // How big of a range this object has. Usually 0.
    var type: ObjectType    // What type of object is it?

    public var width: Int {
        get {
            return rect.width
        }
        set {
            rect.width = newValue
        }
    }
    public var height: Int {
        get {
            return rect.height
        }
        set {
            rect.height = newValue
        }
    }
    
    // Create a new Object and move it to the correct spot
    init(img: SKTexture, rect: Rect, type: ObjectType = .other, anchor: CGPoint? = nil) {
        self.rect = rect
        self.type = type
        img.filteringMode = .nearest
        super.init(texture: img, color: .clear, size: img.size())
        
        // Set anchorpoint to ingame leftmost square center or keep the one you got assigned
        if anchor == nil {
            let size = texture!.size()
            anchorPoint = CGPoint(
                x: 1 / (CGFloat(width) + 1),
                y: CGFloat(height) / ((size.height / gridHeight) * 2)
            )
        } else {
            anchorPoint = anchor!
        }
        
        move(to: Pos(col: rect.col, row: rect.row))
        isUserInteractionEnabled = true
    }
    convenience init(imageNamed: String, rect: Rect, type: ObjectType = .other) {
        let img = TextureHandler.getTexture(from: SKTexture(imageNamed: imageNamed), rect: rect)
        self.init(img: img, rect: rect, type: type)
        name = imageNamed
    }
    convenience init(obj: Object) {
        self.init(img: obj.texture!, rect: obj.rect, type: obj.type, anchor: obj.anchorPoint)
    }
    required    init?(coder aDecoder: NSCoder) {
        self.rect = Rect()
        self.type = .other

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
        
        rect.setPos(row: rect.row + pos.row, col: rect.col + pos.col)
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
        position.x = -gridWidth * 4.5
        zPosition = 10
        rect.setPos(row: 0, col: 0)
        
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
        
        let radiusNode = SKShapeNode(path: path.cgPath)
        radiusNode.fillColor = c
        radiusNode.lineWidth = 1
        radiusNode.strokeColor = c
        radiusNode.zPosition = zPosition - 1
        radiusNode.alpha = 0.5
        
        addChild(radiusNode)
        
    }
    public func removeRadius() {
        removeAllChildren()
    }
    
    // Sets or gets pos.
    public func getPos() -> Pos {
        return rect.toPos()
    }
    
    public func interact(p: Person) {
        print("\(p.name ?? "person") interacted with \(name ?? "obj")")
    }
    
    // Clone this object to a new object
    public func clone() -> Object {
        return Object(obj: self)
    }
    public func printObj() {
        print("Object: \(String(describing: name)), " +
            "PosX: \(position.x), PosY: \(position.y). Rect: \(rect.toStr()), zPos: \(zPosition)")
    }
    
    public func rotate(to dir: Dir) {
        self.dir = dir
        updateTexture()
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
        let length = rect.width >= rect.height ? rect.width : rect.height
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
}
