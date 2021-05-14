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
    
    init(scene: GameScene, text: String, id: String) {
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
    let spacing: CGFloat!
    
    init(scene: GameScene) {
        self.spacing = Const.Menu.spacingFactor * scene.minSize()
    }
    
    func arrange(scene: GameScene) {
        if self.buttons.count <= 0 {
            return
        }
        
        var totalHeight = CGFloat(self.buttons.count - 1) * self.spacing
        for b in self.buttons {
            totalHeight += b.shape.frame.height
        }
        
        var pos = scene.center()
        pos.y += 0.5 * totalHeight
        
        for b in self.buttons {
            let halfHeight = 0.5 * b.shape.frame.height
            pos.y -= halfHeight
            b.shape.position = pos
            pos.y -= halfHeight + self.spacing
            
        }
    }
}

class MainMenu: Menu {
    override init(scene: GameScene) {
        super.init(scene: scene)
        
        self.buttons.append(Button(scene: scene, text: "TUTORIAL", id: Const.Button.tutorialId))
        
        let levelGameText = "PLAY " + String(Const.Game.maxLevel) + " LEVELS"
        self.buttons.append(Button(scene: scene, text: levelGameText, id: Const.Button.startLevelGameId))
        
        let timeGameText = "PLAY " + String(Const.Game.maxSeconds) + " SECONDS"
        self.buttons.append(Button(scene: scene, text: timeGameText, id: Const.Button.startTimedGameId))
        
        self.arrange(scene: scene)
    }
}

class EndGameMenu: Menu {
    override init(scene: GameScene) {
        super.init(scene: scene)
        
        self.buttons.append(Button(scene: scene, text: "REPLAY", id: Const.Button.replayGameId))
        self.buttons.append(Button(scene: scene, text: "HOME", id: Const.Button.homeId))
        
        self.arrange(scene: scene)
    }
}
