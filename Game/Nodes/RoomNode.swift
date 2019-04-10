//
//  BackgroundNode.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-03-06.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

var maxRows = 9         // 0 to 8 is default allowed positions
var maxCols = 9         // 0 to 8 is default allowed positions

public class RoomNode : SKNode
{
    var objects = [Object]()   // All placed objects in the room
    private var currObj: Object?       // Obj that is currently being manipulated.
    private var currObjRef: Object?    // Reference to non visible but not yet deleted backup.
    
    private let grid: SKNode = SKNode()
    private let moveAudio: SKAudioNode = SKAudioNode(fileNamed: "click")
    
    /** Add an object to the room. This will both add and display the object. */
    public func add(obj: Object) {
        objects.append(obj)
        addChild(obj)
        update()
    }
    
    /** Remove an object from the room.
     This will both remove the object and stop displaying it.
     */
    public func remove(obj: Object) {
        objects.removeAll(where: { x in x === obj })
        obj.removeFromParent()
    }
    
    /** Update the goals of people and move them */
    private func update() {
        /*
        let guests = objects.filter({x in x is Person && x.type == .guest }) as! [Person]
        var goalLessGuests = guests.filter({$0.goal == nil})
        var emptyChairs = objects.filter({x in x.type == .chair && x.person == nil })
        
        while goalLessGuests.count > 0 && emptyChairs.count > 0 {
            goalLessGuests.first?.goal = emptyChairs.first
            goalLessGuests.removeFirst(); emptyChairs.removeFirst()
        }
        
        let people = objects.filter({$0 is Person}) as! [Person]
        for person in people {
            person.walk()
        }
 */
    }
    
    // CONSIDER MOVING THESE TO A OBJECT HANDLER CLASS OR SOMETHING
    /** Sets a new object that can be modified safely.
     Stops displaying the original node, and creates a copy that can be manipulated.
     */
    public func setCurrent(obj: Object) {
        obj.printObj()
        
        // Removes original and saves reference
        obj.removeFromParent()
        remove(obj: obj)
        currObjRef = obj
        currObjRef!.name = "ref"
        
        // Creates a new clone
        currObj = obj.clone()
        currObj!.name = "currObj"
        
        // Update posColor
        currObj!.displayRadius(color: posColor(obj))

        // Display clone
        addChild(currObj!)
    }
    public func hasCurrent() -> Bool {
        return currObj != nil
    }
    public func getCurrent() -> Object? {
        return currObj
    }
    public func getRef() -> Object? {
        return currObjRef
    }
    
    /** Replaces ref with current. */
    public func cfmCurrent() {
        currObj!.alpha = 1
        currObj!.removeFromParent()
        currObj!.removeRadius()
        add(obj: currObj!)
        currObj = nil
        currObjRef = nil
    }
    
    /** Resets the current obj to the way it was before. Returns if no current obj is defined. */
    public func cnlCurrent() {
        if currObj != nil {
            add(obj: currObjRef!)
            remove(obj: currObj!)
            currObj = nil
            currObjRef = nil
        }
    }
    
    /** Move the current object depending on how to pan vector looks. */
    public func moveCurrent(distance: CGPoint) {
        if let obj = currObj {
            let pos = obj.panStart!
            let xSteps = Int((distance.x / (gridWidth/2)).rounded())
            let ySteps = Int((distance.y / (gridHeight/2)).rounded())
            let rowStep = ( ySteps + xSteps)/2
            let colStep = (-ySteps + xSteps)/2
            let r = pos.row + rowStep
            let c = pos.col + colStep
            let curntRect = Rect(col: c, row: r, width: obj.width, height: obj.height)
            
            if isInsideRoom(at: curntRect) {
                if curntRect != obj.rect {
                    obj.move(to: curntRect.toPos())
                    obj.displayRadius(color: posColor(obj))
                    moveAudio.run(.play())
                }
            }
        }
    }
    
    /** Calculate the position color */
    private func posColor(_ obj: Object) -> SKColor {
        if (isUnoccupied(at: obj.rect)) {
            return .green
        } else {
            return .red
        }

    }
    // CONSIDER MOVING THESE TO A OBJECT HANDLER CLASS OR SOMETHING
    
    /** Checks if this rect is valid to place or display an object at. */
    public func isValid(at r: Rect) -> Bool {
        return isInsideRoom(at: r) && isUnoccupied(at: r)
    }
    
    /** Checks if this rect is a valid place to display the object at. */
    private func isInsideRoom(at rect: Rect) -> Bool {
        let c = rect.col
        let r = rect.row
        let w = rect.width
        let h = rect.height
        return r >= 0 && r+h-1 <= maxRows-1 && c >= 0 && c+w-1 <= maxCols-1
    }
    
    /** Checks if this rect is valid to place the object at. */
    private func isUnoccupied(at rect: Rect) -> Bool {
        for obj in objects {
            if obj.isOverlapping(with: rect) { return false }
        }
        return true
    }
    
