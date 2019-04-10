//
//  TableNode.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-04-06.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//
/*
import SpriteKit

enum tableError: Error {
    case notEnoughChairs
}

class TableNode: Object {
    
    var chair1: Person? = nil
    var chair2: Person? = nil
    
    var table: SKTexture!
    var chairF: SKTexture!
    var chairB: SKTexture!
    var personF: SKTexture!
    var personB: SKTexture!
    
    var nodeTree = SKNode()
    var view = SKView()
    
    // Inicialize
    init(gameScene: GameScene, table: SKTexture, chairF: SKTexture, chairB: SKTexture, width: Int, height: Int, price: Int) {
        
        super.init(gameScene: gameScene, texture: table, width: width, height: height, price: price)

        self.table = table
        self.chairF = chairF
        self.chairB = chairB
        
        let one = SKSpriteNode(texture: self.chairB)
        let two = SKSpriteNode(texture: self.table)
        let three = SKSpriteNode(texture:self.chairF)
        
        nodeTree.addChild(one)
        nodeTree.addChild(two)
        nodeTree.addChild(three)

        if let texture = view.texture(from: nodeTree) {
            self.texture = texture
        }

        // THIS CAN BE USED IN PERSON CLASS let two = SKTexture(rect: <#T##CGRect#>, in: <#T##SKTexture#>)
    }
    /*
    // Called when someone sits down at the table
    func used(by person: Person) {
        if chair1 == nil {
            chair1 = person
            nodeTree.addChild(SKSpriteNode(texture: gameScene.personB))
        } else if chair2 == nil {
            chair2 = person
            nodeTree.addChild(SKSpriteNode(texture: gameScene.personF))
        } else {
            print("im to dumb for error handeling")
        }
        
        if let texture = view.texture(from: nodeTree) {
            self.texture = texture
        }
    }
 */
    
    // I don't know why this has to be here
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //COPY
    /*
    convenience init(obj: TableNode) {
        self.init(gameScene: gameScene!, table: obj.texture!, chairF: obj.chairF, chairB: obj.chairB, width: obj.width, height: obj.height, price: obj.price)
    }
    
    override public func copy() -> Any {
        let obj = TableNode(obj: self)
        return obj
    }*/
}
*/
