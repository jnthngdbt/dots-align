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
    var mode: GameMode
    
    var nbPatternPoints = 0
    var angleCumul = 0.0
    var ended = false
    var boost: CGFloat = 1.0
    
    init(scene: GameScene, nbPatternPoints: Int, indicators: GameIndicators?, mode: GameMode) {
        self.indicators = indicators
        self.mode = mode
        
        self.nbPatternPoints = nbPatternPoints
        
        let radius = 0.5 * Const.Game.sphereDiameterFactor * scene.minSize()
        let dotRadius = Const.Dot.radiusFactor * scene.minSize()
        let color = mode == .tutorial ? Const.Tutorial.dotsColor : Const.Cloud.color
        let isTypeDerp = Scalar.random(in: 0...1) < Const.Cloud.typeDerpProb
        let isTypeDerpHard = Scalar.random(in: 0...1) < Const.Cloud.typeDerpHardProb
        let isTypeShadow = Scalar.random(in: 0...1) < Const.Cloud.typeShadowProb
        
        self.cloud = Cloud(nbPoints: nbPatternPoints, scene: scene, color: color, radius: radius, dotRadius: dotRadius, addGuides: mode == GameMode.tutorial, isTypeDerp: isTypeDerp, isTypeDerpHard: isTypeDerpHard, isTypeShadow: isTypeShadow)
        self.cloud.desalign()
        
        self.boost = CGFloat(Const.Level.maxBoost)
        
        self.indicators?.update(name: IndicatorNames.dots, value: self.getTotalNbDots())
        self.indicators?.update(name: IndicatorNames.boost, value: self.getBoostInt(), prefix: "x")
        
        if mode == .time && Const.Level.makeBoostDecreaseWithTimeInTimeGame {
            self.startBoostCountdown(scene: scene, maxBoost: Const.Level.maxBoost)
        }
    }
    
    func startBoostCountdown(scene: GameScene, maxBoost: Int) {
        let boostStep = CGFloat(maxBoost - 1) / CGFloat(Const.Level.boostCountdownNbSteps)
        let waitSec = Const.Level.boostCountdownSec / Scalar(Const.Level.boostCountdownNbSteps)
        
        let countdownStep = SKAction.sequence([
            SKAction.wait(forDuration: waitSec),
            SKAction.run({
                self.boost -= boostStep
                print(self.boost)
                self.indicators?.update(name: IndicatorNames.boost, value: self.getBoostInt(), gaugeValue: self.boost, prefix: "x")
            })
        ])
        
        let countdown = SKAction.repeat(countdownStep, count: Const.Level.boostCountdownNbSteps)
        scene.run(countdown, withKey: Const.Level.boostCountdownKey)
    }
    
    func getTotalNbDots() -> Int {
        return 2 * self.nbPatternPoints
    }
    
    func updateBoostFromRotation() {
        let steps = Const.Level.maxAngleCumul / Scalar(Const.Level.maxBoost - 1)
        let multiplier = Scalar(Const.Level.maxBoost) - self.angleCumul / steps
        self.boost = CGFloat(max(1.0, multiplier))
    }
    
    func getBoostInt() -> Int {
        // Ugly hack to deal with numerical precision.
        let isIntPlusEps = self.boost.truncatingRemainder(dividingBy: 1) < 1e-6
        return isIntPlusEps ? Int(self.boost) : Int(ceil(self.boost))
    }
    
    func rotate(dir: Vector3d, speed: Scalar = 1) {
        let q = Utils.quaternionFromDir(dir: dir, speed: speed)
        self.cloud.rotate(quaternion: q)
        
        self.angleCumul += q.angle
        
        if self.mode == .level || ((self.mode == .time) && !Const.Level.makeBoostDecreaseWithTimeInTimeGame) {
            self.updateBoostFromRotation()
            self.indicators?.update(name: IndicatorNames.boost, value: self.getBoostInt(), gaugeValue: self.boost, prefix: "x")
        }
    }
    
    func solve() {
        self.ended = true

        let dir = Const.Cloud.alignedOrientation - self.cloud.orientation
        self.cloud.rotate(dir: dir)
        
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
        self.animateOut()
    }
    
    func computeScore() -> Int {
        return self.getTotalNbDots() * self.getBoostInt()
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
