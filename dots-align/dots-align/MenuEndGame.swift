//
//  EndGameMenu.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-06-03.
//

import Foundation
import SpriteKit

class MenuEndGame {
    let title: SKLabelNode
    let gameDescription: SKLabelNode
    let newScoreTitle: SKLabelNode
    let newScoreValue: SKLabelNode
    let bestScoreTitle: SKLabelNode
    let bestScoreValue: SKLabelNode
    let gamesLeft: SKLabelNode
    let replayButton: MenuButton
    let homeButton: MenuButton
    
    let newScore: Int
    let bestScore: Int
    
    init(scene: GameScene, mode: GameMode, type: GameType) {
        self.newScore = UserData.getLastScore(mode: mode, type: type)
        self.bestScore = UserData.getBestScore(mode: mode, type: type)
        
        self.title = SKLabelNode(text: "SCORE")
        self.gameDescription = SKLabelNode(text: Const.getGameTypeData(type).description())
        self.newScoreTitle = SKLabelNode(text: "THIS GAME")
        self.newScoreValue = SKLabelNode(text: String(self.newScore))
        self.bestScoreTitle = SKLabelNode(text: "YOUR BEST")
        self.bestScoreValue = SKLabelNode(text: String(self.bestScore))
        self.gamesLeft = SKLabelNode(text: "PLAY 5 MORE GAMES TO UNLOCK A NEW GAME!")
        self.replayButton = MenuButton(scene: scene, text: "REPLAY", id: ButtonId.replayGameId)
        self.homeButton = MenuButton(scene: scene, text: "HOME", id: ButtonId.endGameHomeId)
        
        self.setTitle(scene: scene)
        self.setGameDescription(scene: scene)
        self.setNewScore(scene: scene)
        self.setBestScore(scene: scene)
        self.setGamesLeft(scene: scene)
        self.setButtons(scene: scene)
        
//        if isNewBest {
//            self.addScoreLabel(scene: scene, label: "NEW BEST", value: score, scale: 1.5, spacingAfterFactor: 5.0)
//        } else {
//            self.addScoreLabel(scene: scene, label: "THIS GAME", value: score, scale: 1.0, spacingAfterFactor: 2.0)
//            self.addScoreLabel(scene: scene, label: "YOUR BEST", value: bestScore, scale: 1.0, spacingAfterFactor: 4.0)
//        }
        
        self.animateIn()
    }
    
    private func isNewBestScore() -> Bool {
        return self.newScore > self.bestScore
    }
    
    private func setTitle(scene: GameScene) {
        MenuEndGame.setLabel(scene: scene, label: self.title, fontSize: 0.18, posY: 0.90 * scene.size.height)
        self.title.fontName = Const.fontNameTitle
    }
    
    private func setGameDescription(scene: GameScene) {
        MenuEndGame.setLabel(scene: scene, label: self.gameDescription, fontSize: 0.07, posY: 0.78 * scene.size.height)
        self.gameDescription.fontColor = Const.accentColor
        self.gameDescription.fontName = Const.fontNameTitle
    }
    
    private func setNewScore(scene: GameScene) {
        MenuEndGame.setScoreIndicator(scene: scene, title: self.newScoreTitle, value: self.newScoreValue, posY: 0.67)
    }
    
    private func setBestScore(scene: GameScene) {
        MenuEndGame.setScoreIndicator(scene: scene, title: self.bestScoreTitle, value: self.bestScoreValue, posY: 0.52)
    }
    
    private func setGamesLeft(scene: GameScene) {
        MenuEndGame.setLabel(scene: scene, label: self.gamesLeft, fontSize: 0.04, posY: 0.35 * scene.size.height)
    }
    
    private func setButtons(scene: GameScene) {
        let posY = 0.18 * scene.size.height
        let spacing = 0.16 * scene.minSize() // spacing not function of height
        
        self.replayButton.shape.position.y = posY
        self.homeButton.shape.position.y = posY + spacing
    }
    
    private static func setLabel(scene: GameScene, label: SKLabelNode, fontSize: CGFloat, posY: CGFloat) {
        label.fontColor = Const.labelColor
        label.fontName = Const.fontNameLabel
        label.fontSize = fontSize * scene.minSize()
        label.position = CGPoint(x: scene.center().x, y: posY)
        label.verticalAlignmentMode = .center
        label.setScale(0) // will animate
        scene.addChild(label)
    }
    
    private static func setScoreIndicator(scene: GameScene, title: SKLabelNode, value: SKLabelNode, posY: CGFloat) {
        let titlePosY = posY * scene.size.height
        let valuePosY = titlePosY - 0.1 * scene.minSize() // spacing not function of height
        
        MenuEndGame.setLabel(scene: scene, label: title, fontSize: 0.06, posY: titlePosY)
        MenuEndGame.setLabel(scene: scene, label: value, fontSize: 0.15, posY: valuePosY)
    }
    
    private func animateIn() {
        self.title.run(MenuEndGame.getAnimation(wait: 0.1))
        self.gameDescription.run(MenuEndGame.getAnimation(wait: 0.2))
        self.newScoreTitle.run(MenuEndGame.getAnimation(wait: 0.4))
        self.newScoreValue.run(MenuEndGame.getAnimation(wait: 0.4))
        self.bestScoreTitle.run(MenuEndGame.getAnimation(wait: 0.4))
        self.bestScoreValue.run(MenuEndGame.getAnimation(wait: 0.4))
        self.gamesLeft.run(MenuEndGame.getAnimation(wait: 0.5))
        self.replayButton.animate(MenuEndGame.getAnimation(wait: 0.6))
        self.homeButton.animate(MenuEndGame.getAnimation(wait: 0.6))
    }
    
    private static func getAnimation(wait: TimeInterval) -> SKAction {
        return SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.0),
            SKAction.wait(forDuration: wait),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ])
    }
    
    deinit {
        self.title.removeFromParent()
        self.gameDescription.removeFromParent()
        self.newScoreTitle.removeFromParent()
        self.newScoreValue.removeFromParent()
        self.bestScoreTitle.removeFromParent()
        self.bestScoreValue.removeFromParent()
        self.gamesLeft.removeFromParent()
    }
}
