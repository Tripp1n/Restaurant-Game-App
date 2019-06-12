//
//  Door.swift
//  Game
//
//  Created by Torben Nordtorp on 2019-04-18.
//  Copyright © 2019 Torben Nordtorp. All rights reserved.
//

import Foundation

public class Door: Object, Interactable {
    func interacted(by prs: Person) -> Bool {
        texture = Object.getTexture(named: "door_open", type: .directional, dir: dir)
        prs.run(.fadeOut(withDuration: 1)) {
            prs.removeFromParent()
            prs.desire = .vanish
            prs.goal = nil
            self.texture = Object.getTexture(named: "door_closed", type: .directional, dir: self.dir)
        }

        return true
    }
    
    public override func isPlacementAllowed(room: Rect, objs: [Object]) -> Bool {
        if super.isPlacementAllowed(room: room, objs: objs) {
            return rect.getOverlappingEdges(in: room).contains(Dir(rawValue: (dir.rawValue + 2)%4))
        }
        return false
    }
}
