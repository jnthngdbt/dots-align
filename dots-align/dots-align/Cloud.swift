//
//  Cloud.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class Cloud {
    var dots = Array<Dot>()
    var derps = Array<Dot>()
    var orientation = Vector3d(0, 0, 1)
    var alignedDist = 0.0
    let radius: CGFloat
    
    init(nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, addGuides: Bool = false, isTypeDerp: Bool = false, isTypeDerpHard: Bool = false, isTypeShadow: Bool = false) {
        self.radius = radius
        
        let mustDerp = isTypeDerp || isTypeDerpHard
        let points = Cloud.generateSymmetricRandomPoints(nbPoints: mustDerp ? nbPoints / 2 : nbPoints)
        
        for p in points {
            dots.append(Dot(scene: scene, color: color, point3d: p, radius: dotRadius, sphereRadius: radius, mustShadow: isTypeShadow))
        }
        
        if (mustDerp) {
            let pointsDerps = Cloud.generateSymmetricRandomPoints(nbPoints: nbPoints - nbPoints / 2)
            let dotSizeRatio: CGFloat = isTypeDerpHard ? 1.0 : 0.5
            
            for p in pointsDerps {
                derps.append(Dot(scene: scene, color: color, point3d: p, radius: dotSizeRatio * dotRadius, sphereRadius: radius, mustShadow: isTypeShadow))
            }
        }
        
        if Const.Debug.showGuideDots || addGuides {
            dots.append(Dot(scene: scene, color: Const.Cloud.guideDotsColor, point3d: Const.Cloud.alignedOrientation, radius: 0.5 * dotRadius, sphereRadius: radius))
            dots.append(Dot(scene: scene, color: Const.Cloud.guideDotsColor, point3d: -Const.Cloud.alignedOrientation, radius: 0.5 * dotRadius, sphereRadius: radius))
        }
    }
    
    class func generateSymmetricRandomPoints(nbPoints: Int) -> Array<Vector3d> {
        var points = Array<Vector3d>()
        
        if nbPoints > 0 {
            for _ in 1...nbPoints {
                // Uniform distribution in 3d is a cube.
                // No spherical symmetry, but creates interesting patterns mapped on a sphere.
                // For spherical symmetry, use normal distribution
                let x = Utils.randomCoordinateNonZero()
                let y = Utils.randomCoordinateNonZero()
                let z = Utils.randomCoordinateNonZero()
                
                points.append(simd_normalize(Vector3d(x, y, z)))
                points.append(simd_normalize(Vector3d(x, y, -z)))
            }
        }
        
        return points
    }
    
    func rotate(dir: Vector3d, speed: Scalar = 1) {
        let q = Utils.quaternionFromDir(dir: dir, speed: speed)
        self.rotate(quaternion: q)
    }
    
    func rotate(quaternion: Quat) {
        self.orientation = quaternion.act(self.orientation)
        
        if self.orientation.z < 0 {
            self.orientation *= -1
        }
        
        self.alignedDist = simd_distance(self.orientation, Const.Cloud.alignedOrientation)
        
        for dot in self.dots {
            dot.rotate(quaternion: quaternion)
        }
        
        let quaternionDerp = simd_quatd(angle: quaternion.angle, axis: simd_cross(quaternion.axis, Vector3d(0, 0, -1)))
        for derp in self.derps {
            derp.rotate(quaternion: quaternionDerp)
        }
    }
    
    func desalign() {
        let eps = 2 * Const.Cloud.alignedDistThresh // make sure to not start aligned
        let x = Utils.randomCoordinateNonZero(eps: eps)
        let y = Utils.randomCoordinateNonZero(eps: eps)
        let z = 1.0
        let p = simd_normalize(Vector3d(x,y,z))
        
        let dir = p - Const.Cloud.alignedOrientation
        
        self.rotate(dir: dir)
    }
    
    func isAligned() -> Bool {
        return self.alignedDist < Const.Cloud.alignedDistThresh
    }
    
    func animate(action: SKAction) {
        for dot in self.dots {
            dot.animate(action: action)
        }
        
        for derp in self.derps {
            derp.animate(action: action)
        }
    }
    
    func clear() {
        self.orientation = Const.Cloud.alignedOrientation
        self.alignedDist = 0
        
        for dot in self.dots {
            dot.node.removeFromParent()
        }
        
        for derp in self.derps {
            derp.node.removeFromParent()
        }
        
        self.dots.removeAll()
        self.derps.removeAll()
    }
}
