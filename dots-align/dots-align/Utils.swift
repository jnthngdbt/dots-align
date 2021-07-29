//
//  Utils.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

typealias Scalar = Double
typealias Vector2d = SIMD3<Scalar>
typealias Vector3d = SIMD3<Scalar>
typealias Quat = simd_quatd

extension UIColor {
    func toColor(_ color: UIColor, factor: CGFloat) -> UIColor {
        let factor = max(min(factor, 1), 0)
        switch factor {
            case 0: return self
            case 1: return color
            default:
                var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
                guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }
                
                let r = r1 + (r2 - r1) * factor
                let g = g1 + (g2 - g1) * factor
                let b = b1 + (b2 - b1) * factor
                let a = a1 + (a2 - a1) * factor

                return UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }
    
    func scaleRgb(_ scale: CGFloat) -> UIColor {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        
        r = min(1.0, r * scale)
        g = min(1.0, g * scale)
        b = min(1.0, b * scale)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func offsetHue(_ hue: CGFloat, scaleBrightness: CGFloat) -> UIColor {
        var (h, s, v, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        guard self.getHue(&h, saturation: &s, brightness: &v, alpha: &a) else { return self }
        
        h = h + hue
        if h < 0.0 { h = 1.0 - h }
        if h > 1.0 { h = h - 1.0 }
        
        v = min(1.0, v * scaleBrightness)

        return UIColor(hue: h, saturation: s, brightness: v, alpha: a)
    }
    
    func setAlpha(_ alpha: CGFloat) -> UIColor {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}

class Utils {
    class func randomPoint() -> Vector3d {
        let x = Utils.randomCoordinateNonZero()
        let y = Utils.randomCoordinateNonZero()
        let z = Utils.randomCoordinateNonZero()
        let p = Vector3d(x,y,z)
        return simd_normalize(p)
    }
    
    class func randomCoordinateNonZero(eps: Scalar = 0.001) -> Scalar {
        return self.randomSign() * Scalar.random(in: eps...1)
    }
    
    class func randomSign() -> Scalar {
        return Bool.random() ? 1 : -1
    }
    
    class func randomOdd(inMin: Int, inMax: Int) -> Int {
        return 2 * Int.random(in: inMin/2...inMax/2)
    }
    
    class func quaternionFromDir(dir: Vector3d, speed: Scalar = 1) -> Quat {
        let norm = simd_length(dir)
        
        if norm > 0 && norm < 1 { // avoid divide by 0, avoid undetermined asin when > 1
            let angle = asin(norm)
            let unit = simd_normalize(dir)
            let axis = simd_normalize(simd_cross(unit, Vector3d(0, 0, -1)))
            return Quat(angle: speed * angle, axis: axis)
        }
        
        // No rotation (0 angle). Using x vector, because cross product with z vector may be used elsewhere.
        return Quat(angle: 0, axis: Vector3d(1, 0, 0))
    }
    
    class func makeCloud(type: GameType, nbPoints: Int, scene: GameScene, color: UIColor, radius: CGFloat, dotRadius: CGFloat, addGuides: Bool = false, mustShadow: Bool = false) -> Cloud {
        switch type {
        case .normal:
            return Cloud(nbPoints: nbPoints, scene: scene, color: color, radius: radius, dotRadius: dotRadius, addGuides: addGuides, mustShadow: mustShadow)
        case .satellite:
            return CloudSatellite(nbPoints: nbPoints, scene: scene, color: color, radius: radius, dotRadius: dotRadius, addGuides: addGuides)
        case .shadow:
            return CloudShadow(nbPoints: nbPoints, scene: scene, color: color, radius: radius, dotRadius: dotRadius, addGuides: addGuides)
        case .transit:
            return CloudTransit(nbPoints: nbPoints, scene: scene, color: color, radius: radius, dotRadius: dotRadius, addGuides: addGuides)
        case .mirage:
            return CloudMirage(nbPoints: nbPoints, scene: scene, color: color, radius: radius, dotRadius: dotRadius, addGuides: addGuides)
        case .rewire:
            return CloudRewire(nbPoints: nbPoints, scene: scene, color: color, radius: radius, dotRadius: dotRadius, addGuides: addGuides)
        }
    }
}

