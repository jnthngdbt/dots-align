//
//  CloudShadow.swift
//  dots-align
//
//  Created by Jonathan on 2021-07-01.
//

import Foundation
import SpriteKit

class CloudShadow: Cloud {
    init(nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, addGuides: Bool = false) {
        super.init(
            nbPoints: nbPoints,
            scene: scene,
            color: color,
            radius: radius,
            dotRadius: dotRadius,
            addGuides: addGuides,
            mustShadow: true) // <-
    }
}
