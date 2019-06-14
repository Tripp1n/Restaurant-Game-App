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

public class Object: SKSpriteNode, Codable {
    var rect: Rect          // Position and size of object in room-grid.
    var dir: Dir = .north   // Direction object is facing.
    var panStart: Pos?      // Wtf is this get that shit away from me. Nil unless user is moving the object. Represents pos when pan began.
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
    init(img: SKTexture, rect: Rect, type: ObjectType = .symetric, isInteractable: Bool = false) {
        self.rect = rect
        self.type = type
        img.filteringMode = .nearest
        
        super.init(texture: img, color: .clear, size: img.size())
        
        setAnchor()
        move(to: pos)
        
        
        let debug = SKShapeNode(rectOf: CGSize(width: 2, height: 2))
        debug.fillColor = .red
        debug.strokeColor = .red
        debug.glowWidth = 0
        debug.zPosition = 0.1
        addChild(debug)
        
        isUserInteractionEnabled = isInteractable
    }
    
    convenience init(named: String, rect: Rect, type: ObjectType, dir: Dir = .north) {
        let img = Object.getTexture(named: named, type: type, dir: dir)
        self.init(img: img, rect: rect, type: type, isInteractable: true)
        name = named
        self.dir = dir
    }
    
    func setAnchor() {
        let size = texture!.size()
        
        var n = CGFloat(rect.ncol - rect.nrow)
        if n < 1 { n = 1 }
        let a = CGPoint(
            x: 1/CGFloat(rect.nrow+1),
            y: (gridHeight/2)*n / size.height
        )
        anchorPoint = a
    }
    
    static public func getTexture(named: String, type: ObjectType, dir: Dir = .north) -> SKTexture {
        let texture: SKTexture
        switch type {
        case .symetric:
            texture =  SKTexture(imageNamed: named)
        case .directional:
            texture = SKTexture(imageNamed: "\(named)_\(dir)")
        }
        texture.filteringMode = .nearest
        return texture
    }
    
    // Checks if this object rect is interfering with other rects
    public func isOverlapping(with r: Rect) -> Bool {
        return rect.overlaps(r)
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
        return rect.contains(r)
    }
    
    /** Moves this object delta steps from the current position */
    public func move(delta pos: Pos) {
        let dist = Int(gridHeight)
        let offset = CGPoint(
            x: pos.col*dist + pos.row*dist, // TODO: REMOVE + dist and readjust grid
            y: pos.row * dist/2 - pos.col * dist/2
        )
        
        rect.pos = Pos(c: rect.col + pos.col, r: rect.row + pos.row)
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
        // Move to (0,0) and reset obj
        position = CGPoint()
        zPosition = 10
        self.pos = Pos(c: 0, r: 0)
        
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
                radiusNode.zPosition = -0.01    // Based on current nodes z pos i think, this makes sure its always lower
                radiusNode.alpha = 0.5
                
                radiusNode.position.x += CGFloat(col)*gridWidth/2 + CGFloat(row)*gridWidth/2
                radiusNode.position.y += CGFloat(row)*gridHeight/2 - CGFloat(col)*gridHeight/2
                
                addChild(radiusNode)
            }
        }
    }
    public func removeRadius() {
        removeAllChildren()
    }
    
    public func printObj() {
        print("Object: \(String(describing: name)), " +
            "PosX: \(position.x), PosY: \(position.y). Rect: \(rect.toStr()), zPos: \(zPosition)")
    }
    
    public func rotate(to dir: Dir) {
        self.dir = dir
        texture = Object.getTexture(named: name!, type: type, dir: dir)
        let temp = rect.ncol
        rect.ncol = rect.nrow
        rect.nrow = temp
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
    
    /** Override this if object is not allowed to be placed on certain spots. */
    public func isPlacementAllowed(room: Rect, objs: [Object]) -> Bool {
        for obj in objs {
            if self != obj && obj.rect.overlaps(rect) { return false }
        }
        return true
    }
    
    /** Override this if object only works if placed next to a specific object for example. */
    public func isPlacementRecommended(room: Rect, objs: [Object]) -> Bool {
        return true
    }
    
    //MARK: Archiving Paths
 
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("objects")
    
    
    
    // MARK: -- REQUIRED TO MAKE CLASS ENCODABLE --
    
    // Used for encoding somehow
    enum CodingKeys: String, CodingKey {
        case rect
        case dir
        case type
        case name
        case person
    }
    
    // Called when encoding
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rect, forKey: .rect)
        try container.encode(dir, forKey: .dir)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
    }
    
    // Called when decoding
    required convenience public init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        let svdRect     = try? container.decode(Rect.self      , forKey: .rect)
        let svdDir      = try? container.decode(Dir.self       , forKey: .dir)
        let svdName     = try? container.decode(String.self    , forKey: .name)
        let svdType     = try? container.decode(ObjectType.self, forKey: .type)
        
        self.init(named: svdName!, rect: svdRect!, type: svdType!, dir: svdDir!)
    }
    
    // MARK: -- REQUIRED BUT UNUSED --
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}
