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
    let homeButton: FooterHomeButton
    
    let hdrGame: SKLabelNode
    let hdrLevels: SKLabelNode
    let hdrTimed: SKLabelNode
    
    let titlePosY: CGFloat = 0.85
    let tablePosY: CGFloat = 0.75
    
    let colGameWidth: CGFloat = 0.3
    let colLevelWidth: CGFloat = 0.3
    let colTimeWidth: CGFloat = 0.3
    
    let sidePadding: CGFloat
    let colGamePosX: CGFloat
    let colLevelPosX: CGFloat
    let colTimePosX: CGFloat
    
    init(scene: GameScene) {
        self.title = SKLabelNode(text: "SCORE BOARD")
        self.homeButton = FooterHomeButton(scene: scene)
        
        self.hdrGame = SKLabelNode(text: "GAME TYPE")
        self.hdrLevels = SKLabelNode(text: "LEVEL MODE")
        self.hdrTimed = SKLabelNode(text: "TIME MODE")
        
        self.sidePadding = 0.5 * (1 - (self.colGameWidth + self.colLevelWidth + self.colTimeWidth))
        self.colGamePosX = self.sidePadding + 0.5 * self.colGameWidth
        self.colLevelPosX = self.sidePadding + self.colGameWidth + 0.5 * self.colLevelWidth
        self.colTimePosX = self.sidePadding + self.colGameWidth + self.colLevelWidth + 0.5 * self.colTimeWidth
        
        self.setTitle(scene: scene)
        self.setHeaderLabel(scene: scene, lbl: self.hdrGame, posX: self.colGamePosX)
        self.setHeaderLabel(scene: scene, lbl: self.hdrLevels, posX: self.colLevelPosX)
        self.setHeaderLabel(scene: scene, lbl: self.hdrTimed, posX: self.colTimePosX)
        
        self.animateIn()
    }
    
    private func setTitle(scene: GameScene) {
        self.title.fontColor = labelColor
        self.title.fontName = Const.fontNameTitle
        self.title.fontSize = 0.15 * scene.minSize()
        self.title.position = CGPoint(x: scene.center().x, y: self.titlePosY * scene.size.height)
        self.title.setScale(0)
        scene.addChild(self.title)
    }
    
    private func setHeaderLabel(scene: GameScene, lbl: SKLabelNode, posX: CGFloat) {
        lbl.fontColor = labelColor
        lbl.fontName = Const.fontNameLabel
        lbl.fontSize = 0.05 * scene.minSize()
        lbl.position = CGPoint(x: posX * scene.size.width, y: self.tablePosY * scene.size.height)
        lbl.alpha = 0
        scene.addChild(lbl)
    }
    
    private func animateIn() {
        self.title.run(SKAction.sequence([
            SKAction.wait(forDuration: Const.Animation.titleAppearWait),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        let tableAnimation = SKAction.sequence([
            SKAction.wait(forDuration: 2.0 * Const.Animation.titleAppearWait),
            SKAction.fadeAlpha(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.hdrGame.run(tableAnimation)
        self.hdrLevels.run(tableAnimation)
        self.hdrTimed.run(tableAnimation)
    }
    
    deinit {
        self.title.removeFromParent()
        self.hdrGame.removeFromParent()
        self.hdrLevels.removeFromParent()
        self.hdrTimed.removeFromParent()
    }
}
