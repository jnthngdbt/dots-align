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

    init(scene: GameScene, color: UIColor, point3d: Vector3d, sphereRadius: CGFloat) {
        self.scene = scene
        self.color = color
        self.point = simd_normalize(point3d)
        
        self.sphereRadius = sphereRadius
        self.radius = Const.Dot.radiusFactor * self.scene.minSize()
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
        let scale = self.getScaleFromDepth(amplitude: Const.Dot.depthColorAmplitude)
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        self.color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        r = min(1.0, r * scale)
        g = min(1.0, g * scale)
        b = min(1.0, b * scale)
        
        let color = UIColor(red: r, green: g, blue: b, alpha: a)
        
        self.node.strokeColor = UIColor.clear
        self.node.fillColor = color
    }
    
    func getScaleFromDepth(amplitude: CGFloat) -> CGFloat {
        return CGFloat(self.point.z) * amplitude + 1.0 // converts [-1, 1] z to e.g. [0.8, 1.2] for 0.2 amplitude
    }
    
    func rotate(quaternion: Quat) {
        self.point = quaternion.act(self.point)
        self.update()
    }
    
    deinit {
        self.node.removeFromParent()
    }
}
