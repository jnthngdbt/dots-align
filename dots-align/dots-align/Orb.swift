//
//  Orb.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-06-01.
//

import Foundation
import SpriteKit

class Orb {
    let node: SKShapeNode
    init(scene: GameScene, diameter: CGFloat = Const.Orb.diameterFactor) {
        self.node = SKShapeNode.init(circleOfRadius: 0.5 * diameter * scene.minSize())
        self.node.fillColor = Const.Orb.color
        self.node.strokeColor = UIColor.clear
        self.node.position = scene.center()
        self.node.setScale(0) // must animate
        scene.addChild(self.node)
    }
    
    deinit {
        self.node.removeFromParent()
    }
}
