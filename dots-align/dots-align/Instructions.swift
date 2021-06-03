//
//  TutorialInstructions.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-27.
//

import Foundation
import SpriteKit

class FooterInstructionsButton: FooterButton {
    init(scene: GameScene) {
        super.init(scene: scene, text: "✔︎", id: ButtonId.tutorialInstructionsId)
        self.shape.position.x = scene.size.width - Const.Indicators.sidePaddingFactor * scene.minSize()
    }
}

class Instructions {
    var button: FooterInstructionsButton
    var title: SKLabelNode?
    var text: ContainedLabel?
    var areInstructionsShown = true

    init(scene: GameScene) {
        self.button = FooterInstructionsButton(scene: scene)
        self.showInstructions(scene: scene)
    }
    
    func showInstructions(scene: GameScene) {
        self.button.label.text = "✔︎"
        
        self.title = SKLabelNode(text: "TUTORIAL")
        self.title!.fontColor = labelColor
        self.title!.fontName = Const.fontNameTitle
        self.title!.fontSize = 0.11 * scene.minSize()
        self.title!.position = CGPoint(x: scene.center().x, y: 0.9 * scene.size.height)
        scene.addChild(self.title!)
        
        var text = ""
        text += "► The goal is to align two symmetric dot patterns orbiting a ball.\n\n"
        text += "► For this tutorial, small red dots are added to the patterns to help you find the solution. Aligning the small red dots will align the two patterns.\n\n"
        text += "► When you feel you can do it without those handy small dots, you are ready to play!\n\n"
        text += "► Tap the checkmark below to hide those instructions."
        
        let size = CGSize(width: 0.95 * scene.size.width, height: 2.0 * scene.size.height)
        
        // For the block of text, scale font also including aspect ratio.
        // Otherwise, for iPads with lower aspect ratio, the text is too big and goes too low.
        let aspectClip = min(1.8, scene.maxSize() / scene.minSize())
        let textFontSize = aspectClip * 0.03 * scene.minSize()
        
        self.text = ContainedLabel(scene: scene, text: text, size: size, cornerRadius: 0)

        self.text!.label.fontName = Const.fontNameText
        self.text!.shape.fillColor = UIColor(white: 0.0, alpha: 0.5)
        self.text!.label.fontSize = textFontSize
        self.text!.label.fontColor = labelColor
        self.text!.shape.position = CGPoint(x: scene.center().x, y: 0.85 * scene.size.height)
        self.text!.shape.zPosition = Const.Button.zPosition - 1.0
        self.text!.label.horizontalAlignmentMode = .center
        self.text!.label.verticalAlignmentMode = .top

        self.text!.shape.alpha = 1.0

        self.text!.label.lineBreakMode = .byWordWrapping
        self.text!.label.numberOfLines = 0
        self.text!.label.preferredMaxLayoutWidth = size.width
        
        self.title!.zPosition = Const.Button.zPosition
    }
    
    func onButtonTap(scene: GameScene) {
        self.areInstructionsShown = !self.areInstructionsShown
        
        if (self.areInstructionsShown) {
            self.showInstructions(scene: scene)
        } else {
            self.text = nil
            self.title?.removeFromParent()
            self.button.label.text = "?"
        }
    }
    
    func animate(action: SKAction) {
        self.text?.animate(action: action)
        self.title?.run(action)
    }
    
    deinit {
        self.title?.removeFromParent()
    }
}
