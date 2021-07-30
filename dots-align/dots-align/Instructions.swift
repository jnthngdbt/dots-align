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
    var titleString: String
    var text: ContainedLabel?
    var textString: String
    var alpha: CGFloat
    var areInstructionsShown = true

    init(scene: GameScene, title: String, text: String, alpha: CGFloat, startHidden: Bool) {
        self.button = FooterInstructionsButton(scene: scene)
        self.titleString = title
        self.textString = text
        self.alpha = alpha
        
        if startHidden {
            self.hideInstructions()
        } else {
            self.showInstructions(scene: scene)
        }
    }
    
    func showInstructions(scene: GameScene) {
        self.button.label.text = "✔︎"
        self.areInstructionsShown = true
        
        self.title = SKLabelNode(text: self.titleString)
        self.title!.fontColor = Const.labelColor
        self.title!.fontName = Const.fontNameTitle
        self.title!.fontSize = 0.11 * scene.minSize()
        self.title!.position = CGPoint(x: scene.center().x, y: 0.9 * scene.size.height)
        scene.addChild(self.title!)
        
        let size = CGSize(width: 0.9 * scene.size.width, height: 2.0 * scene.size.height)
        
        // For the block of text, scale font also including aspect ratio.
        // Otherwise, for iPads with lower aspect ratio, the text is too big and goes too low.
        let aspectClip = min(1.8, scene.maxSize() / scene.minSize())
        let textFontSize = aspectClip * 0.032 * scene.minSize()
        
        self.text = ContainedLabel(scene: scene, text: self.textString, size: size, cornerRadius: 0)

        self.text!.label.fontName = Const.fontNameText
        self.text!.shape.fillColor = UIColor(white: 0.0, alpha: self.alpha)
        self.text!.label.fontSize = textFontSize
        self.text!.label.fontColor = Const.labelColor
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
    
    func hideInstructions() {
        self.button.label.text = "?"
        self.areInstructionsShown = false
        
        self.text = nil
        self.title?.removeFromParent()
    }
    
    func onButtonTap(scene: GameScene) {
        self.areInstructionsShown = !self.areInstructionsShown
        
        if (self.areInstructionsShown) {
            self.showInstructions(scene: scene)
        } else {
            self.hideInstructions()
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

class InstructionsGetStarted: Instructions {
    init(scene: GameScene) {
        var text = ""
        text += "► Find the symmetry in the pattern of dots.\n\n"
        text += "► Rotate the dots to make the two symmetric parts overlap.\n\n"
        text += "► Small red dots are added here as guides to help you get started. They won't be there during the game.\n\n"
        text += "► Tap the checkmark below to hide those instructions."
        
        super.init(scene: scene, title: "GET STARTED", text: text, alpha: 0.5, startHidden: false)
    }
}

class InstructionsHowItWorks: Instructions {
    init(scene: GameScene) {
        var text = ""
        text += "► Find the symmetry in the pattern of dots.\n\n"
        text += "► Rotate the dots to make the two symmetric parts overlap.\n\n"
        text += "► The level score is the number of dots multiplied by the boost level.\n\n"
        text += "► The boost level decreases with time or when you rotate the dots, depending on game mode.\n\n"
        text += "► The boost level determines the number of dots of the next level."
        
        super.init(scene: scene, title: "HOW IT WORKS", text: text, alpha: 0.8, startHidden: true)
    }
}
