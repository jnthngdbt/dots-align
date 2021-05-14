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
    
    deinit {
        self.shape.removeFromParent() // removes child label also
    }
}

class MainMenu {
    let startLevelGameBtn: Button!
    
    init(scene: GameScene) {
        self.startLevelGameBtn = Button(scene: scene, text: "PLAY 20 LEVELS", id: Const.Button.startLevelGameId)
    }
}

class EndGameMenu {
    let startLevelGameBtn: Button!
    init(scene: GameScene) {
        self.startLevelGameBtn = Button(scene: scene, text: "REPLAY", id: Const.Button.replayGameId)
    }
}
