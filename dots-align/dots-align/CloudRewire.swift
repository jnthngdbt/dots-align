//
//  CloudRewire.swift
//  dots-align
//
//  Created by Jonathan on 2021-07-23.
//

import Foundation
import SpriteKit

class CloudRewire: CloudWithDerps {
    init(nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, addGuides: Bool = false) {
        super.init(
            nbPoints: nbPoints,
            scene: scene,
            color: color,
            radius: radius,
            dotRadius: dotRadius,
            nbPointsDerp: nbPoints, // <-
            derpSizeRatio: 1.0, // <-
            addGuides: addGuides)
    }
}

