//
//  MainMenu.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class MenuButton: Button {
    var spacingAfter: CGFloat = 0.0
    
    override init(scene: GameScene, text: String, id: String = "") {
        super.init(scene: scene, text: text, id: id)
        self.spacingAfter = Const.Menu.spacingFactor * scene.minSize()
    }
}

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

class MainMenu: Menu {
    let cloud: Cloud!
    let title: SKLabelNode!
    
    init(scene: GameScene) {
        // Set cloud.
        let radius = 0.5 * Const.Menu.sphereDiameterFactor * scene.minSize()
        let points = Cloud.generateSymmetricRandomPoints(nbPoints: Const.Menu.sphereNbDots)
        self.cloud = Cloud(points: points, scene: scene, color: Const.Menu.sphereDotsColor, radius: radius)
        self.cloud.desalign()
        
        self.title = SKLabelNode(text: "ALIGN DOTS")
        
        super.init()
        
        self.buttons.append(MenuButton(scene: scene, text: "TUTORIAL", id: Const.Button.tutorialId))
        
        let levelGameText = "PLAY " + String(Const.Game.maxLevel) + " LEVELS"
        self.buttons.append(MenuButton(scene: scene, text: levelGameText, id: Const.Button.startLevelGameId))
        
        let timeGameText = "PLAY " + String(Const.Game.maxSeconds) + " SECONDS"
        self.buttons.append(MenuButton(scene: scene, text: timeGameText, id: Const.Button.startTimedGameId))
        
        self.arrange(scene: scene)
        
        self.setTitle(scene: scene)
        
        self.animateIn()
    }
    
    func setTitle(scene: GameScene) {
        // Center title between screen top and buttons.
        let buttonTopPos = self.getTopPosition(scene: scene)
        let titlePosX = self.buttons.last!.shape.position.x
        let titlePosY = buttonTopPos.y + 0.5 * (scene.size.height - buttonTopPos.y)
        
        self.title.fontColor = UIColor(white: 0.5, alpha: 1)
        self.title.fontName = "AvenirNextCondensed-Heavy"
        self.title.fontSize = 0.16 * scene.minSize()
        self.title.position = CGPoint(x: titlePosX, y: titlePosY)
        self.title.zPosition = self.buttons.last!.shape.zPosition
        self.title.verticalAlignmentMode = .center
        scene.addChild(self.title)
    }
    
    func update() {
        let dt = 0.016 // ms for 60 hz
        let radPerSec = Scalar.pi / 60
        let rad = dt * radPerSec
        let q = Quat(angle: rad, axis: simd_normalize(Vector3d(-1, 1, 0)))
        self.cloud.rotate(quaternion: q)
    }
    
    private func animateIn() {
        self.animateInButtons()
        self.animateInCloud()
    }
    
    private func animateInCloud() {
        let blinkUp = SKAction.group([
            SKAction.fadeAlpha(by: 0.0, duration: 0.05),
            SKAction.scale(to: 1.3, duration: 0.05)
        ])
        
        let blinkDown = SKAction.group([
            SKAction.fadeAlpha(by: -0.0, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
        
        let animation = SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.0),
            SKAction.wait(forDuration: 0.5),
            SKAction.scale(to: 1, duration: 0.1),
            blinkUp,
            blinkDown
        ])
        
        self.cloud.animate(action: animation)
    }
    
    private func animateInButtons() {
        let animation = SKAction.sequence([
            SKAction.fadeAlpha(to: 0, duration: 0.0),
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeAlpha(to: 1, duration: 0.1)
        ])
        
        self.animateButtons(action: animation)
    }
    
    deinit {
        self.title.removeFromParent()
    }
}

class EndGameMenu: Menu {
    init(scene: GameScene, score: Int) {
        super.init()
        
        self.addScoreLabel(scene: scene, label: "SCORE", value: score, spacingAfterFactor: 2.0)
        self.addScoreLabel(scene: scene, label: "BEST", value: score, spacingAfterFactor: 5.0)
        
        self.buttons.append(MenuButton(scene: scene, text: "REPLAY", id: Const.Button.replayGameId))
        self.buttons.append(MenuButton(scene: scene, text: "HOME", id: Const.Button.homeId))
        
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
            SKAction.fadeAlpha(to: 1, duration: 0.1)
        ])
        
        self.animateButtons(action: animation)
    }
    
    func addScoreLabel(scene: GameScene, label: String, value: Int, spacingAfterFactor: CGFloat = 1.0) {
        let scoreLabel = MenuButton(scene: scene, text: label)
        scoreLabel.shape.fillColor = UIColor.clear
        scoreLabel.label.fontSize *= 2.25
        scoreLabel.shape.setScale(0.4)
        scoreLabel.label.fontColor = UIColor(white: 0.4, alpha: 1)
        scoreLabel.spacingAfter *= 0
        self.buttons.append(scoreLabel)
        
        let scoreButton = MenuButton(scene: scene, text: String(value))
        scoreButton.shape.fillColor = UIColor.clear
        scoreButton.label.fontSize *= 2.25
        scoreButton.label.fontColor = UIColor(white: 0.4, alpha: 1)
        scoreButton.spacingAfter *= spacingAfterFactor
        self.buttons.append(scoreButton)
    }
}
