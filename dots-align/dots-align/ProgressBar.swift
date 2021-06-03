//
//  ProgressBar.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-06-03.
//

import Foundation
import SpriteKit

class ProgressBar {
    var edge: SKShapeNode!
    var fill: SKShapeNode!
    var minimum: CGFloat = 0
    var maximum: CGFloat = 100
    let rect: CGRect
    
    init(scene: GameScene, rect: CGRect) {
        let cornerRadius = 0 * rect.height
        let color = Const.Indicators.fontColor
        
        self.rect = rect
        
        self.edge = SKShapeNode(rectOf: CGSize(width: rect.width, height: rect.height), cornerRadius: cornerRadius)
        self.edge.position = rect.origin
        self.edge.fillColor = UIColor.clear
        self.edge.strokeColor = color
        
        self.fill = SKShapeNode(rectOf: CGSize(width: rect.width, height: rect.height), cornerRadius: cornerRadius)
        self.fill.position = rect.origin
        self.fill.fillColor = color
        self.fill.strokeColor = color
        
        scene.addChild(self.edge)
        scene.addChild(self.fill)
    }
    
    func setValue(value: CGFloat) {
        var ratio = (value - self.minimum) / (self.maximum - self.minimum) // convert to [0, 1] range
        ratio = max(0.0, min(1.0, ratio))
        
        self.fill.xScale = ratio
        self.fill.position.x = rect.origin.x - 0.5 * (1.0 - ratio) * rect.width
    }
    
    func animate(action: SKAction) {
        self.edge.run(action)
        self.fill.run(action)
    }
    
    deinit {
        self.edge.removeFromParent()
        self.fill.removeFromParent()
    }
}
