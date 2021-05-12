//
//  Game.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class Game {
    var level: Level!
    var indicators: GameIndicators!
    var score = 0
    var left = Const.Game.maxLevel
    var isGameEnded = false
    
    init(scene: GameScene) {
        self.indicators = GameIndicators(scene: scene)
        self.level = Level(scene: scene, indicators: self.indicators)
        self.indicators.update(name: IndicatorNames.score, value: 0)
        self.indicators.update(name: IndicatorNames.left, value: self.left)
    }
    
    func checkIfLevelSolved() {
        if self.level.cloud.isAligned() {
            self.level.solve()
            
            let levelScore = self.level.computeScore()
            self.score += levelScore
            self.indicators.update(name: IndicatorNames.score, value: levelScore, prefix: "+", highlight: true)
        }
    }
    
    func newLevelIfNecessary(scene: GameScene) {
        if self.level.solved {
            self.left -= 1
            
            if self.left <= 0 {
                self.isGameEnded = true
            } else {
                self.level = Level(scene: scene, indicators: self.indicators)
                self.indicators.update(name: IndicatorNames.score, value: self.score)
                self.indicators.update(name: IndicatorNames.left, value: self.left)
            }
        }
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
