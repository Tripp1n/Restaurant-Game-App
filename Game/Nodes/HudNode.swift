//
//  HudNode.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-03-24.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class HudNode : SKNode {

    let label = SKLabelNode()
    let inventoryLabel = SKLabelNode(text: "Inventory")
    var appendIcon: SKSpriteNode!
    var cancelIcon: SKSpriteNode!
    var submitIcon: SKSpriteNode!
    var rotateIcon: SKSpriteNode!
    var shopIcon: SKSpriteNode!
    
    public var inventoryNode: SKSpriteNode = SKSpriteNode()

    public func setup(size: CGSize)
    {
        label.text = "Resturant game"
        label.fontSize = 30
        label.position = CGPoint(x: size.width / 2, y: size.height - 40)
        label.zPosition = 1
        
        // Icons
        appendIcon = prep(name: "add", size: size)
        shopIcon = prep(name: "shop", size: size)
        submitIcon = prep(name: "submit", size: size)
        cancelIcon = prep(name: "cancel", size: size)
        rotateIcon = prep(name: "rotate", size: size)
        
        cancelIcon.anchorPoint = CGPoint(x: 0, y: 1)
        cancelIcon.position = CGPoint(x: 10 , y: size.height - 10)
        rotateIcon.position = CGPoint(x: size.width - (20 + submitIcon.frame.width), y: size.height - 10)
        
        // Inventory
        inventoryNode = SKSpriteNode(color: .darkGray, size: CGSize(width: size.width, height: size.height/4))
        let n = inventoryNode
        n.anchorPoint = CGPoint(x: 0, y: 0)
        n.position = CGPoint(x: 0, y: 0)
        n.isUserInteractionEnabled = false
        
        inventoryLabel.color = .lightText
        inventoryLabel.fontName = "AvenirNext-Bold"
        inventoryLabel.fontSize = 20
        inventoryLabel.horizontalAlignmentMode = .left
        inventoryLabel.position = CGPoint(x: 10, y: size.height/4 - 20)
        inventoryLabel.zPosition = 1
        inventoryNode.addChild(inventoryLabel)
                
        addChild(appendIcon)
        addChild(label)
    }
    
    private func prep(name: String, size: CGSize) -> SKSpriteNode {
        let icon = SKSpriteNode(imageNamed: name)
        icon.position = CGPoint(x: size.width - 10, y: size.height - 10)
        icon.anchorPoint = CGPoint(x: 1, y: 1)
        icon.scale(to: CGSize(width: 40, height: 40))
        icon.colorBlendFactor = 0.5
        icon.color = .white
        icon.name = name
        icon.isUserInteractionEnabled = true
        return icon
    }
    
    public func NormalMode() {
        removeAllChildren()
        addChild(label)
        addChild(appendIcon)
    }
    
    public func ShopMode() {
        removeAllChildren()
        addChild(cancelIcon)
    }
    
    public func InventoryMode() {
        removeAllChildren()
        addChild(cancelIcon)
        addChild(shopIcon)
        addChild(inventoryNode)
        
        //var totalWidth: CGFloat = 0
        
        //for obj in gameScene.inventoryObjs
        //{
            /*
            let box = SKSpriteNode(color: .lightGray,
                                   size: CGSize(width: gameScene.table.frame.width + 20,
                                                height: gameScene.table.frame.height + 20))
            box.anchorPoint = CGPoint(x: 0, y: 0)
            box.position = CGPoint(x: totalWidth + 10 , y: 10)
            box.zPosition = 1
            
            inventoryNode.addChild(box)
            
            obj.anchorPoint = CGPoint(x: 0, y: 0)
            obj.position = CGPoint(
                x: totalWidth + 20,
                y: 20
            )
            obj.alpha = 1
            obj.removeFromParent()
            obj.zPosition = 2
            inventoryNode.addChild(obj)
            print("ops")
            
            totalWidth += box.size.width + 10
 */
        //}
    }
    
    public func editMode() {
        removeAllChildren()
        addChild(submitIcon)
        addChild(cancelIcon)
        addChild(rotateIcon)
    }
}