    /** Checks if there is an object on the same spot. */
    public func isPlaceable(obj1: Object) -> Bool {
        for obj2 in objects {
            if obj2.isOverlapping(with: obj1) { return false }
        }
        return true
    }
    
    /** Gets object at a certain position. Not being used atm. */
    public func getAt(pos: Pos) -> Object? {
        for obj in objects {
            if obj.isOverlapping(with: pos.toRect()) { return obj }
        }
        return nil
    }
    
    public func containsObj(f: (Object) -> Bool ) -> Bool {
        return objects.contains(where: f)
    }
    
    public func setup() {
        xScale = 2
        yScale = 2
        position = CGPoint(x: frame.midX, y: frame.midY)
        
        moveAudio.autoplayLooped = false
        addChild(moveAudio)
        
        let floorSize = Int(gridWidth)*maxCols
        
        // add textures to ground
        for X in 0..<maxCols {
            for Y in 0..<maxRows {
                let floorTexture = SKTexture(imageNamed: "floorDark")
                floorTexture.filteringMode = SKTextureFilteringMode.nearest
                let floorTileNode = SKSpriteNode(texture: floorTexture)
                let size: Int = Int(floorTileNode.size.height)
                let sizeHalf: Int = Int(floorTileNode.size.height/2)
                
                let x: CGFloat =  CGFloat(size*(X+Y) - floorSize/2)
                let y: CGFloat = CGFloat(sizeHalf*(Y-X))
                floorTileNode.position = CGPoint(x: x+CGFloat(size), y: y)
                floorTileNode.zPosition = -1
                addChild(floorTileNode)
            }
        }
        
        // add textures to wall
        for n in 0..<maxCols {
            let wallTextureLeft = SKTexture(rect: CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(width: 0.5, height: 1.0)
            ), in: SKTexture(imageNamed: "wallBlackStone"))
            wallTextureLeft.filteringMode = SKTextureFilteringMode.nearest
            let wallTextureRight = SKTexture(rect: CGRect(
                origin: CGPoint(x: 0.5, y: 0),
                size: CGSize(width: 0.5, height: 1.0)
            ), in: SKTexture(imageNamed: "wallBlackStone"))
            wallTextureRight.filteringMode = SKTextureFilteringMode.nearest

            for n2 in 0..<2 {
                let wallNodeWest = SKSpriteNode(texture: wallTextureLeft)
                let wallNodeNorth = SKSpriteNode(texture: wallTextureRight)

                let heigth: Int = Int((wallNodeWest.size.height*3/4 - 1) * CGFloat(n2))
                let whSize: CGFloat = wallNodeWest.size.width/2
                let size: CGFloat = wallNodeWest.size.width/4
                
                wallNodeWest.position = CGPoint(
                    x: whSize - CGFloat(floorSize/2) + CGFloat(n*20),
                    y: whSize + CGFloat(n*10) + size + CGFloat(heigth)
                )
                addChild(wallNodeWest)

                
                wallNodeNorth.position = CGPoint(
                    x: whSize + CGFloat(n*20),
                    y: whSize + CGFloat((maxRows-n)*10) - size + 1 + CGFloat(heigth)
                )
                addChild(wallNodeNorth)
            }
        }
        
        // add grid
        grid.alpha = 0
        addChild(grid)
        
        let offsetX = Int(gridWidth/2)
        let offsetY = Int(gridHeight/2)
        
        for i in 0...Int(maxRows)
        {
            let path4 = CGMutablePath()
            path4.move(to: CGPoint(x: -floorSize/2 + offsetX*i, y: 0 - offsetY*i)) // Move to edge of diamond shape
            path4.addLine(to: CGPoint(x: 0 + offsetX*i, y: floorSize/4 - offsetY*i))
            let lineNode = SKShapeNode(path: path4)
            lineNode.strokeColor = .white
            lineNode.zPosition = 1
            lineNode.isUserInteractionEnabled = false
            grid.addChild(lineNode)
            
            let path5 = CGMutablePath()
            path5.move(to: CGPoint(x: -floorSize/2 + offsetX*i, y: 0 + offsetY*i)) // Move to edge of diamond shape
            path5.addLine(to: CGPoint(x: 0 + offsetX*i, y: -floorSize/4 + offsetY*i))
            let lineNode2 = SKShapeNode(path: path5)
            lineNode2.strokeColor = .white
            lineNode2.zPosition = 1
            lineNode2.isUserInteractionEnabled = false
            grid.addChild(lineNode2)
        }
    }
    
    public func hideGrid() {
        grid.alpha = 0
    }
    
    public func showGrid() {
        grid.alpha = 0.25
    }
    
    public func printCrntObjs() {
        currObjRef!.printObj()
        currObj!.printObj()
    }
}
