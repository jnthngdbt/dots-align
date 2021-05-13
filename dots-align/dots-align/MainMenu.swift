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
    
    init(scene: GameScene) {
        let size = CGSize(width: 0.75 * scene.minSize(), height: 0.2 * scene.minSize())
        
        self.label = SKLabelNode(text: "PLAY 20 LEVELS")
        self.label.fontColor = Const.Menu.fontColor
        self.label.fontName = Const.fontName
        self.label.fontSize = CGFloat(Const.Menu.fontSizeFactor) * scene.minSize()
        self.label.verticalAlignmentMode = .center
        self.label.name = "startLevelGame"
        
        self.shape = SKShapeNode(rectOf: size, cornerRadius: 0.5 * size.height)
        self.shape.fillColor = UIColor.init(white: 0.1, alpha: 1)
        self.shape.strokeColor = UIColor.clear
        self.shape.position = scene.center()
        self.shape.name = "startLevelGame"
        
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
        self.startLevelGameBtn = Button(scene: scene)
    }
}
