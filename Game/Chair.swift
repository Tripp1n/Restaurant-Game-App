//
//  Chair.swift
//  Game
//
//  Created by Torben Nordtorp on 2019-04-13.
//  Copyright © 2019 Torben Nordtorp. All rights reserved.
//

import SpriteKit

public class Chair: Object, Interactable {
    var person: Person?
    
    public func standUp() -> Person {
        person!.goal = nil
        removeAllChildren()
        let prs = person!
        self.person = nil
        return prs
    }
    
    func interacted(by prs: Person) -> Bool {
        if (person == nil) {
            person = prs
            
            // Remove from room
            prs.removeFromParent()
            
            // Adds the new sprite on top of chair texture
            let spriteNode = SKSpriteNode(imageNamed: "guest_sit_\(dir)")
            spriteNode.anchorPoint = anchorPoint
            spriteNode.position = CGPoint(x: 0,y: 0)
            spriteNode.zPosition = 0.1
            addChild(spriteNode)
            return true
        }
        return false
    }
    
    override public func isPlacementRecommended(room: Rect, objs: [Object]) -> Bool {
        let tables = objs.filter({$0 is Table})
        
        for table in tables {
            if let getToTableDir = table.rect.isNextTo(pos: pos) {
                if (getToTableDir == dir) { return true }
            }
        }
        return false
    }
    
    // Called when encoding
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rect, forKey: .rect)
        try container.encode(dir, forKey: .dir)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(person, forKey: .person)
    }
    
    // Called when decoding
    required convenience public init(from decoder: Decoder) throws {
        let container   = try decoder.container(keyedBy: CodingKeys.self)
        let svdRect     = try? container.decode(Rect.self      , forKey: .rect)
        let svdDir      = try? container.decode(Dir.self       , forKey: .dir)
        let svdName     = try? container.decode(String.self    , forKey: .name)
        let svdType     = try? container.decode(ObjectType.self, forKey: .type)
        let svdPerson   = try? container.decode(Person.self, forKey: .person)

        
        self.init(named: svdName!, rect: svdRect!, type: svdType!, dir: svdDir!)
        person = svdPerson
    }
}
