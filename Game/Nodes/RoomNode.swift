//
//  BackgroundNode.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-03-06.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

public class RoomNode : SKNode
{
    private let spawnRate = 10 // spawns one guest every x seconds
    var objects: [Object] = []
    public var roomRect = Rect(blc: 0, blr: 0, nc: 5, nr: 3)
               // All placed objects in the room
    private var guests = [Person]()     // All people in the room
    private var currObj: Object?        // ref to an object in objects
    
    // Save pos and dir in case they cancel.
    private var orgPos = Pos()
    private var orgDir = Dir.north
    
    private let grid: SKNode = SKNode()
    private let moveAudio: SKAudioNode = SKAudioNode(fileNamed: "click")
    
    var audio: SKAudioNode = SKAudioNode(fileNamed: "Welcome")
    
    public func setup(roomRect: Rect? = nil, floorTextureName: String = "floorDark") {
        addChild(audio)
        
        if let rect = roomRect { self.roomRect = rect}
        
        let debug = SKShapeNode(rectOf: CGSize(width: 2, height: 2))
        debug.fillColor = .green
        debug.strokeColor = .green
        debug.glowWidth = 0
        debug.zPosition = 100
        addChild(debug)
        
        // Variables?
        let ncol = self.roomRect.ncol
        let nrow = self.roomRect.nrow
        xScale = 2
        yScale = 2
        position.x = parent!.frame.midX
        position.y = parent!.frame.midY
        moveAudio.autoplayLooped = false
        addChild(moveAudio)
        let floorSize = Int(gridWidth)*ncol
        
        // Load and display objects from memory
        if let objs = load() {
            for object in objs {
                var obj = object
                print(obj.name!)
                if obj.name!.contains("chair") {
                    obj = Chair(named: obj.name!, rect: obj.rect, type: obj.type, dir: obj.dir)
                }
                else if obj.name!.contains("table") {
                    obj = Table(named: obj.name!, rect: obj.rect, type: obj.type, dir: obj.dir)
                }
                else if obj.name!.contains("door") {
                    obj = Door(named: obj.name!, rect: obj.rect, type: obj.type, dir: obj.dir)
                }
                addChild(obj)
                objects.append(obj)
            }
        }
        
        // Add textures to ground
        let floorTexture = SKTexture(imageNamed: floorTextureName)
        for X in 0..<ncol {
            for Y in 0..<nrow {
                let floorSquare = Object(img: floorTexture, rect: Rect(blc: X, blr: Y))
                floorSquare.zPosition = -1
                addChild(floorSquare)
            }
        }
        
        // Add the grid
        grid.alpha = 0
        addChild(grid)
        
        let offsetX = Int(gridWidth/2)
        let offsetY = Int(gridHeight/2)
        
        for i in 0...Int(ncol) {
            let path4 = CGMutablePath()
            // Move to edge of diamond shape
            path4.move(to: CGPoint(x: offsetX*(i-1), y: -offsetY*i))
            path4.addLine(to: CGPoint(x: offsetX*(i-1) + offsetX*(nrow-ncol) + floorSize/2,
                                      y: floorSize/4 - offsetY*i + offsetY*(nrow-ncol)))
            let lineNode = SKShapeNode(path: path4)
            lineNode.strokeColor = .white
            lineNode.zPosition = 1
            lineNode.isAntialiased = false
            lineNode.isUserInteractionEnabled = false
            grid.addChild(lineNode)
        }
        
        for i in 0...Int(nrow) {
            let path5 = CGMutablePath()
            path5.move(to: CGPoint(x: offsetX*(i-1), y: offsetY*i)) // Move to edge of diamond shape
            path5.addLine(to: CGPoint(x: offsetX*(i-1) + floorSize/2, y: -floorSize/4 + offsetY*i))
            let lineNode2 = SKShapeNode(path: path5)
            lineNode2.strokeColor = .white
            lineNode2.zPosition = 1
            lineNode2.isAntialiased = false
            lineNode2.isUserInteractionEnabled = false
            grid.addChild(lineNode2)
        }
        
        // Create a function that is repetedly called every second
         _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    /** Add an object to the room. This will both add and display the object. */
    public func add(obj: Object) {
        objects.append(obj)
        addChild(obj)
        update()
        save()
    }
    
    public func spawnPerson(at door: Door) {
        let prs = Person(walkCycleNamed: "guest1", door: door)
        prs.alpha = 0
        
        addChild(prs)
        guests.append(prs)

        door.texture = Object.getTexture(named: "door_open", type: .directional, dir: door.dir)
        prs.run(.fadeIn(withDuration: 0.5)) {
            door.texture = Object.getTexture(named: "door_closed", type: .directional, dir: door.dir)
        }
    }
    
    /** Remove an object from the room.
     This will both remove the object and stop displaying it.
     */
    public func remove(obj: Object) {
        objects.removeAll(where: { x in x === obj })
        obj.removeFromParent()
    }
    
    /** Update the goals of people and move them */
    @objc private func update() {
        let doors = objects.filter({
            if let obj = $0 as? Door {
                let val = obj.isPlacementAllowed(room: roomRect, objs: objects)
                return val
            }
            return false
        })
        let chairs = objects.filter({
            $0 is Chair && $0.isPlacementRecommended(room: roomRect, objs: objects)
        })
        var emptyChairs = chairs.filter({
            for guest in guests.filter({$0.goal != nil}) {
                if $0 == guest.goal { return false }
            }
            return true
        })
        
        // Update the goals of guests
        for guest in guests.filter({$0.goal == nil}) {
            switch guest.desire {
            case .sit:
                if !emptyChairs.isEmpty {
                    let doorZ = doors.first!.zPosition
                    let guestZ = guest.zPosition
                    guest.walk(to: emptyChairs.removeFirst(), avoid: objects, room: roomRect)
                } else {
                    guest.desire = .leave
                }
            case .leave:
                if !doors.isEmpty {
                    guest.walk(to: doors.randomElement()!, avoid: objects, room: roomRect)
                }
            case .vanish:
                guests.removeAll(where: {$0 == guest})
            default:
                break // They are already sitting at an table and waiting to order, eat, or pay.
            }
        }
        
        // Spawn new guests
        if Int.random(in: 1...spawnRate) == 1 {
            if doors.count > 0 {
                if emptyChairs.count > 0 {
                    spawnPerson(at: doors.randomElement() as! Door)
                }
            } else {
                // TODO: Send warning to player that there are no doors.
            }
        }
        
        print("Guest's goals updated")
    }
    
    // CONSIDER MOVING THESE TO A OBJECT HANDLER CLASS OR SOMETHING
    /** Sets a new object that can be modified safely.
     Stops displaying the original node, and creates a copy that can be manipulated.
     */
    public func setCurrent(obj: Object) {
        orgDir = obj.dir
        orgPos = obj.pos
        currObj = obj
        objects.removeAll(where: { x in x === obj })
        obj.displayRadius(color: posColor(obj))
        obj.zPosition += 0.1
    }
    public func hasCurrent() -> Bool {
        return currObj != nil
    }
    public func getCurrent() -> Object? {
        return currObj
    }
    
    /** Replaces ref with current. */
    public func cfmCurrent() {
        if currObj != nil {
            currObj!.removeRadius()
            currObj!.zPosition -= 0.1
            objects.append(currObj!)
            currObj = nil
            save()
        }
    }
    
    /** Resets the current obj to the way it was before. Returns if no current obj is defined. */
    public func cnlCurrent() {
        if currObj != nil {
            currObj!.dir = orgDir
            currObj!.move(to: orgPos)
            cfmCurrent()
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
            let curntRect = Rect(blc: c, blr: r, nc: obj.width, nr: obj.height)
            
            if isInside(at: curntRect) {
                if curntRect != obj.rect {
                    obj.move(to: curntRect.pos)
                    obj.displayRadius(color: posColor(obj))
                    moveAudio.run(.play())
                }
            }
        }
    }
    
    public func rotateRoomRight() {
        let rows = roomRect.nrow
        roomRect.nrow = roomRect.ncol
        roomRect.ncol = rows
    }
    
    public func rotateRoomLeft() {
        let rows = roomRect.nrow
        roomRect.nrow = roomRect.ncol
        roomRect.ncol = rows
    }
    
    public func rotateCurrent() {
        if let obj = currObj {
            obj.rotateClockW()
            obj.displayRadius(color: posColor(obj))
        }
    }
    
    /** Calculate the position color */
    private func posColor(_ obj: Object) -> SKColor {
        if (!obj.isPlacementAllowed(room: roomRect, objs: objects)) {
            return .red
        } else if (!obj.isPlacementRecommended(room: roomRect, objs: objects)) {
            return .yellow
        } else {
            return .green
        }
    }
    
    /** Checks if this rect is valid to place or display an object at. */
    public func isValid(_ obj: Object) -> Bool {
        return isInside(at: obj.rect) && obj.isPlacementAllowed(room: roomRect, objs: objects)
    }
    
    /** Checks if this rect is a valid place to display the object at. */
    public func isInside(at rect: Rect) -> Bool {
        return roomRect.contains(rect)
    }
    
    /// Check if given rect is touching the edge of the room.
    private func isAtEdge(r: Rect) -> Bool {
        return !r.getOverlappingEdges(in: roomRect).isEmpty
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
    
    public func hideGrid() {
        grid.alpha = 0
    }
    
    public func showGrid() {
        grid.alpha = 1
    }
    
    public func printCrntObjs() {
        currObj!.printObj()
    }
    
    
    //MARK: Persistence
    
    func save() {
        // Gets document/objects directory
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url.appendPathComponent("objects")
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(objects)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func load() -> [Object]? {
        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        url.appendPathComponent("objects")
        
        if !FileManager.default.fileExists(atPath: url.path) {
            return nil
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            do {
                return try decoder.decode([Object].self, from: data)
            } catch {
                fatalError(error.localizedDescription)
            }
        } else {
            fatalError("No data at \(url.path)!")
        }
    }
}

/*
 // add textures to wall
 for n in 0..<ncol {
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
 y: whSize + CGFloat((nrow-n)*10) - size + 1 + CGFloat(heigth)
 )
 addChild(wallNodeNorth)
 }
 }*/
