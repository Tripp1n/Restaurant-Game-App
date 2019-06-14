//
//  ObjectContainer.swift
//  Game
//
//  Created by Torben Nordtorp on 2019-06-12.
//  Copyright © 2019 Torben Nordtorp. All rights reserved.
//

import GameKit

class ObjectContainer: SKNode {
    let object: Object
    
    init(obj: Object, backColor: UIColor, size: CGSize) {
        object = obj
        //object.position = CGPoint(x: 40, y: -20)
        object.position = CGPoint(x: 0, y: -gridHeight)
        object.zPosition = 0.1
        object.setScale(2)
        object.isUserInteractionEnabled = false
        
        let background = SKShapeNode(rectOf: size, cornerRadius: 5)
        background.fillColor = backColor
        
        super.init()
        
        addChild(background)
        addChild(object)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
