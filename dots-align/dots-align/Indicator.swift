//
//  Indicator.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class Indicator {
    var label = SKLabelNode(text: "LABEL")
    var data = SKLabelNode(text: "DATA")
    var gauge: ProgressBar?

    init(scene: GameScene, idx: Int, addGauge: Bool = false) {
        let padding = Const.Indicators.sidePaddingFactor * scene.minSize() // left and right padding, indicators are centered and distributed on remaining
        let nbIndicators = IndicatorNames.allCases.count
        let posX = padding + (scene.size.width - 2.0 * padding) * CGFloat(idx) / CGFloat(nbIndicators - 1)
        
        // Layout indicators on a circle.
        let normalizedPosX = posX - scene.center().x
        let layoutRadius = Const.Indicators.layoutSphereFactor * Const.Cloud.sphereDiameterFactor * scene.minSize()
        let dataPosY = sqrt(layoutRadius * layoutRadius - normalizedPosX * normalizedPosX) + scene.center().y
        let labelPosY = dataPosY + Const.Indicators.verticalSpacingFactor * scene.minSize()
        
        label.position = CGPoint(x: posX, y: labelPosY)
        data.position = CGPoint(x: posX, y: dataPosY)

        label.fontSize = 0.04 * scene.minSize()
        data.fontSize = 0.08 * scene.minSize()

        label.fontName = Const.fontNameLabel
        data.fontName = Const.fontNameLabel

        label.fontColor = Const.Indicators.fontColor
        data.fontColor = Const.Indicators.fontColor

        scene.addChild(label)
        scene.addChild(data)
        
        if addGauge {
            let gaugeWidth = Const.Indicators.gaugeWidthFactor * scene.minSize()
            let gaugeHeight = Const.Indicators.gaugeHeightFactor * scene.minSize()
            let gaugePosX = posX
            let gaugePosY = dataPosY - 0.03 * scene.minSize()
            let rect = CGRect(x: gaugePosX, y: gaugePosY, width: gaugeWidth, height: gaugeHeight)
            self.gauge = ProgressBar(scene: scene, rect: rect)
        }
    }

    func updateData(value: Int, gaugeValue: CGFloat? = nil, prefix: String = "", highlight: Bool = false) {
        
        let gauge = gaugeValue == nil ? CGFloat(value) : gaugeValue
        
        let text = prefix + String(value)
        let isNewText = self.data.text != text
        self.data.text = text
        
        if highlight {
            self.data.fontColor = Const.Indicators.fontColorHighlight
        } else {
            self.data.fontColor = Const.Indicators.fontColor
        }
        
        if isNewText {
            self.animateBounce()
        }
        
        self.gauge?.setValue(value: gauge!)
    }
    
    func animateBounce(waitSec: TimeInterval = 0.0) {
        let animation = SKAction.sequence([
            SKAction.wait(forDuration: waitSec),
            SKAction.scale(to: 1.3, duration: Const.Animation.blinkSec),
            SKAction.scale(to: 1.0, duration: Const.Animation.blinkSec)
        ])
        
        self.data.run(animation)
    }
    
    func animate(_ action: SKAction) {
        self.label.run(action)
        self.data.run(action)
        self.gauge?.animate(action)
    }
    
    deinit {
        self.label.removeFromParent()
        self.data.removeFromParent()
    }
}
