//
//  EndGameMenu.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-06-03.
//

import Foundation
import SpriteKit

class MenuEndGame: Menu {
    init(scene: GameScene, score: Int, bestScore: Int) {
        super.init()
        
        let isNewBest = score > bestScore
        
        self.addTitleLabel(scene: scene, label: "SCORES", spacingAfterFactor: 7.0)
        
        if isNewBest {
            self.addScoreLabel(scene: scene, label: "NEW BEST", value: score, scale: 1.5, spacingAfterFactor: 5.0)
        } else {
            self.addScoreLabel(scene: scene, label: "THIS GAME", value: score, scale: 1.0, spacingAfterFactor: 2.0)
            self.addScoreLabel(scene: scene, label: "YOUR BEST", value: bestScore, scale: 1.0, spacingAfterFactor: 5.0)
        }
        
        self.buttons.append(MenuButton(scene: scene, text: "REPLAY", id: ButtonId.replayGameId))
        self.buttons.append(MenuButton(scene: scene, text: "HOME", id: ButtonId.endGameHomeId))
        
        self.arrange(scene: scene)
        
        self.animateIn()
    }
    
    private func animateIn() {
        self.animateInButtons()
    }
    
    private func animateInButtons() {
        let animation = SKAction.sequence([
            SKAction.fadeAlpha(to: 0, duration: 0.0),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeAlpha(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.animateButtons(action: animation)
    }
    
    func addTitleLabel(scene: GameScene, label: String, spacingAfterFactor: CGFloat = 1.0) {
        let label = MenuButton(scene: scene, text: label)
        label.label.fontName = Const.fontNameTitle
        label.shape.fillColor = UIColor.clear
        label.label.fontSize *= 3
        label.shape.setScale(1.0)
        label.label.fontColor = labelColor
        label.spacingAfter *= spacingAfterFactor
        self.buttons.append(label)
    }
    
    func addScoreLabel(scene: GameScene, label: String, value: Int, scale: CGFloat, spacingAfterFactor: CGFloat = 1.0) {
        let scoreLabel = MenuButton(scene: scene, text: label)
        scoreLabel.shape.fillColor = UIColor.clear
        scoreLabel.label.fontSize *= 2.25
        scoreLabel.shape.setScale(scale * 0.4)
        scoreLabel.label.fontColor = labelColor
        scoreLabel.spacingAfter *= 0
        self.buttons.append(scoreLabel)
        
        let scoreButton = MenuButton(scene: scene, text: String(value))
        scoreButton.shape.fillColor = UIColor.clear
        scoreButton.label.fontSize *= 2.25
        scoreButton.shape.setScale(scale * 1.0)
        scoreButton.label.fontColor = labelColor
        scoreButton.spacingAfter *= spacingAfterFactor
        self.buttons.append(scoreButton)
    }
}
