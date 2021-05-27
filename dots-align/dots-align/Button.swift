//
//  Button.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-25.
//

import Foundation
import SpriteKit

class ContainedLabel {
    let label: SKLabelNode
    let shape: SKShapeNode
    
    init(scene: GameScene, text: String, size: CGSize, cornerRadius: CGFloat) {
        self.label = SKLabelNode(text: text)
        self.label.fontColor = Const.Button.fontColor
        self.label.fontName = Const.fontNameLabel
        self.label.fontSize = Const.Button.fontSizeFactor * scene.minSize()
        self.label.verticalAlignmentMode = .center
        
        self.shape = SKShapeNode(rectOf: size, cornerRadius: cornerRadius)
        self.shape.fillColor = Const.Button.fillColor
        self.shape.strokeColor = UIColor.clear
        self.shape.position = scene.center()
        
        self.shape.addChild(self.label)
        
        self.shape.zPosition = Const.Button.zPosition // make to be in foreground (max z of sphere dots is 1)
        
        self.shape.alpha = 0.0 // start hidden to make sure to not show it before being ready
        
        if (Const.debug) {
            self.shape.strokeColor = UIColor.white
        }
        
        scene.addChild(self.shape)
    }
    
    func size() -> CGSize {
        return self.shape.frame.size
    }
    
    static func animateFromHitNode(node: SKNode) {
        if let buttonShapeNode = ContainedLabel.getShapeNode(node: node) {
            buttonShapeNode.run(SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.06),
                SKAction.scale(to: 1.0, duration: 0.06),
            ]))
        }
    }
    
    static func getShapeNode(node: SKNode) -> SKNode? {
        // When tapping a button, will hit either the label or the shape.
        // The shape node is the one that has a child (the label does not).
        return node.children.count > 0 ? node : node.parent
    }
    
    deinit {
        self.shape.removeFromParent() // removes child label also
    }
}

class Button: ContainedLabel {
    init(scene: GameScene, text: String, id: ButtonId = ButtonId.none) {
        let w = Const.Button.widthFactor * scene.minSize()
        let h = Const.Button.heightFactor * scene.minSize()
        let size = CGSize(width: w, height: h)
        
        super.init(scene: scene, text: text, size: size, cornerRadius: 0.5 * size.height)
        self.label.name = id.rawValue
        self.shape.name = id.rawValue
    }
}
