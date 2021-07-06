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
    var orientation = Vector3d(0, 0, 1)
    var alignedDist = 0.0
    let radius: CGFloat
    
    init(nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, addGuides: Bool = false, mustShadow: Bool = false) {
        self.radius = radius
        
        let points = Cloud.generateSymmetricRandomPoints(nbPoints: nbPoints)
        
        for p in points {
            dots.append(Dot(scene: scene, color: color, point3d: p, radius: dotRadius, sphereRadius: radius, mustShadow: mustShadow))
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
    }
    
    func desalign() {
        let eps = 2 * Const.Cloud.alignedDistThresh // make sure to not start aligned
        let x = Utils.randomCoordinateNonZero(eps: eps)
        let y = Utils.randomCoordinateNonZero(eps: eps)
        self.desalign(x: x, y: y)
    }
    
    func desalign(x: Scalar, y: Scalar) {
        let p = simd_normalize(Vector3d(x, y, 1)) // project on unit sphere from z = 1 plane
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
    }
    
    func clear() {
        self.orientation = Const.Cloud.alignedOrientation
        self.alignedDist = 0
        
        for dot in self.dots {
            dot.node.removeFromParent()
        }
        
        self.dots.removeAll()
    }
}
