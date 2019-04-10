//
//  ShopObj.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-10-21.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class ShopObj: SKNode {
    var obj: Object!
    var price: Int!

    func setup(obj: Object, price: Int) {
        
        obj.xScale = 2
        obj.yScale = 2
        let label = SKLabelNode(text: String(price) + "$")
        label.position.y = obj.frame.height + 10 
        obj.addChild(label)
        addChild(obj)
    }
}
