//
//  Menu.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-06-03.
//

import Foundation
import SpriteKit

class Menu {
    var buttons = Array<MenuButton>()
    
    func arrange(scene: GameScene) {
        if self.buttons.count <= 0 {
            return
        }
        
        var pos = getTopPosition(scene: scene)
        
        for b in self.buttons {
            let halfHeight = 0.5 * b.shape.frame.height
            pos.y -= halfHeight
            b.shape.position = pos
            pos.y -= halfHeight + b.spacingAfter
        }
    }
    
    func getTopPosition(scene: GameScene) -> CGPoint {
        var totalHeight: CGFloat = 0.0
        for b in self.buttons {
            totalHeight += b.shape.frame.height + b.spacingAfter
        }
        totalHeight -= self.buttons.last!.spacingAfter
        
        var pos = scene.center()
        pos.y += 0.5 * totalHeight
        
        return pos
    }
    
    func animateButtons(action: SKAction) {
        for b in self.buttons {
            b.shape.run(action)
        }
    }
}
