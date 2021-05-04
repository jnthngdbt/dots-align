//
//  GameScene.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import SpriteKit
import GameplayKit

typealias Float3d = SIMD3<Float>

class Dot {
    let nominalRadiusSceneFactor: CGFloat = 0.02
    let glowWidthFactor: CGFloat = 0.0
    
    let depthRadiusAmplitude: CGFloat = 0.3
    let depthColorAmplitude: CGFloat = 0.3
    
    var node: SKShapeNode
    var point: Float3d
    let scene: SKScene
    let color: UIColor

    init(scene: SKScene, color: UIColor, point3d: Float3d) {
        self.scene = scene
        self.color = color
        self.point = point3d
        
        let nominalRadius = self.nominalRadiusSceneFactor * min(self.scene.size.width, self.scene.size.height)
        self.node = SKShapeNode.init(circleOfRadius: nominalRadius)
        self.node.glowWidth = nominalRadius * self.glowWidthFactor
        
        self.updatePosition(point3d: point3d)
        self.updateStyle()
    }
    
    func updatePosition(point3d: Float3d) {
        let w = self.scene.size.width
        let h = self.scene.size.height
        
        let x = 0.5 * w + CGFloat(point3d.x) * w
        let y = 0.5 * h + CGFloat(point3d.y) * h
        let z = CGFloat(point3d.z)
        
        self.node.position = CGPoint(x:x, y:y)
        self.node.zPosition = z
        
        self.point = point3d
    }
    
    func updateStyle() {
        self.updateRadius()
        self.updateColor()
    }
    
    func updateRadius() {
        let scale = self.getScaleFromDepth(amplitude: self.depthRadiusAmplitude)
        self.node.setScale(scale)
    }
    
    func updateColor() {
        let scale = self.getScaleFromDepth(amplitude: self.depthColorAmplitude)
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        self.color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        r = min(1.0, r * scale)
        g = min(1.0, g * scale)
        b = min(1.0, b * scale)
        
        let color = UIColor(red: r, green: g, blue: b, alpha: a)
        
        self.node.strokeColor = color
        self.node.fillColor = color
    }
    
    func getScaleFromDepth(amplitude: CGFloat) -> CGFloat {
        return CGFloat(self.point.z) * amplitude + 1.0 // converts [-1, 1] z to e.g. [0.8, 1.2] for 0.2 amplitude
    }
    
    func rotate(vector: Float3d) {
        self.node.position.x += CGFloat(vector.x)
        self.node.position.y += CGFloat(vector.y)
    }
}

class GameScene: SKScene {
    
    private var dots = Array<Dot>()
    
    // Scene will appear. Create content here. (not "touch moved")
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 1)
        
        self.dots.append(Dot(scene: self, color: UIColor(white: 0.5, alpha: 1), point3d: Float3d(0.2, 0, -1)))
        self.dots.append(Dot(scene: self, color: UIColor(white: 0.5, alpha: 1), point3d: Float3d(-0.2, 0, 1)))
        
        for dot in self.dots {
            self.addChild(dot.node)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let dx = Float(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Float(t.location(in: self).y - t.previousLocation(in: self).y)
            
            for dot in self.dots {
                dot.rotate(vector: Float3d(dx, dy, 0))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
