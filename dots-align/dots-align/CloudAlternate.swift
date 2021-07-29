//
//  CloudAlternate.swift
//  dots-align
//
//  Created by Jonathan on 2021-07-26.
//

import Foundation
import SpriteKit

class CloudAlternate: Cloud {
    let speed: Scalar = 1.5
    
    var skipDirection = false
    var angleSign = 1.0
    var angleCumul = 0.0
    var direction = Vector3d(0, 1, 0)
    var lastDirection = Vector3d(0, 1, 0)
    
    init(nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, addGuides: Bool = false) {
        super.init(
            nbPoints: nbPoints,
            scene: scene,
            color: color,
            radius: radius,
            dotRadius: dotRadius,
            addGuides: addGuides)
    }
    
    override func desalign(x: Scalar, y: Scalar) {
        self.skipDirection = true
        super.desalign(x: x, y: y)
        self.skipDirection = false
    }
    
    override func rotate(quaternion: Quat) {
        super.rotate(quaternion: quaternion)
        
        if !self.skipDirection {
            let crossVector = quaternion.angle > 0.0 ? Vector3d(0, 0, 1) : Vector3d(0, 0, -1)
            let direction = simd_cross(quaternion.axis, crossVector)
            
            if simd_dot(direction, self.lastDirection) < 0.0 {
                self.angleSign *= -1.0
            }
            
            self.angleCumul += self.angleSign * quaternion.angle
            
            self.lastDirection = direction
        }

        self.updateDotScale()
    }
    
    private func updateDotScale() {
        let scaleA = 1.0 - abs(sin(self.speed * self.angleCumul))
        let scaleB = 1.0 - abs(cos(self.speed * self.angleCumul))
        
        for i in 0..<self.dots.count {
            let scale = (i < self.dots.count / 2) ? scaleA : scaleB
            self.dots[i].setRadius(radius: self.dots[i].baseRadius * CGFloat(scale))
            self.dots[i].node.alpha = CGFloat(scale * 1.5)
        }
    }
}
