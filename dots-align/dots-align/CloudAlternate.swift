//
//  CloudAlternate.swift
//  dots-align
//
//  Created by Jonathan on 2021-07-26.
//

import Foundation
import SpriteKit

class CloudAlternate: Cloud {
    let peakSpacingAngle = 0.45 * Scalar.pi // note: may become weird when to high, something breaks
    var lastPeakPos = Vector3d(0, 0, 0)
    var debugLastPeakDot: Dot?
    
    init(nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, addGuides: Bool = false) {
        if Const.Debug.showCloudDebug {
            self.debugLastPeakDot = Dot(scene: scene, color: UIColor.red, point3d: Const.Cloud.alignedOrientation, radius: 0.5 * dotRadius, sphereRadius: radius)
            self.debugLastPeakDot?.node.setScale(1)
        }
        
        super.init(
            nbPoints: nbPoints,
            scene: scene,
            color: color,
            radius: radius,
            dotRadius: dotRadius,
            addGuides: addGuides)
    }
    
    override func desalign(x: Scalar, y: Scalar) {
        super.desalign(x: x, y: y)
        self.updatePeakPos() // init peak pos
        self.updateDotScale()
    }
    
    override func rotate(quaternion: Quat) {
        super.rotate(quaternion: quaternion)
        self.updateDotScale()
    }
    
    private func updatePeakPos() {
        self.lastPeakPos = self.orientation
        
        self.debugLastPeakDot?.point = self.lastPeakPos
        self.debugLastPeakDot?.update()
    }
    
    private func updateDotScale() {
        let dot = abs(simd_dot(self.orientation, self.lastPeakPos))
        let angleBetweenVectors = dot < 1.0 ? acos(dot) : 0 // acos assumes both vectors were normalized
        let vectorToPeakSpacingAngle = Scalar.pi * angleBetweenVectors / self.peakSpacingAngle
        
        let scaleA = 1.0 - abs(sin(vectorToPeakSpacingAngle))
        let scaleB = 1.0 - abs(cos(vectorToPeakSpacingAngle))
        
        for i in 0..<self.dots.count {
            let scale = (i <= self.dots.count / 2) ? scaleA : scaleB
            self.dots[i].setRadius(radius: self.dots[i].baseRadius * CGFloat(scale))
        }
        
        // Reset source position when peak reached.
        if angleBetweenVectors >= self.peakSpacingAngle {
            self.updatePeakPos()
        }
    }
}
