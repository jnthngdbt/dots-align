//
//  GameIndicators.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-06-03.
//

import Foundation
import SpriteKit

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
