//
//  TutorialInstructions.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-27.
//

import Foundation
import SpriteKit

class TutorialInstructions {
    var instructions: ContainedLabel
    var title: SKLabelNode

    init(scene: GameScene) {
        self.title = SKLabelNode(text: "TUTORIAL")
        self.title.fontColor = labelColor
        self.title.fontName = Const.fontNameTitle
        self.title.fontSize = 0.11 * scene.minSize()
        self.title.position = CGPoint(x: scene.center().x, y: 0.9 * scene.size.height)
        scene.addChild(self.title)
        
        var text = ""
        text += "► The goal is to align the two symmetric dot patterns orbiting the ball.\n\n"
        text += "► In this tutorial, small red dots are added to the patterns to help you find the solution. Aligning the small red dots will align the two patterns.\n\n"
        text += "► When you feel you can do it without those handy small dots, you are ready to play!\n\n"
        text += "► Tap the checkmark below to hide those instructions."
        
        let size = CGSize(width: 0.95 * scene.size.width, height: 2.0 * scene.size.height)
        
        // For the block of text, scale font also including aspect ratio.
        // Otherwise, for iPads with lower aspect ratio, the text is too big and goes too low.
        let aspect = scene.maxSize() / scene.minSize()
        let textFontSize = aspect * 0.03 * scene.minSize()
        
        self.instructions = ContainedLabel(scene: scene, text: text, size: size, cornerRadius: 0)

        self.instructions.label.fontName = Const.fontNameText
        self.instructions.shape.fillColor = UIColor(white: 0.0, alpha: 0.5)
        self.instructions.label.fontSize = textFontSize
        self.instructions.label.fontColor = labelColor
        self.instructions.shape.position = CGPoint(x: scene.center().x, y: 0.85 * scene.size.height)
        self.instructions.shape.zPosition = Const.Button.zPosition - 1.0
        self.instructions.label.horizontalAlignmentMode = .center
        self.instructions.label.verticalAlignmentMode = .top

        self.instructions.shape.alpha = 1.0

        self.instructions.label.lineBreakMode = .byWordWrapping
        self.instructions.label.numberOfLines = 0
        self.instructions.label.preferredMaxLayoutWidth = size.width
        
        self.title.zPosition = Const.Button.zPosition
    }
    
    deinit {
        self.title.removeFromParent()
    }
}
