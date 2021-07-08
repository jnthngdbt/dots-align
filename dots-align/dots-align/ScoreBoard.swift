//
//  ScoreBoard.swift
//  dots-align
//
//  Created by Jonathan on 2021-07-08.
//

import Foundation
import SpriteKit

class ScoreBoard {
    let title: SKLabelNode
    var homeButton: FooterHomeButton!
    
    let columnGamePosX = 0.3
    let columnLevelsPosX = 0.6
    let columnTimedPosX = 0.8
    
    init(scene: GameScene) {
        self.title = SKLabelNode(text: "SCORE BOARD")
        self.title.fontColor = labelColor
        self.title.fontName = Const.fontNameTitle
        self.title.fontSize = 0.15 * scene.minSize()
        self.title.position = CGPoint(x: scene.center().x, y: 0.85 * scene.size.height)
        self.title.setScale(0)
        scene.addChild(self.title)
        
        self.homeButton = FooterHomeButton(scene: scene)
        
        self.animateIn()
    }
    
    private func animateIn() {
        self.title.run(SKAction.sequence([
            SKAction.wait(forDuration: Const.Animation.titleAppearWait),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
    }
    
    deinit {
        self.title.removeFromParent()
    }
}
