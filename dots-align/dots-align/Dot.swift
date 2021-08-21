//
//  Dot.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class SizeableCircle: SKShapeNode {
    var radius: CGFloat {
        didSet {
            self.path = SizeableCircle.path(radius: self.radius)
        }
    }

    init(radius: CGFloat) {
        self.radius = radius
        super.init()
        self.path = SizeableCircle.path(radius: self.radius)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class func path(radius: CGFloat) -> CGMutablePath {
        let path: CGMutablePath = CGMutablePath()
        path.addArc(center: CGPoint.zero, radius: radius, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: false)
        return path
    }

}

class Dot {
    var node: SizeableCircle
    var point: Vector3d
    let scene: GameScene
    let color: UIColor
    var baseRadius: CGFloat
    var sphereRadius: CGFloat = 0.0
    let mustShadow: Bool

    init(scene: GameScene, color: UIColor, point3d: Vector3d, radius: CGFloat, sphereRadius: CGFloat, mustShadow: Bool = false) {
        self.scene = scene
        self.color = color
        self.point = simd_normalize(point3d)
        
        self.sphereRadius = sphereRadius
        self.baseRadius = radius
        self.mustShadow = mustShadow
        self.node = SizeableCircle.init(radius: radius)
        self.node.setScale(0) // needs to animate
        
        self.update()
        
        self.scene.addChild(self.node)
    }
    
    func update() {
        self.updatePosition()
        self.updateStyle()
    }
    
    func updatePosition() {
        let sceneCenter = self.scene.center()
        
        let x = sceneCenter.x + CGFloat(self.point.x) * self.sphereRadius
        let y = sceneCenter.y + CGFloat(self.point.y) * self.sphereRadius
        let z = CGFloat(self.point.z)
        
        self.node.position = CGPoint(x:x, y:y)
        self.node.zPosition = z
    }
    
    func updateStyle() {
        self.updateColor()
    }
    
    func updateColor() {
        let ampB = self.mustShadow ? Const.Dot.colorBrightnessFactorAmplitudeShadow : Const.Dot.colorBrightnessFactorAmplitude
        let z = CGFloat(self.point.z)
        let b = max(0.0, 1.0 - (1.0 - 0.5 * (z + 1.0)) * ampB) // converts [-1, 1] to [1-a, 1] factor
        let h = z * Const.Dot.colorHueAmplitude // converts [-1, 1] to [-a, a] offset
        let color = self.color.offsetHue(h, scaleBrightness: b)
        
        self.node.strokeColor = UIColor.clear
        self.node.fillColor = color
    }
    
    func rotate(quaternion: Quat) {
        self.point = quaternion.act(self.point)
        self.update()
    }
    
    func setRadius(radius: CGFloat) {
        self.node.radius = radius
    }
    
    func animate(_ action: SKAction) {
        self.node.run(action)
    }
    
    deinit {
        self.node.removeFromParent()
    }
}
