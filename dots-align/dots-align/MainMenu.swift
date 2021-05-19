//
//  MainMenu.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class Button {
    let label: SKLabelNode
    let shape: SKShapeNode
    var spacingAfter: CGFloat = 0.0
    
    init(scene: GameScene, text: String, id: String = "") {
        let w = Const.Button.widthFactor * scene.minSize()
        let h = Const.Button.heightFactor * scene.minSize()
        let size = CGSize(width: w, height: h)
        
        self.label = SKLabelNode(text: text)
        self.label.fontColor = Const.Button.fontColor
        self.label.fontName = Const.fontName
        self.label.fontSize = Const.Button.fontSizeFactor * scene.minSize()
        self.label.verticalAlignmentMode = .center
        self.label.name = id
        
        self.shape = SKShapeNode(rectOf: size, cornerRadius: 0.5 * size.height)
        self.shape.fillColor = Const.Button.fillColor
        self.shape.strokeColor = UIColor.clear
        self.shape.position = scene.center()
        self.shape.name = id
        
        self.shape.addChild(self.label)
        
        self.shape.zPosition = 2.0 // make to be in foreground (max z of sphere dots is 1)
        
        self.spacingAfter = Const.Menu.spacingFactor * scene.minSize()
        
        scene.addChild(self.shape)
    }
    
    func size() -> CGSize {
        return self.shape.frame.size
    }
    
    deinit {
        self.shape.removeFromParent() // removes child label also
    }
}

class Menu {
    var buttons = Array<Button>()
    
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
        
        self.buttons.append(Button(scene: scene, text: "TUTORIAL", id: Const.Button.tutorialId))
        
        let levelGameText = "PLAY " + String(Const.Game.maxLevel) + " LEVELS"
        self.buttons.append(Button(scene: scene, text: levelGameText, id: Const.Button.startLevelGameId))
        
        let timeGameText = "PLAY " + String(Const.Game.maxSeconds) + " SECONDS"
        self.buttons.append(Button(scene: scene, text: timeGameText, id: Const.Button.startTimedGameId))
        
        self.arrange(scene: scene)
        
        self.setTitle(scene: scene)
        
        self.animateIn()
    }
    
    func setTitle(scene: GameScene) {
        // Center title between screen top and buttons.
        let buttonTopPos = self.getTopPosition(scene: scene)
        let titlePosX = self.buttons.last!.shape.position.x
        let titlePosY = buttonTopPos.y + 0.5 * (scene.size.height - buttonTopPos.y)
        
        self.title.fontColor = Const.Button.fillColor
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
        let blinkUp = SKAction.group([
            SKAction.fadeAlpha(by: 0, duration: 0.05),
            SKAction.scale(to: 1.5, duration: 0.05)
        ])
        
        let blinkDown = SKAction.group([
            SKAction.fadeAlpha(by: 0, duration: 0.05),
            SKAction.scale(to: 1.0, duration: 0.05)
        ])
        
        let animation = SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.0),
            SKAction.wait(forDuration: 0.5),
            SKAction.scale(to: 1, duration: 0.2),
            blinkUp,
            blinkDown
        ])
        
        self.cloud.animate(action: animation)
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
        
        self.buttons.append(Button(scene: scene, text: "REPLAY", id: Const.Button.replayGameId))
        self.buttons.append(Button(scene: scene, text: "HOME", id: Const.Button.homeId))
        
        self.arrange(scene: scene)
    }
    
    func addScoreLabel(scene: GameScene, label: String, value: Int, spacingAfterFactor: CGFloat = 1.0) {
        let scoreLabel = Button(scene: scene, text: label)
        scoreLabel.shape.fillColor = UIColor.clear
        scoreLabel.label.fontSize *= 2.25
        scoreLabel.shape.setScale(0.4)
        scoreLabel.label.fontColor = UIColor(white: 0.4, alpha: 1)
        scoreLabel.spacingAfter *= 0
        self.buttons.append(scoreLabel)
        
        let scoreButton = Button(scene: scene, text: String(value))
        scoreButton.shape.fillColor = UIColor.clear
        scoreButton.label.fontSize *= 2.25
        scoreButton.label.fontColor = UIColor(white: 0.4, alpha: 1)
        scoreButton.spacingAfter *= spacingAfterFactor
        self.buttons.append(scoreButton)
    }
}
