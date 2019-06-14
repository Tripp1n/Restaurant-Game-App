//
//  lightingTestScene.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-10-21.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class lightningScene: SKScene {
    private var circle : SKShapeNode!
    private var box : SKRegion!
    private var torch : SKLightNode!
    private var sprite : SKSpriteNode!
    private var button : TextButton!
    
    override func didMove(to view: SKView) {
        circle = SKShapeNode(circleOfRadius: 100)
        sprite = SKSpriteNode(imageNamed: "Table")
        
        //button = TextButton("Hello", color: UIColor.red)
        
        //addChild(button)
        
        torch = SKLightNode()
        torch.categoryBitMask = 4
        //torch.shadowColor = UIColor.black
        //torch.ambientColor = UIColor.red
        //torch.lightColor = UIColor.green
        torch.falloff = 0.8
        torch.zPosition = 1
        addChild(torch)
        
        let background = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 1)
        
        self.backgroundColor = background
    }
    
    func test() {
        print("button clicked")
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
        let table = sprite.copy() as! SKSpriteNode
        table.position = pos
        table.shadowCastBitMask = 1
        table.shadowedBitMask = 1 << 1
        table.lightingBitMask = 1 << 2
        addChild(table)
        
        let candle = torch.copy() as! SKLightNode
        candle.position = pos
        
        addChild(circle)
        circle.position = pos
        circle.strokeColor = UIColor.red
        
        print("touched")
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        torch.position = pos
        circle.position = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        circle.removeFromParent()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }

}
