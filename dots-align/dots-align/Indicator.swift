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

    init(scene: GameScene, idx: Int) {
        let h = scene.size.height
        let w = scene.size.width

        let labelPosY = h * (1 - 0.05)
        let dataPosY = labelPosY - 0.08 * scene.minSize()

        let nbIndicators = IndicatorNames.allCases.count
        let posX = w * CGFloat(idx + 1) / CGFloat(nbIndicators + 1)
        
        label.position = CGPoint(x: posX, y: labelPosY)
        data.position = CGPoint(x: posX, y: dataPosY)

        label.fontSize = 0.04 * scene.minSize()
        data.fontSize = 0.08 * scene.minSize()

        label.fontName = Const.fontName
        data.fontName = Const.fontName

        label.fontColor = Const.Indicators.fontColor
        data.fontColor = Const.Indicators.fontColor

        scene.addChild(label)
        scene.addChild(data)
    }

    func updateData(value: Int, prefix: String = "", highlight: Bool = false) {
        self.data.text = prefix + String(value)
        if highlight {
            self.data.fontColor = Const.Indicators.fontColorHighlight
        } else {
            self.data.fontColor = Const.Indicators.fontColor
        }
    }
    
    deinit {
        self.label.removeFromParent()
        self.data.removeFromParent()
    }
}