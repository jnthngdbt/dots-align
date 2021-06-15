//
//  Game.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class Game {
    let mode: GameMode
    var orb: Orb?
    var level: Level!
    var indicators: GameIndicators?
    var instructions: Instructions?
    var homeButton: FooterHomeButton!
    var left = Const.Game.maxLevel
    var ended = false
    var levelScoreLabel: SKLabelNode!
    var levelScoreLabelStartPos: CGPoint!
    var levelScoreLabelEndPos: CGPoint!
    
    // Results
    var score = 0
    var nbCompletedLevels = 0
    var sumNbDots = 0
    var sumRotationRad = 0.0
    var sumBoost = 0
    
    init(scene: GameScene, mode: GameMode) {
        self.mode = mode
        
        self.homeButton = FooterHomeButton(scene: scene)
        self.orb = Orb(scene: scene)
        
        switch self.mode {
        case GameMode.level: self.left = Const.Game.maxLevel
        case GameMode.time: self.left = Const.Game.maxSeconds
        default: self.left = 1
        }
        
        if mode == GameMode.tutorial {
            self.indicators = nil
            self.instructions = InstructionsGetStarted(scene: scene)
        } else {
            self.indicators = GameIndicators(scene: scene, mode: mode, left: self.left)
            self.instructions = InstructionsHowItWorks(scene: scene)
        }
        
        self.initLevelScoreLabel(scene: scene)
        self.level = Level(scene: scene, nbPatternPoints: Const.Game.startNbPoints, indicators: self.indicators, mode: mode)
    }
    
    func initLevelScoreLabel(scene: GameScene) {
        self.levelScoreLabelStartPos = scene.center()
        self.levelScoreLabelEndPos = scene.center()
        self.levelScoreLabelEndPos.y += (0.5 * Const.Game.sphereDiameterFactor + Const.Level.levelScoreEndPosOffsetFactor) * scene.minSize()
        self.levelScoreLabel = SKLabelNode(text: "0")
        self.levelScoreLabel.fontColor = labelColor
        self.levelScoreLabel.fontName = Const.fontNameLabel
        self.levelScoreLabel.fontSize = Const.Level.levelScoreFontSizeFactor * scene.minSize()
        self.levelScoreLabel.position = self.levelScoreLabelStartPos
        self.levelScoreLabel.alpha = 0 // start hidden
        scene.addChild(self.levelScoreLabel)
    }
    
    func animateIn(waitSec: TimeInterval = 0.0) {
        // Start hidden.
        self.level.cloud.animate(action: SKAction.scale(to: 0, duration: 0.0))
        self.indicators?.animate(action: SKAction.fadeAlpha(to: 0, duration: 0.0))
        self.orb?.node.run(SKAction.scale(to: 0, duration: 0.0))
        self.homeButton?.animate(action: SKAction.scale(to: 0, duration: 0.0))
        self.instructions?.button.animate(action: SKAction.scale(to: 0, duration: 0.0))
        self.instructions?.animate(action: SKAction.fadeAlpha(to: 0, duration: 0.0))
        
        // Pop.
        self.instructions?.animate(action: SKAction.sequence([
            SKAction.wait(forDuration: waitSec + 0.2),
            SKAction.fadeAlpha(to: 1, duration: Const.Animation.expandSec)
        ]))
        self.orb?.node.run(SKAction.sequence([
            SKAction.wait(forDuration: waitSec + 0.2),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        self.indicators?.animate(action: SKAction.sequence([
            SKAction.wait(forDuration: waitSec + 0.4),
            SKAction.fadeAlpha(to: 1, duration: Const.Animation.expandSec)
        ]))
        self.homeButton?.animate(action: SKAction.sequence([
            SKAction.wait(forDuration: waitSec + 0.4),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        self.instructions?.button.animate(action: SKAction.sequence([
            SKAction.wait(forDuration: waitSec + 0.4),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        self.level.cloud.animate(action: SKAction.sequence([
            SKAction.wait(forDuration: waitSec + 0.6),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
    }
    
    func checkIfLevelSolved() {
        if self.level.cloud.isAligned() {
            self.level.solve()
            
            let levelScore = self.level.computeScore()
            
            self.score += levelScore
            self.nbCompletedLevels += 1
            self.sumNbDots += self.level.getTotalNbDots()
            self.sumRotationRad += self.level.angleCumul
            self.sumBoost += self.level.getBoostInt()
            
            self.indicators?.update(name: IndicatorNames.score, value: self.score)
            
            if self.mode != GameMode.tutorial {
                self.updateLevelScoreLabel(levelScore: levelScore)
            }
        }
    }
    
    func newLevelIfNecessary(scene: GameScene) {
        if self.level.ended {
            if self.mode == GameMode.level {
                self.left -= 1
                
                self.indicators?.update(name: IndicatorNames.left, value: self.left)
                
                if self.left <= 0 {
                    self.ended = true
                    return
                }
            }
            
            scene.removeAction(forKey: Const.Level.boostCountdownKey)
            self.level = Level(scene: scene, nbPatternPoints: self.getNextLevelNbPatternPoints(), indicators: self.indicators, mode: self.mode)
            self.level.animateIn()
        }
    }
    
    func getNextLevelNbPatternPoints() -> Int {
        if self.mode == .tutorial {
            return Utils.randomOdd(inMin:Const.Game.minNbPoints, inMax:Const.Game.maxNbPoints)
        }
            
        let ratio = Scalar(self.level.boost - 1.0) / Scalar(Const.Level.maxBoost - 1) // -1 since boost starts at 1
        let minPoints = Scalar(Const.Game.minNbPoints)
        let maxPoints = Scalar(Const.Game.maxNbPoints)
        let nbPatternPoints = minPoints + ratio * (maxPoints - minPoints)
            
        return Int(round(nbPatternPoints))
    }
    
    func updateLevelScoreLabel(levelScore: Int) {
        self.levelScoreLabel.text = String(levelScore)
        
        let animation = SKAction.sequence([
            SKAction.move(to: self.levelScoreLabelStartPos, duration: 0),
            SKAction.group([
                SKAction.move(to: self.levelScoreLabelEndPos, duration: Const.Animation.scoreRiseSec),
                SKAction.fadeAlpha(to: 1.0, duration: Const.Animation.scoreRiseSec)
            ]),
            SKAction.wait(forDuration: Const.Animation.scoreRiseWaitSec),
            SKAction.fadeAlpha(to: 0.0, duration: 0.3),
        ])
        
        self.levelScoreLabel.run(animation)
    }
    
    func timeCountdown() {
        self.left -= 1
        self.indicators?.update(name: IndicatorNames.left, value: self.left)
    }
    
    func end() -> GameEntity? {
        self.ended = true
        return DatabaseManager.addGameResult(game: self)
    }
    
    deinit {
        self.levelScoreLabel.removeFromParent()
    }
}
