//
//  Utils.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

typealias Scalar = Double
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
    
    func scale(_ scale: CGFloat) -> UIColor {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        
        r = min(1.0, r * scale)
        g = min(1.0, g * scale)
        b = min(1.0, b * scale)

        return UIColor(red: r, green: g, blue: b, alpha: a)
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
        
        if norm > 0 {
            let angle = asin(norm)
            let unit = simd_normalize(dir)
            let axis = simd_normalize(simd_cross(unit, Vector3d(0, 0, -1)))
            return Quat(angle: speed * angle, axis: axis)
        }
        
        return Quat(angle: 0, axis: Vector3d(0, 0, 1)) // no effect
    }
}

