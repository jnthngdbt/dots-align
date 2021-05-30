//
//  Indicator.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class ProgressBar {
    var edge: SKShapeNode!
    var fill: SKShapeNode!
    var minimum: CGFloat = 0
    var maximum: CGFloat = 100
    let rect: CGRect
    
    init(scene: GameScene, rect: CGRect) {
        let cornerRadius = 0 * rect.height
        let color = Const.Indicators.fontColor
        
        self.rect = rect
        
        self.edge = SKShapeNode(rectOf: CGSize(width: rect.width, height: rect.height), cornerRadius: cornerRadius)
        self.edge.position = rect.origin
        self.edge.fillColor = UIColor.clear
        self.edge.strokeColor = color
        
        self.fill = SKShapeNode(rectOf: CGSize(width: rect.width, height: rect.height), cornerRadius: cornerRadius)
        self.fill.position = rect.origin
        self.fill.fillColor = color
        self.fill.strokeColor = color
        
        scene.addChild(self.edge)
        scene.addChild(self.fill)
    }
    
    func setValue(value: CGFloat) {
        var ratio = (value - self.minimum) / (self.maximum - self.minimum) // convert to [0, 1] range
        ratio = max(0.0, min(1.0, ratio))
        
        self.fill.xScale = ratio
        self.fill.position.x = rect.origin.x - 0.5 * (1.0 - ratio) * rect.width
    }
    
    func animate(action: SKAction) {
        self.edge.run(action)
        self.fill.run(action)
    }
    
    deinit {
        self.edge.removeFromParent()
        self.fill.removeFromParent()
    }
}

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
        let layoutRadius = Const.Indicators.layoutSphereFactor * Const.Game.sphereDiameterFactor * scene.minSize()
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
            let animation = SKAction.sequence([
                SKAction.scale(to: 1.3, duration: Const.Animation.blinkSec),
                SKAction.scale(to: 1.0, duration: Const.Animation.blinkSec)
            ])
            
            self.data.run(animation)
        }
        
        self.gauge?.setValue(value: gauge!)
    }
    
    func animate(action: SKAction) {
        self.label.run(action)
        self.data.run(action)
        self.gauge?.animate(action: action)
    }
    
    deinit {
        self.label.removeFromParent()
        self.data.removeFromParent()
    }
}
