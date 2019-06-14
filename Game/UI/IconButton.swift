//
//  IconButton.swift
//  Game
//
//  Created by Torben Nordtorp on 2019-06-12.
//  Copyright © 2019 Torben Nordtorp. All rights reserved.
//

import SpriteKit

class IconButton: SKSpriteNode, Button {
    var isOn = true
    let onClickOn: () -> ()
    let onClickOff: () -> ()
    let onTexture: SKTexture
    let offTexture: SKTexture
    
    init(
        onTexture: String,
        offTexture: String,
        isOn: Bool,
        onClickOn: @escaping () -> Void,
        onClickOff: @escaping () -> Void
    ) {
        self.onClickOn = onClickOn
        self.onClickOff = onClickOff
        self.onTexture = SKTexture(imageNamed: onTexture)
        self.offTexture = SKTexture(imageNamed: offTexture)
        self.isOn = isOn
        if isOn {
            super.init(texture: self.onTexture, color: .white, size: self.onTexture.size())
        } else {
            super.init(texture: self.offTexture, color: .white, size: self.onTexture.size())
        }
    }

    func onHover(_ bool: Bool) {
        if bool { alpha = 0.5 } else { alpha = 1 }
    }
    
    func onClick() {
        if isOn { onClickOn() ; isOn = !isOn; texture = offTexture }
        else    { onClickOff(); isOn = !isOn; texture = onTexture  }
    }
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
