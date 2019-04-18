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
    
    let act = SKAction.scale(to: 1.2, duration: 0.1)
    let act2 = SKAction.scale(to: 1, duration: 0.1)
    
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
        let test1 = Table(named: "tableBlack", rect: Rect(), type: .symetric)
        let test5 = Table(named: "tableWhite", rect: Rect(c: 4, r: 4), type: .symetric)
        let door1 = Door(named: "door_closed", rect: Rect(c: 2, r: 2, nc: 1, nr: 2), type: .semisymetric)
        let test2 = Chair(named: "chair", rect: Rect(c: 4, r: 5), type: .direction)
        let test3 = Chair(named: "chair", rect: Rect(c: 4, r: 6), type: .direction)
        let test4 = Chair(named: "chair", rect: Rect(c: 0, r: 8), type: .direction)
        let test6 = Chair(named: "chair", rect: Rect(c: 3, r: 8), type: .direction)
        
        let person1 = Person(walkCycleNamed: "guest1", pos: Pos(col: 3, row: 3))
        let person2 = Person(walkCycleNamed: "guest1", pos: Pos(col: 0, row: 0))
        let person3 = Person(walkCycleNamed: "guest1", pos: Pos(col: 7, row: 7))
        
        /*
        let light = SKLightNode()
        light.isEnabled = true
        light.categoryBitMask = 1
        let light2 = SKLightNode()
        light2.isEnabled = true
        light2.categoryBitMask = 1
        
        test5.shadowCastBitMask = 1
        test2.shadowedBitMask = 1
        test3.shadowCastBitMask = 1
        test6.lightingBitMask = 1

        test1.addChild(light)
        test4.addChild(light2)*/
        
        room.add(obj: test1)
        room.add(obj: test2)
        room.add(obj: test3)
        room.add(obj: test4)
        room.add(obj: test5)
        room.add(obj: test6)
        
        room.add(obj: door1)
        
        room.spawn(prs: person1)
        room.spawn(prs: person2)
        room.spawn(prs: person3)
        
        
        /** Cool, men testa att aligna den med gridden först.*/
        /*
        let sourcePositions: [float2] = [
            float2(0, 1),   float2(0.5, 1),   float2(1, 1),
            float2(0, 0.5), float2(0.5, 0.5), float2(1, 0.5),
            float2(0, 0),   float2(0, 0),   float2(1, 0)
        ]
	
        let destinationPositions: [float2] = [
            float2(0.1, 0.9),   float2(0.5, 0.9),   float2(0.9, 0.9),
            float2(0, 0.5), float2(0.5, 0.5), float2(1, 0.5),
            float2(-0.1, 0.1),   float2(0.5, 0.1),   float2(1.1, 0.1)
        ]
        let warpGeometryGrid = SKWarpGeometryGrid(columns: 2,
                                                  rows: 2,
                                                  sourcePositions: sourcePositions,
                                                  destinationPositions: destinationPositions)
        let node = SKEffectNode()
        node.warpGeometry = warpGeometryGrid
        
        node.addChild(room)

        addChild(node)
        
        let node = SKTransformNode()
        node.addChild(room)
        node.setEulerAngles(float3(0, 1, 1))*/

        addChild(room)
        
        // Setup Hud
        hudNode.setup(size: self.size)
        hudNode.zPosition = 100
        addChild(hudNode)
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
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
            room.rotateCurrent()
        }
        else if node.name == "shop" {
            /*let transition:SKTransition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            let scene:SKScene = ShopScene(size: view!.frame.size)
            self.view?.presentScene(scene, transition: transition)*/
        }
    }
    @objc func hold(hold: UILongPressGestureRecognizer) {
        
        if let obj = wasObjectTouched(hold) {
            if hold.state == .began {
                
                if let chair = obj as? Chair {
                    if chair.person != nil {
                        let person = chair.standUp()
                        room.addChild(person)
                        
                    }
                }
                
                if obj is Person { return }
                
                if room.hasCurrent() {
                    let old = room.getCurrent()!
                    if old != obj {
                        if room.isValid(at: old.rect) { room.cfmCurrent() }
                        else { room.cnlCurrent() }
                        room.setCurrent(obj: obj)
                    }
                }
                else { room.setCurrent(obj: obj) }
                
                room.showGrid()
                hudNode.editMode()
                
                // If an object is held
                obj.run(act)
            }
            else if hold.state == .ended {
                obj.run(act2)
            }
        }
        
        // Convert to spritekit cordinates
        var touchLocation = hold.location(in: hold.view)
        touchLocation = self.convertPoint(fromView: touchLocation)
        
        // Check what node got touched
        let node = atPoint(touchLocation)
        
        if hold.state == .began {
            
            // Check if node has userInteraction enabeld
            if !node.isUserInteractionEnabled { return }
            
            if let new = node as? Object {
                if room.hasCurrent() {
                    let old = room.getCurrent()!
                    if old != new {
                        if room.isValid(at: old.rect) { room.cfmCurrent() }
                        else { room.cnlCurrent() }
                        room.setCurrent(obj: new)
                    }
                }
                else { room.setCurrent(obj: new) }
                
                room.showGrid()
                hudNode.editMode()
                
                // If an object is held
                new.run(act)
            }

        }
        else if hold.state == .ended {
            // If an object is held
            if let obj = node as? Object {
                obj.run(act2)
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
            
            // If an object is held
            if let obj = touchedNode as? Object {
                obj.run(act)
            }
        }
        
        if pan.state == .ended {
            // If an object is let go
            if let obj = touchedNode as? Object {
                obj.run(act2)
            }
        }
        
        // Convert movment to spritekit cordinates
        var translation = pan.translation(in: pan.view!)
        translation = CGPoint(x: translation.x, y: -translation.y)
        
        // If touched node is the object that is currently manipulated.
        if let obj = touchedNode as? Object, let obj2 = room.getCurrent(), obj == obj2 {
            if pan.state == .began {
                obj.panStart = obj.pos
            } else if pan.state == .changed {
                if obj.panStart == nil { obj.panStart = obj.pos }
                
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
    
    private func wasObjectTouched(_ recognizer: UIGestureRecognizer) -> Object? {
        // Convert to spritekit cordinates
        var touchLocation = recognizer.location(in: recognizer.view)
        touchLocation = self.convertPoint(fromView: touchLocation)
        
        // Check what node got touched
        let node = atPoint(touchLocation)
        
        var potObj = node as? Object
        
        if potObj == nil {
            potObj = node.parent as? Object
        }
        
        // Check if node has userInteraction enabeld
        if potObj != nil {
            if !potObj!.isUserInteractionEnabled { return nil }
        }
        
        return potObj
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize _lastUpdateTime if it has not already been
        if (lastUpdateTime == 0) {
            lastUpdateTime = currentTime
        }
        
        lastUpdateTime = currentTime
    }
}
