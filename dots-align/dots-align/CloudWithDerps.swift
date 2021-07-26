//
//  CloudWithDerps.swift
//  dots-align
//
//  Created by Jonathan on 2021-06-30.
//

import Foundation
import SpriteKit

class CloudWithDerps: Cloud {
    var derps = Array<Dot>()
    
    init(nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, nbPointsDerp: Int, derpSizeRatio: CGFloat, addGuides: Bool = false) {
        
        super.init(
            nbPoints: nbPoints - nbPointsDerp,
            scene: scene,
            color: color,
            radius: radius,
            dotRadius: dotRadius,
            addGuides: addGuides,
            mustShadow: false)
        
        let pointsDerps = Cloud.generateSymmetricRandomPoints(nbPoints: nbPointsDerp)
        
        for p in pointsDerps {
            derps.append(Dot(scene: scene, color: color, point3d: p, radius: derpSizeRatio * dotRadius, sphereRadius: radius))
        }
    }
    
    override func rotate(quaternion: Quat) {
        super.rotate(quaternion: quaternion)
        
        let quaternionDerp = simd_quatd(angle: quaternion.angle, axis: simd_cross(quaternion.axis, Vector3d(0, 0, -1)))
        for derp in self.derps {
            derp.rotate(quaternion: quaternionDerp)
        }
    }
    
    override func animate(action: SKAction) {
        super.animate(action: action)
        
        for derp in self.derps {
            derp.animate(action: action)
        }
    }
    
    override func clear() {
        super.clear()
        
        for derp in self.derps {
            derp.node.removeFromParent()
        }
        
        self.derps.removeAll()
    }
}
