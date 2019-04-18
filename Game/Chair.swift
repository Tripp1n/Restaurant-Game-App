//
//  Chair.swift
//  Game
//
//  Created by Torben Nordtorp on 2019-04-13.
//  Copyright © 2019 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class Chair: Object {
    var person: Person?
    
    public func sitDown(prs: Person) {
        person = prs

        // Remove from room
        prs.removeFromParent()
        
        // Adds the new sprite on top of chair texture
        let spriteNode = SKSpriteNode(imageNamed: "guest_sit_\(dir)")
        spriteNode.anchorPoint = anchorPoint
        spriteNode.position = CGPoint(x: 0,y: 0)
        addChild(spriteNode)
    }
    
    public func standUp() -> Person {
        person!.goal = nil
        removeAllChildren()
        let prs = person!
        self.person = nil
        return prs
    }
    
    override public func isCorrectlyPlaced(objs: [Object]) -> Bool {
        let tables = objs.filter({$0 is Table})
        
        for table in tables {
            if let getToTableDir = table.rect.isNextTo(pos: pos) {
                if (getToTableDir == dir) { return true }
            }
        }
        return false
    }
}
