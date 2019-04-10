//
//  DoorNode.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-04-04.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//
/*
import SpriteKit

class DoorNode: Object {
    
    public var closedTexture: SKTexture!
    public var openTexture: SKTexture?
    
    // Inicialize
    init(gameScene: GameScene, closedTexture: SKTexture?, openTexture: SKTexture?, width: Int, height: Int, price: Int) {
        super.init(gameScene: gameScene, texture: closedTexture!, width: width, height: height, price: price)
        self.closedTexture = closedTexture
        self.openTexture = openTexture
        self.isSolid = false
    }
    
    override func CanBePlaced() {
        
        // Check if object can be placed here
        super.CanBePlaced()
        /*
        // Check if object is touching the wall
        let colMax = gameScene.grid.gridWidth - 1
        if (!isFlipped && rect.row == 0) || (isFlipped && rect.col == colMax) {
            Placeable(bool: true)
        } else {
            Placeable(bool: false)
        }
 */
    }
    
    // I don't know why this has to be here
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /*
    // Allow copying
    convenience init(obj: DoorNode) {
        self.init(gameScene: gameScene, closedTexture: obj.closedTexture!, openTexture: obj.openTexture, width: obj.width, height: obj.height, price: obj.price)
    }
    
    override public func copy() -> Any {
        let obj = DoorNode(obj: self)
        return obj
    }*/
}
*/
