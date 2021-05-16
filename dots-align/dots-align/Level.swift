//
//  Level.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class Level {
    var cloud: Cloud!
    var indicators: GameIndicators!
    
    var nbPatternPoints = 0
    var angleCumul = 0.0
    var solved = false
    
    init(scene: GameScene, indicators: GameIndicators) {
        self.indicators = indicators
        
        self.nbPatternPoints = Utils.randomOdd(inMin:Const.Level.minNbPoints, inMax:Const.Level.maxNbPoints) // odd random integer in range
        let points = Cloud.generateSymmetricRandomPoints(nbPoints: nbPatternPoints)
        
        let radius = 0.5 * Const.Game.sphereDiameterFactor * scene.minSize()
        self.cloud = Cloud(points: points, scene: scene, color: Const.Cloud.color, radius: radius)
        self.cloud.desalign()
        
        self.animateIn()
        
        self.indicators.update(name: IndicatorNames.dots, value: self.getTotalNbDots())
        self.indicators.update(name: IndicatorNames.bonus, value: Const.Level.maxMultiplier, prefix: "x")
    }
    
    func getTotalNbDots() -> Int {
        return 2 * self.nbPatternPoints
    }
    
    func computeMultiplier() -> Int {
        let steps = Const.Level.maxAngleCumul / Scalar(Const.Level.maxMultiplier - 1)
        let multiplier = Const.Level.maxMultiplier - Int(angleCumul / steps)
        return max(1, multiplier)
    }
    
    func rotate(dir: Vector3d, speed: Scalar = 1) {
        let q = Utils.quaternionFromDir(dir: dir, speed: speed)
        self.cloud.rotate(quaternion: q)
        
        self.angleCumul += q.angle
        self.indicators.update(name: IndicatorNames.bonus, value: self.computeMultiplier(), prefix: "x")
    }
    
    func solve() {
        self.solved = true

        let dir = Const.Cloud.alignedOrientation - self.cloud.orientation
        self.cloud.rotate(dir: dir)
        
        self.animateOut()
    }
    
    func computeScore() -> Int {
        return self.getTotalNbDots() * self.computeMultiplier()
    }
    
    func animateIn() {
        for dot in self.cloud.dots {
            dot.node.setScale(0)
            dot.node.run(SKAction.scale(to: 1, duration: 0.2))
        }
    }
    
    func animateOut() {
        for dot in self.cloud.dots {
            let expand = SKAction.group([
                SKAction.fadeAlpha(to: 0.9, duration: 0.05),
                SKAction.scale(to: 1.5, duration: 0.05)
            ])
            
            let back = SKAction.group([
                SKAction.fadeAlpha(to: 1.0, duration: 0.05),
                SKAction.scale(to: 1.0, duration: 0.05)
            ])
            
            let collapse = SKAction.group([
                SKAction.fadeAlpha(to: 0.0, duration: 0.2),
                SKAction.scale(to: 0, duration: 0.2)
            ])
            
            let animation = SKAction.sequence([
                expand,
                back,
                SKAction.wait(forDuration: 0.3),
                collapse
            ])

            dot.node.run(animation)
        }
    }
}
