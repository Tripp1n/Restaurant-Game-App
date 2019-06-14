//
//  HudNode.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-03-24.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class HudNode: SKNode {
    var roomNode: RoomNode!
    
    let infoNode = SKNode()
    let settingsNode = SKNode()
    let inventoryNode = SKNode()
    
    let lblmoney = SKLabelNode(fontNamed: "Menlo-Bold")
    let lbldebt = SKLabelNode(fontNamed: "Menlo-Bold")
    let topBar = SKShapeNode()
    let inventoryLabel = SKLabelNode(text: "Inventory")
    var appendIcon: SKSpriteNode!
    var cancelIcon: SKSpriteNode!
    var submitIcon: SKSpriteNode!
    var rotateIcon: SKSpriteNode!
    var shopIcon: SKSpriteNode!
    
    public func setMoney(_ money: Int) {
        lblmoney.text = "Current money: \(money) $"
    }
    
    public func setDebt(_ money: Int) {
        lbldebt.text = "Weekly payment: -\(money) $"
    }
    
    public func setup(size: CGSize, room: RoomNode) {
        roomNode = room
        
        // -- Info bar --
        let topBar = SKShapeNode(rect: CGRect(x: 0, y: Int(size.height), width: Int(size.width), height: -40))
        topBar.fillColor = .lightGray
        topBar.strokeColor = .white
        
        let moneyBox = SKShapeNode(rect: CGRect(x: Int(size.width/3), y: Int(size.height+10-60), width: Int(size.width/3), height: 70), cornerRadius: 10)
        moneyBox.strokeColor = .white
        moneyBox.fillColor = .darkGray
        
        lblmoney.fontSize = 16
        lblmoney.position = CGPoint(x: size.width / 2, y: size.height - 20)
        lblmoney.zPosition = 1
        lblmoney.fontColor = .green
        
        lbldebt.fontSize = 12
        lbldebt.position = CGPoint(x: size.width / 2, y: size.height - 40)
        lbldebt.zPosition = 1
        lbldebt.fontColor = .yellow
        
        setMoney(400)
        setDebt(29)
        
        moneyBox.addChild(lblmoney)
        moneyBox.addChild(lbldebt)
        
        infoNode.addChild(topBar)
        infoNode.addChild(moneyBox)
        
        
        // -- Setting column on left hand side --
        let setting = IconButton(onTexture: "settings", offTexture: "settings", isOn: true,
                                 onClickOn: {}, onClickOff: {})
        let sound   = IconButton(onTexture: "volume_on", offTexture: "volume_off", isOn: true,
                                 onClickOn: {
                                    room.audio.run(.pause())},
                                 onClickOff: {
                                    room.audio.run(.play())})
        let grid   = IconButton(onTexture: "grid_on", offTexture: "grid_off", isOn: false,
                                onClickOn: {
                                    room.hideGrid()},
                                onClickOff: {
                                    room.showGrid()})
        setting.anchorPoint = CGPoint(x: 0, y: 1)
        setting.position = CGPoint(x: 10, y: size.height - 60)
        sound.anchorPoint = CGPoint(x: 0, y: 1)
        sound.position = CGPoint(x: 10, y: size.height - 100)
        grid.anchorPoint = CGPoint(x: 0, y: 1)
        grid.position = CGPoint(x: 10, y: size.height - 140)
        
        settingsNode.addChild(setting)
        settingsNode.addChild(sound)
        settingsNode.addChild(grid)

        // -- Inventory Node --
        let obj  = Object(named: "chair", rect: Rect(), type: .directional)
        let obj2 = Object(named: "chair", rect: Rect(), type: .directional)

        
        ///let tag = TextButton("Inventory", onClick: {})
        //tag.position = CGPoint(x: size.width/2, y: size.height/2)
        
        let objCon = ObjectContainer(obj: obj, backColor: .lightGray,
                                     size: CGSize(width: size.width/6, height: size.width/6))
        objCon.position = CGPoint(x: size.width/2, y: size.height/2)
        
        let display = ObjectDisplayer(obj: obj2, price: 100, count: 2,
                                      size: CGSize(width: size.width/5, height:size.width/5), onButtonClick: {})
        display.position = CGPoint(x: size.width/2, y: size.height/2)


        
        //inventoryNode.addChild(tag)
        //inventoryNode.addChild(objCon)
        inventoryNode.addChild(display)
        
        
        // Icons
        appendIcon = prepIcon(name: "add",    size: size)
        shopIcon   = prepIcon(name: "shop",   size: size)
        submitIcon = prepIcon(name: "submit", size: size)
        cancelIcon = prepIcon(name: "cancel", size: size)
        rotateIcon = prepIcon(name: "rotate", size: size)
        
        cancelIcon.anchorPoint = CGPoint(x: 0, y: 1)
        cancelIcon.position = CGPoint(x: 10 , y: size.height - 50)
        rotateIcon.position = CGPoint(x: size.width - (20 + submitIcon.frame.width), y: size.height - 50)
        
        NormalMode()
    }
    
    private func prepIcon(name: String, size: CGSize) -> SKSpriteNode {
        let icon = SKSpriteNode(imageNamed: name)
        icon.position = CGPoint(x: size.width - 10, y: size.height - 50)
        icon.anchorPoint = CGPoint(x: 1, y: 1)
        //icon.scale(to: CGSize(width: 40, height: 40))
        icon.colorBlendFactor = 0
        icon.color = .white
        icon.name = name
        icon.isUserInteractionEnabled = true
        /*
        let outline = SKSpriteNode(imageNamed: name)
        outline.anchorPoint = CGPoint(x: 1, y: 1)
        outline.scale(to: CGSize(width: 40, height: 40))
        outline.color = .black
        outline.colorBlendFactor = 1
        outline.zPosition = -0.1
        icon.addChild(outline)*/

        return icon
    }
    
    public func NormalMode() {
        removeAllChildren()
        addChild(infoNode)
        addChild(settingsNode)
        //addChild(inventoryNode)
    }
    
    public func ShopMode() {
        removeAllChildren()
        addChild(infoNode)
        addChild(cancelIcon)
    }
    
    public func InventoryMode() {
        removeAllChildren()
        addChild(infoNode)

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
        addChild(infoNode)

        addChild(submitIcon)
        addChild(cancelIcon)
        addChild(rotateIcon)
    }
}
