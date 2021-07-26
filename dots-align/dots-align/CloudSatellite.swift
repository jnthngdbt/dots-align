//
//  CloudSatellite.swift
//  dots-align
//
//  Created by Jonathan on 2021-06-30.
//

import Foundation
import SpriteKit

class CloudSatellite: CloudWithDerps {
    init(nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, addGuides: Bool = false) {
        super.init(
            nbPoints: nbPoints,
            scene: scene,
            color: color,
            radius: radius,
            dotRadius: dotRadius,
            nbPointsDerp: nbPoints / 2,
            derpSizeRatio: 0.5, // <-
            addGuides: addGuides)
    }
}
