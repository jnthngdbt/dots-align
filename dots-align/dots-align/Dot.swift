//
//  Dot.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class Dot {
    var node: SKShapeNode
    var point: Vector3d
    let scene: GameScene
    let color: UIColor
    var radius: CGFloat = 0.0
    var sphereRadius: CGFloat = 0.0

    init(scene: GameScene, color: UIColor, point3d: Vector3d, radius: CGFloat, sphereRadius: CGFloat) {
        self.scene = scene
        self.color = color
        self.point = simd_normalize(point3d)
        
        self.sphereRadius = sphereRadius
        self.radius = radius
        self.node = SKShapeNode.init(circleOfRadius: self.radius)
        
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
        let z = CGFloat(self.point.z)
        let b = 1.0 - (1.0 - 0.5 * (z + 1.0)) * Const.Dot.colorBrightnessFactorAmplitude // converts [-1, 1] to [1-a, 1] factor
        let h = z * Const.Dot.colorHueAmplitude // converts [-1, 1] to [-a, a] offset
        let color = self.color.offsetHue(h, scaleBrightness: b)
        
        self.node.strokeColor = UIColor.clear
        self.node.fillColor = color
    }
    
    func rotate(quaternion: Quat) {
        self.point = quaternion.act(self.point)
        self.update()
    }
    
    func animate(action: SKAction) {
        self.node.run(action)
    }
    
    deinit {
        self.node.removeFromParent()
    }
}
