//
//  GameScene.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var dotNode : SKShapeNode?
    
    // Scene will appear. Create content here. (not "touch moved")
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 1)
        
        // Dot.
        let w = self.size.width
        let h = self.size.height
        let r = 0.05 * w
        let dotColor = UIColor(white: 0.7, alpha: 1)
        
        self.dotNode = SKShapeNode.init(circleOfRadius: r)
        
        if let dotNode = self.dotNode {
            dotNode.strokeColor = dotColor
            dotNode.fillColor = dotColor
            dotNode.position = CGPoint(x: 0.5 * w, y: 0.5 * h)
            dotNode.glowWidth = r * 0.5
            self.addChild(dotNode)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let dx = t.location(in: self).x - t.previousLocation(in: self).x
            let dy = t.location(in: self).y - t.previousLocation(in: self).y
            
            self.dotNode?.position.x += dx
            self.dotNode?.position.y += dy
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
