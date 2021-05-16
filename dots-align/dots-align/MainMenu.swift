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
        
        var totalHeight: CGFloat = 0.0
        for b in self.buttons {
            totalHeight += b.shape.frame.height + b.spacingAfter
        }
        totalHeight -= self.buttons.last!.spacingAfter
        
        var pos = scene.center()
        pos.y += 0.5 * totalHeight
        
        for b in self.buttons {
            let halfHeight = 0.5 * b.shape.frame.height
            pos.y -= halfHeight
            b.shape.position = pos
            pos.y -= halfHeight + b.spacingAfter
        }
    }
}

class MainMenu: Menu {
    let cloud: Cloud!
    
    init(scene: GameScene) {
        // Set cloud.
        let radius = 0.5 * Const.Menu.sphereDiameterFactor * scene.minSize()
        let points = Cloud.generateSymmetricRandomPoints(nbPoints: Const.Menu.sphereNbDots)
        self.cloud = Cloud(points: points, scene: scene, color: Const.Menu.sphereDotsColor, radius: radius)
        self.cloud.desalign()
        
        super.init()
        
        self.buttons.append(Button(scene: scene, text: "TUTORIAL", id: Const.Button.tutorialId))
        
        let levelGameText = "PLAY " + String(Const.Game.maxLevel) + " LEVELS"
        self.buttons.append(Button(scene: scene, text: levelGameText, id: Const.Button.startLevelGameId))
        
        let timeGameText = "PLAY " + String(Const.Game.maxSeconds) + " SECONDS"
        self.buttons.append(Button(scene: scene, text: timeGameText, id: Const.Button.startTimedGameId))
        
        self.arrange(scene: scene)
    }
}

class EndGameMenu: Menu {
    init(scene: GameScene, score: Int) {
        super.init()
        
        self.addScoreLabel(scene: scene, label: "SCORE", value: score, spacingAfterFactor: 1.0)
        self.addScoreLabel(scene: scene, label: "BEST", value: score, spacingAfterFactor: 3.0)
        
        self.buttons.append(Button(scene: scene, text: "REPLAY", id: Const.Button.replayGameId))
        self.buttons.append(Button(scene: scene, text: "HOME", id: Const.Button.homeId))
        
        self.arrange(scene: scene)
    }
    
    func addScoreLabel(scene: GameScene, label: String, value: Int, spacingAfterFactor: CGFloat = 1.0) {
        let scoreLabel = Button(scene: scene, text: label)
        scoreLabel.shape.fillColor = UIColor.clear
        scoreLabel.label.fontSize *= 2.25
        scoreLabel.shape.setScale(0.4)
        scoreLabel.label.fontColor = Const.Indicators.fontColor
        scoreLabel.spacingAfter *= 0
        self.buttons.append(scoreLabel)
        
        let scoreButton = Button(scene: scene, text: String(value))
        scoreButton.shape.fillColor = UIColor.clear
        scoreButton.label.fontSize *= 2.25
        scoreButton.label.fontColor = Const.Indicators.fontColor
        scoreButton.spacingAfter *= spacingAfterFactor
        self.buttons.append(scoreButton)
    }
}
