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
    let maxBoost: Int
    var boost: CGFloat = 1.0
    
    init(scene: GameScene, nbPatternPoints: Int, indicators: GameIndicators?, mode: GameMode, type: GameType) {
        self.indicators = indicators
        self.mode = mode
        
        self.nbPatternPoints = nbPatternPoints
        
        let radius = 0.5 * Const.Level.sphereDiameterFactor * scene.minSize()
        let dotRadius = Const.Level.dotRadiusFactor * scene.minSize()
        let color = mode == .tutorial ? Const.Tutorial.dotsColor : Const.Cloud.color
        
        self.cloud = Utils.makeCloud(
            type: type,
            nbPoints: nbPatternPoints,
            scene: scene,
            color: color,
            radius: radius,
            dotRadius: dotRadius,
            addGuides: mode == GameMode.tutorial)
        
        self.cloud.desalign()
        
        self.maxBoost = getMaxBoost(type: type)
        self.boost = CGFloat(self.maxBoost)
        
        self.indicators?.update(name: IndicatorNames.dots, value: self.getTotalNbDots())
        self.indicators?.update(name: IndicatorNames.boost, value: self.getBoostInt(), prefix: "x")
        
        if mode == .time {
            self.startBoostCountdown(scene: scene, maxBoost: self.maxBoost)
        }
    }
    
    func startBoostCountdown(scene: GameScene, maxBoost: Int) {
        let boostStep = CGFloat(maxBoost - 1) / CGFloat(Const.Level.boostCountdownNbSteps)
        let waitSec = Const.Level.boostCountdownSec / Scalar(Const.Level.boostCountdownNbSteps)
        
        let countdownStep = SKAction.sequence([
            SKAction.wait(forDuration: waitSec),
            SKAction.run({
                self.boost -= boostStep
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
        let multiplier = Scalar(self.maxBoost) - self.angleCumul * Const.Level.boostPerAngle
        self.boost = CGFloat(max(1.0, multiplier))
    }
    
    func getBoostInt() -> Int {
        // Ugly hack to deal with numerical precision.
        let isIntPlusEps = self.boost.truncatingRemainder(dividingBy: 1) < 1e-6
        return isIntPlusEps ? Int(self.boost) : Int(ceil(self.boost))
    }
    
    func rotate(dir: Vector3d, speed: Scalar = 1) {
        let radius = self.cloud.radius
        if radius <= 0 { return }
        let dirNorm = dir / Scalar(radius)
            
        let q = Utils.quaternionFromDir(dir: dirNorm, speed: speed)
        self.cloud.rotate(quaternion: q)
        
        self.angleCumul += q.angle
        
        if self.mode == .level {
            self.updateBoostFromRotation()
            self.indicators?.update(name: IndicatorNames.boost, value: self.getBoostInt(), gaugeValue: self.boost, prefix: "x")
        }
    }
    
    func solve() {
        self.ended = true

        let dir = Const.Cloud.alignedOrientation - self.cloud.orientation
        self.cloud.rotate(dir: dir)
        
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        
        if self.mode != .tutorial {
            self.playBeep()
        }
        
        self.animateOut()
    }
    
    func playBeep() {
        let boostFrac = (self.boost - 1) / (CGFloat(self.maxBoost) - 1) // boost goes from 1 to max
        let nbBeeps = Const.Music.beeps.count
        let beepIdxRaw = Int((boostFrac * CGFloat(nbBeeps))) // nbBeeps - 1 + 1
        let beepIdx = min(nbBeeps - 1, max(0, beepIdxRaw))
        let beepName = Const.Music.beeps[beepIdx]
        Music.instance.playBeep(beepName)
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
