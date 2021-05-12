//
//  GameScene.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var game: Game!
    
    var unitSphereDiameter: CGFloat = 1.0
    var orbDiameter: CGFloat = 1.0
    var orb = SKShapeNode()
    
    func minSize() -> CGFloat {
        return min(self.size.width, self.size.height)
    }
    
    func center() -> CGPoint {
        let w = self.size.width
        let h = self.size.height
        return CGPoint(x: 0.5 * w, y: 0.5 * h)
    }
    
    // Scene will appear. Create content here. (not "touch moved")
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        self.unitSphereDiameter = Const.Scene.unitSphereDiameterFactor * self.minSize()
        self.orbDiameter = Const.Scene.orbDiameterFactor * self.minSize()
        
        self.orb = SKShapeNode.init(circleOfRadius: 0.5 * self.orbDiameter)
        self.orb.fillColor = UIColor(white: 0.0, alpha: 0.4)
        self.orb.strokeColor = UIColor.clear
        self.orb.position = self.center()
        self.addChild(self.orb)
        
        self.game = Game(scene: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.game.level.solved {
            return
        }
        
        if let t = touches.first {
            let dx = Scalar(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Scalar(t.location(in: self).y - t.previousLocation(in: self).y)
            let v = Vector3d(dx, dy, 0)
            
            if self.unitSphereDiameter > 0 {
                let dir = 2 * v / Scalar(self.unitSphereDiameter) // normalize by radius
                self.game.level.rotate(dir: dir, speed: Const.Scene.orbitingSpeed)
            }
        }
        
        self.game.checkIfLevelSolved()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.game.newLevelIfNecessary(scene: self)
        if self.game.isGameEnded {
            self.game = Game(scene: self)
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
