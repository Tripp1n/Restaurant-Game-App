//
//  Button.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-10-07.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class Button: SKNode {
    private var box : SKShapeNode
    private var label : SKLabelNode
    private var color : UIColor
    
    init(_ text: String, color: UIColor = UIColor.gray) {
        self.label = SKLabelNode(text: text)
        self.color = color
        self.box = SKShapeNode(rect: CGRect(x: 10, y: 10, width: 10, height: 10), cornerRadius: 10)
        super.init()
        
        position = CGPoint(x: 0, y: 0)
        addChild(box)
        addChild(label)
    }
    
    func clicked(at pos: CGPoint) {
        if pos == self.position {}
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
