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
    var indicators: GameIndicators!
    var score = 0
    var left = Const.Game.maxLevel
    var isGameEnded = false
    var levelScoreLabel: SKLabelNode!
    
    init(scene: GameScene, mode: GameMode) {
        self.mode = mode
        self.indicators = GameIndicators(scene: scene)
        self.level = Level(scene: scene, indicators: self.indicators)
        
        switch self.mode {
        case GameMode.level: self.left = Const.Game.maxLevel
        case GameMode.time: self.left = Const.Game.maxSeconds
        default: self.left = 1
        }
        
        self.indicators.update(name: IndicatorNames.score, value: 0)
        self.indicators.update(name: IndicatorNames.left, value: self.left)
        
        var pos = scene.center()
        pos.y += (0.5 * Const.Game.sphereDiameterFactor + 0.05) * scene.minSize()
        self.levelScoreLabel = SKLabelNode(text: "0")
        self.levelScoreLabel.fontColor = UIColor(white: 0.6, alpha: 1)
        self.levelScoreLabel.fontName = Const.fontName
        self.levelScoreLabel.fontSize = 0.08 * scene.minSize()
        self.levelScoreLabel.position = pos
        self.levelScoreLabel.alpha = 0 // start hidden
        scene.addChild(self.levelScoreLabel)
    }
    
    func checkIfLevelSolved() {
        if self.level.cloud.isAligned() {
            self.level.solve()
            self.updateLevelScoreLabel()
        }
    }
    
    func newLevelIfNecessary(scene: GameScene) {
        if self.level.solved {
            if self.mode == GameMode.level {
                self.left -= 1
                
                self.indicators.update(name: IndicatorNames.left, value: self.left)
                
                if self.left <= 0 {
                    self.isGameEnded = true
                    return
                }
            }
            
            self.level = Level(scene: scene, indicators: self.indicators)
            self.indicators.update(name: IndicatorNames.score, value: self.score)
        }
    }
    
    func updateLevelScoreLabel() {
        let levelScore = self.level.computeScore()
        self.score += levelScore
        self.levelScoreLabel.text = String(levelScore)
        
        let animation = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: Const.Animation.blinkSec),
            SKAction.fadeAlpha(to: 0.6, duration: Const.Animation.blinkSec),
            SKAction.wait(forDuration: Const.Animation.blinkWaitSec),
            SKAction.fadeAlpha(to: 0.0, duration: 0.3),
        ])
        
        self.levelScoreLabel.run(animation)
    }
    
    func timeCountdown() {
        self.left -= 1
        self.indicators.update(name: IndicatorNames.left, value: self.left)
    }
    
    deinit {
        self.levelScoreLabel.removeFromParent()
    }
}

class GameIndicators {
    var indicators = Array<Indicator>()
    
    init(scene: GameScene) {
        for i in 0..<IndicatorNames.allCases.count {
            self.indicators.append(Indicator(scene: scene, idx: i))
        }
        
        self.indicators[IndicatorNames.left.rawValue].label.text = "LEFT"
        self.indicators[IndicatorNames.left.rawValue].data.text = "20"
        
        self.indicators[IndicatorNames.dots.rawValue].label.text = "DOTS"
        self.indicators[IndicatorNames.dots.rawValue].data.text = "0"
        
        self.indicators[IndicatorNames.bonus.rawValue].label.text = "BONUS"
        self.indicators[IndicatorNames.bonus.rawValue].data.text = "x0"
        
        self.indicators[IndicatorNames.score.rawValue].label.text = "SCORE"
        self.indicators[IndicatorNames.score.rawValue].data.text = "0"
    }
    
    func update(name: IndicatorNames, value: Int, prefix: String = "", highlight: Bool = false) {
        if indicators.count > name.rawValue {
            indicators[name.rawValue].updateData(value: value, prefix: prefix, highlight: highlight)
        }
    }
}
