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
    var indicators: GameIndicators?
    
    var nbPatternPoints = 0
    var angleCumul = 0.0
    var ended = false
    
    init(scene: GameScene, nbPatternPoints: Int, indicators: GameIndicators?, mode: GameMode) {
        self.indicators = indicators
        
        self.nbPatternPoints = nbPatternPoints
        let points = Cloud.generateSymmetricRandomPoints(nbPoints: nbPatternPoints)
        
        let radius = 0.5 * Const.Game.sphereDiameterFactor * scene.minSize()
        let dotRadius = Const.Dot.radiusFactor * scene.minSize()
        let color = mode == .tutorial ? Const.Tutorial.dotsColor : Const.Cloud.color
        self.cloud = Cloud(points: points, scene: scene, color: color, radius: radius, dotRadius: dotRadius, addGuides: mode == GameMode.tutorial)
        self.cloud.desalign()
        
        self.indicators?.update(name: IndicatorNames.dots, value: self.getTotalNbDots())
        self.indicators?.update(name: IndicatorNames.boost, value: Int(Const.Level.maxMultiplier), prefix: "x")
    }
    
    func getTotalNbDots() -> Int {
        return 2 * self.nbPatternPoints
    }
    
    func computeMultiplier() -> CGFloat {
        let steps = Const.Level.maxAngleCumul / Scalar(Const.Level.maxMultiplier - 1)
        let multiplier = Scalar(Const.Level.maxMultiplier) - self.angleCumul / steps
        return CGFloat(max(1.0, multiplier))
    }
    
    func computeMultiplierInt() -> Int {
        return Int(ceil(self.computeMultiplier()))
    }
    
    func rotate(dir: Vector3d, speed: Scalar = 1) {
        let q = Utils.quaternionFromDir(dir: dir, speed: speed)
        self.cloud.rotate(quaternion: q)
        
        self.angleCumul += q.angle
        self.indicators?.update(name: IndicatorNames.boost, value: self.computeMultiplierInt(), gaugeValue: self.computeMultiplier(), prefix: "x")
    }
    
    func solve() {
        self.ended = true

        let dir = Const.Cloud.alignedOrientation - self.cloud.orientation
        self.cloud.rotate(dir: dir)
        
        self.animateOut()
    }
    
    func computeScore() -> Int {
        return self.getTotalNbDots() * self.computeMultiplierInt()
    }
    
    func animateIn() {
        let animation = SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.0),
            SKAction.wait(forDuration: 0.2),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.cloud.animate(action: animation)
    }
    
    func animateOut() {
        self.animateOutCloud()
    }
    
    private func animateOutCloud() {
        let expand = SKAction.group([
            SKAction.fadeAlpha(to: 0.9, duration: Const.Animation.blinkSec),
            SKAction.scale(to: 1.5, duration: Const.Animation.blinkSec)
        ])
        
        let back = SKAction.group([
            SKAction.fadeAlpha(to: 1.0, duration: Const.Animation.blinkSec),
            SKAction.scale(to: 1.0, duration: Const.Animation.blinkSec)
        ])
        
        let collapse = SKAction.group([
            SKAction.fadeAlpha(to: 0.0, duration: Const.Animation.collapseSec),
            SKAction.scale(to: 0, duration: Const.Animation.collapseSec)
        ])
        
        let animation = SKAction.sequence([
            expand,
            back,
            SKAction.wait(forDuration: Const.Animation.blinkWaitSec),
            collapse
        ])

        self.cloud.animate(action: animation)
    }
}
