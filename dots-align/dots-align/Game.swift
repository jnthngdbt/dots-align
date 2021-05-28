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
    var level: Level!
    var indicators: GameIndicators?
    var tutorialInstructions: TutorialInstructions?
    var score = 0
    var left = Const.Game.maxLevel
    var ended = false
    var levelScoreLabel: SKLabelNode!
    var levelScoreLabelStartPos: CGPoint!
    var levelScoreLabelEndPos: CGPoint!
    
    init(scene: GameScene, mode: GameMode) {
        self.mode = mode
    
        if mode == GameMode.tutorial {
            self.indicators = nil
            self.tutorialInstructions = TutorialInstructions(scene: scene)
        } else {
            self.indicators = GameIndicators(scene: scene, mode: mode)
            self.tutorialInstructions = nil
        }
        
        switch self.mode {
        case GameMode.level: self.left = Const.Game.maxLevel
        case GameMode.time: self.left = Const.Game.maxSeconds
        default: self.left = 1
        }
        
        self.indicators?.indicators[IndicatorNames.left.rawValue].gauge?.maximum = CGFloat(self.left)
        self.indicators?.indicators[IndicatorNames.dots.rawValue].gauge?.maximum = 2.0 * CGFloat(Const.Game.maxNbPoints)
        self.indicators?.indicators[IndicatorNames.boost.rawValue].gauge?.minimum = 1.0
        self.indicators?.indicators[IndicatorNames.boost.rawValue].gauge?.maximum = CGFloat(Const.Level.maxMultiplier)
        self.indicators?.indicators[IndicatorNames.score.rawValue].gauge?.maximum = 1000 // TODO best score
        
        self.indicators?.update(name: IndicatorNames.left, value: self.left)
        self.indicators?.update(name: IndicatorNames.dots, value: 0)
        self.indicators?.update(name: IndicatorNames.boost, value: Const.Level.maxMultiplier)
        self.indicators?.update(name: IndicatorNames.score, value: 0)
        
        self.level = Level(scene: scene, nbPatternPoints: Const.Game.startNbPoints, indicators: self.indicators, mode: mode)
        
        self.levelScoreLabelStartPos = scene.center()
        self.levelScoreLabelEndPos = scene.center()
        self.levelScoreLabelEndPos.y += (0.5 * Const.Game.sphereDiameterFactor + 0.05) * scene.minSize()
        self.levelScoreLabel = SKLabelNode(text: "0")
        self.levelScoreLabel.fontColor = UIColor(white: 0.6, alpha: 1)
        self.levelScoreLabel.fontName = Const.fontNameLabel
        self.levelScoreLabel.fontSize = 0.12 * scene.minSize()
        self.levelScoreLabel.position = self.levelScoreLabelStartPos
        self.levelScoreLabel.alpha = 0 // start hidden
        scene.addChild(self.levelScoreLabel)
    }
    
    func checkIfLevelSolved() {
        if self.level.cloud.isAligned() {
            self.level.solve()
            
            let levelScore = self.level.computeScore()
            self.score += levelScore
            
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
            
            self.level = Level(scene: scene, nbPatternPoints: self.getNextLevelNbPatternPoints(), indicators: self.indicators, mode: self.mode)
        }
    }
    
    func getNextLevelNbPatternPoints() -> Int {
        if self.mode == .tutorial {
            return Utils.randomOdd(inMin:Const.Game.minNbPoints, inMax:Const.Game.maxNbPoints)
        }
            
        var angleRatio = 1.0 - self.level.angleCumul / Const.Level.maxAngleCumul
        angleRatio = max(0.0, angleRatio)
        let minPoints = Scalar(Const.Game.minNbPoints)
        let maxPoints = Scalar(Const.Game.maxNbPoints)
        let nbPatternPoints = minPoints + angleRatio * (maxPoints - minPoints)
            
        return Int(nbPatternPoints)
    }
    
    func updateLevelScoreLabel(levelScore: Int) {
        self.levelScoreLabel.text = String(levelScore)
        
        let animation = SKAction.sequence([
            SKAction.move(to: self.levelScoreLabelStartPos, duration: 0),
            SKAction.group([
                SKAction.move(to: self.levelScoreLabelEndPos, duration: Const.Animation.scoreRiseSec),
                SKAction.fadeAlpha(to: 0.6, duration: Const.Animation.scoreRiseSec)
            ]),
            SKAction.fadeAlpha(to: 1.0, duration: Const.Animation.blinkSec),
            SKAction.fadeAlpha(to: 0.6, duration: Const.Animation.blinkSec),
            SKAction.wait(forDuration: Const.Animation.blinkWaitSec),
            SKAction.fadeAlpha(to: 0.0, duration: 0.3),
        ])
        
        self.levelScoreLabel.run(animation)
    }
    
    func timeCountdown() {
        self.left -= 1
        self.indicators?.update(name: IndicatorNames.left, value: self.left)
    }
    
    deinit {
        self.levelScoreLabel.removeFromParent()
    }
}

class GameIndicators {
    var indicators = Array<Indicator>()
    
    init(scene: GameScene, mode: GameMode) {
        for i in 0..<IndicatorNames.allCases.count {
            self.indicators.append(Indicator(scene: scene, idx: i, addGauge: true))
        }
        
        self.indicators[IndicatorNames.left.rawValue].label.text = self.getRemainingTitle(mode: mode)
        self.indicators[IndicatorNames.left.rawValue].data.text = "20"
        
        self.indicators[IndicatorNames.dots.rawValue].label.text = "DOTS"
        self.indicators[IndicatorNames.dots.rawValue].data.text = "0"
        
        self.indicators[IndicatorNames.boost.rawValue].label.text = "BOOST"
        self.indicators[IndicatorNames.boost.rawValue].data.text = "x0"
        
        self.indicators[IndicatorNames.score.rawValue].label.text = "SCORE"
        self.indicators[IndicatorNames.score.rawValue].data.text = "0"
    }
    
    func getRemainingTitle(mode: GameMode) -> String {
        switch mode {
        case .level: return "LEVEL"
        case .time: return "TIME"
        default: return "LEFT"
        }
    }
    
    func update(name: IndicatorNames, value: Int, gaugeValue: CGFloat? = nil, prefix: String = "", highlight: Bool = false) {
        if indicators.count > name.rawValue {
            indicators[name.rawValue].updateData(value: value, gaugeValue: gaugeValue, prefix: prefix, highlight: highlight)
        }
    }
    
    func animate(action: SKAction) {
        for i in self.indicators {
            i.animate(action: action)
        }
    }
}
