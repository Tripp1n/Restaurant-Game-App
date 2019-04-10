//
//  GameScene.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-03-06.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit
import UIKit

class RestaurantScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate
{
    // Variables
    public let floorSize: Int = 400
    private var currentTouch: CGPoint = CGPoint()
    private var lastUpdateTime: TimeInterval = 0
    private var touchedNode: SKNode!
    private var roomStartPos: CGPoint!
    
    var panRecognizer : UIPanGestureRecognizer!
    var pinchRecognizer : UIPinchGestureRecognizer!
    var holdRecognizer : UILongPressGestureRecognizer!
    var tapRecognizer : UITapGestureRecognizer!
    
    // Lists
    public var inventoryObjs = [Object]() // Objects not yet placed but bought
    public var placedObjs = [Object]() // Placed Objects
    public var shopObjs = [Object]() // All available buyable items
    
    // Nodes
    public let hudNode = HudNode()
    public let room = RoomNode()
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Setup Room
        room.setup()
        
        // Objects
        let test1 = Object(imageNamed: "tableBlack", rect: Rect(), type: .table)
        let test5 = Object(imageNamed: "tableWhite", rect: Rect(col: 4, row: 4), type: .table)
        let test2 = Object(imageNamed: "chairRed", rect: Rect(col: 4, row: 5), type: .chair)
        let test3 = Object(imageNamed: "chairRed", rect: Rect(col: 4, row: 6), type: .chair)
        let test4 = Object(imageNamed: "chairRed", rect: Rect(col: 0, row: 8), type: .chair)
        let person1 = Person(walkCycleNamed: "guest1", pos: Pos(col: 3, row: 3), type: .guest)
        let person2 = Person(walkCycleNamed: "waiter", pos: Pos(col: 6, row: 6), type: .waiter)
        
        room.add(obj: test1)
        room.add(obj: test2)
        room.add(obj: test3)
        room.add(obj: test4)
        room.add(obj: test5)
        room.add(obj: person1)
        room.add(obj: person2)
        //room.remove(obj: test2)
        
        person1.generatePath(to: person2, avoid: room.objects)
        
        // Makes the room start a
        addChild(room)
        
        // Setup Hud
        hudNode.setup(size: self.size)
        hudNode.zPosition = 100
        addChild(hudNode)
    }

    // Called after scene is presented
    override func didMove(to GameScene: SKView) {
        let audio: SKAudioNode = SKAudioNode(fileNamed: "Welcome")
        addChild(audio)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(pan:)))
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch(pinch:)))
        holdRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(hold(hold:)))
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(tap:)))
        
        holdRecognizer.delegate = self

        self.view!.addGestureRecognizer(holdRecognizer)
        self.view!.addGestureRecognizer(panRecognizer)
        self.view!.addGestureRecognizer(pinchRecognizer)
        self.view!.addGestureRecognizer(tapRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // Handle Tap, Hold, Gesture and Pan handler
    @objc func tap(tap: UITapGestureRecognizer) {
        // Convert to spritekit cordinates
        var touchLocation = tap.location(in: tap.view)
        touchLocation = self.convertPoint(fromView: touchLocation)
            
        // Check what node got touched
        let node = atPoint(touchLocation)
        
        // Check if node has userInteraction enabeld
        if !node.isUserInteractionEnabled { return }
        
        // If an object is Clicked
        if node.name == "add" {}
        else if node.name == "submit" || node.name == "cancel" {
            room.hideGrid()
            hudNode.NormalMode()
            
            if node.name == "submit" {
                room.cfmCurrent()
            }
            else if node.name == "cancel" {
                room.cnlCurrent()
            }
        }
        else if node.name == "rotate" {
            if let obj = room.getCurrent() {
                obj.rotateClockW()
            }
        }
        else if node.name == "shop" {
            /*let transition:SKTransition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            let scene:SKScene = ShopScene(size: view!.frame.size)
            self.view?.presentScene(scene, transition: transition)*/
        }
    }
    @objc func hold(hold: UILongPressGestureRecognizer) {
        if hold.state == .began {
            // Convert to spritekit cordinates
            var touchLocation = hold.location(in: hold.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            
            // Check what node got touched
            let node = atPoint(touchLocation)
            
            // Check if node has userInteraction enabeld
            if !node.isUserInteractionEnabled { return }
            
            if let new = node as? Object {
                if room.hasCurrent() {
                    let old = room.getCurrent()!
                    if old != new {
                        if room.isValid(at: old.rect) {
                            room.cfmCurrent()
                        } else {
                            room.cnlCurrent()
                        }
                        room.setCurrent(obj: new)
                    }
                }
                else {
                    room.setCurrent(obj: new)
                }
                
                room.showGrid()
                hudNode.editMode()
            }
        }
    }
    @objc func pinch(pinch: UIPinchGestureRecognizer) {
        if pinch.state == .changed {
            room.xScale *= pinch.scale
            room.yScale *= pinch.scale
            
            if  room.xScale > 3 {
                room.xScale = 3
                room.yScale = 3
            }
            
            if  room.xScale < 1/3 {
                room.xScale = 1/3
                room.yScale = 1/3
            }
            
            pinch.scale = 1
        }
    }
    @objc func pan(pan: UIPanGestureRecognizer) {
        if pan.state == .began
        {
            // Convert to spritekit cordinates
            var touchLocation = pan.location(in: pan.view)
            touchLocation = convertPoint(fromView: touchLocation)
            touchedNode = atPoint(touchLocation)
        }
        
        // Convert movment to spritekit cordinates
        var translation = pan.translation(in: pan.view!)
        translation = CGPoint(x: translation.x, y: -translation.y)
        
        // If touched node is the object that is currently manipulated.
        if let obj = touchedNode as? Object, let obj2 = room.getCurrent(), obj == obj2 {
            if pan.state == .began {
                obj.panStart = obj.getPos()
            } else if pan.state == .changed {
                if obj.panStart == nil { obj.panStart = obj.getPos() }
                
                // Scale movement to scale
                translation.x /= room.xScale
                translation.y /= room.yScale

                room.moveCurrent(distance: translation)
            } else if pan.state == .ended {
                obj.panStart = nil
            }
        // If not that object, move the room instead.
        } else {
            if pan.state == .began
            {
                roomStartPos = room.position
            }
            else if pan.state == .changed
            {
                room.position.x = roomStartPos.x + translation.x
                room.position.y = roomStartPos.y + translation.y
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize _lastUpdateTime if it has not already been
        if (lastUpdateTime == 0) {
            lastUpdateTime = currentTime
        }
        
        lastUpdateTime = currentTime
    }
}
