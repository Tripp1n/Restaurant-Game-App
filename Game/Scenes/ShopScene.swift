//
//  ShopScene.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-10-06.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class ShopScene: SKScene {
    
    let hudNode = HudNode()
    var scrollView: SwiftySKScrollView!
    let moveableNode = SKNode()
    let label1 = SKLabelNode(text: "SHOP")
    
    // Init
    override func sceneDidLoad() {
        label1.position.y = self.frame.maxY - label1.frame.height - 10
        label1.position.x = self.frame.midX
        
        hudNode.setup(size: size)
        hudNode.ShopMode()
        
        for index in 0..<gameScene.shopObjs.count
        {
            let box = SKShapeNode(rect: CGRect(x: 0, y: 0, width: frame.midX - 15, height: (frame.height-40)/5),
                                  cornerRadius: 5)
            box.fillColor = .gray
            box.name = "box"
            box.position = CGPoint(x: 10 + (CGFloat(index % 2)) * frame.midX,
                                   y: frame.height - (frame.height + 120)/5*(ceil(CGFloat((index+2)/2))) - 20)
            
            let obj = gameScene.shopObjs[index]
            obj.position.y = obj.frame.height / 2 + 20
            obj.position.x = obj.frame.width / 2
            obj.anchorPoint = CGPoint(x: 0.5,y: 0.5)
            obj.name = "obj"
            obj.isUserInteractionEnabled = true
            box.addChild(obj)
            
            let btn = SKShapeNode(rect: CGRect(x: 20, y: -15, width: frame.width/2 - 60, height: frame.height/20),
                                  cornerRadius: 20)
            btn.name = "btn" + String(index)
            btn.isUserInteractionEnabled = true
            btn.fillColor = .gray
            /*if gameScene.money >= obj.price {
                btn.fillColor = .green
            }*/
            /*
            let label = SKLabelNode(text: String(obj.price) + "$")
            label.horizontalAlignmentMode = .center
            label.fontColor = .red
            label.fontName = "CourierNewPS-BoldMT"
            label.zPosition = 20
            label.position.x = frame.midX/2 - 10
            label.position.y = -5
            label.fontSize = 18
            label.name = "label"
            label.isUserInteractionEnabled = true
            btn.addChild(label)*/
            
            box.addChild(btn)
            moveableNode.addChild(box)
        }
    }
    
    // Called after scene is presented
    override func didMove(to GameScene: SKView)
    {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tap(tap:)))
        self.view!.addGestureRecognizer(tapRecognizer)
        
        scrollView = SwiftySKScrollView(
            frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height),
            moveableNode: moveableNode,
            direction: SwiftySKScrollView.ScrollDirection.vertical)
        scrollView.contentSize = CGSize(width: self.frame.size.width, height: self.frame.size.height * 2)
        
        view?.addSubview(scrollView)
        addChild(hudNode)
        addChild(moveableNode)
        addChild(label1)
    }
    
    override func willMove(from view: SKView) {
        scrollView?.removeFromSuperview()
        scrollView = nil // nil out reference to deallocate properly
        moveableNode.removeAllChildren()
    }
    
    @objc func tap(tap: UITapGestureRecognizer) {
        
        // Convert to spritekit cordinates
        var touchLocation = tap.location(in: tap.view)
        touchLocation = self.convertPoint(fromView: touchLocation)
        
        // Check what node got touched
        var node = atPoint(touchLocation)
        
        // Check if node has userInteraction enabeld
        if !node.isUserInteractionEnabled { return }
        
        // If an object is Clicked
        if node.name == "cancel"
        {
            let transition:SKTransition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
            let scene:SKScene = gameScene
            self.view?.presentScene(scene, transition: transition)
        }
        else if node.name!.contains("btn") || node.name!.contains("label") {
            if node.name!.contains("label") {
                node = node.parent!
            }
            print(node.name!)
            let index: Int = Int(String(node.name!.dropFirst(3)))!

            print(index)

            // Buy the obj
            //let obj = gameScene.shopObjs[index]

            /*if gameScene.money >= obj.price {
                gameScene.money -= obj.price
                gameScene.inventoryObjs.append(obj)
                print("bougth " + obj.name!)
            }
            else  {
                print("can't afford " + obj.name!)
            }*/

        }
    }
}
