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
    let radiusFactor: CGFloat = 0.02
    let depthColorAmplitude: CGFloat = 0.3
    
    var node: SKShapeNode
    var point: Float3d
    let scene: GameScene
    let color: UIColor

    init(scene: GameScene, color: UIColor, point3d: Float3d) {
        self.scene = scene
        self.color = color
        self.point = simd_normalize(point3d)
        
        let radius = self.radiusFactor * self.scene.minSize()
        self.node = SKShapeNode.init(circleOfRadius: radius)
        
        self.update()
        
        self.scene.addChild(self.node)
    }
    
    func update() {
        self.updatePosition()
        self.updateStyle()
    }
    
    func updatePosition() {
        let sceneCenter = self.scene.center()
        let sphereRadius = 0.5 * self.scene.level.unitSphereDiameter
        
        let x = sceneCenter.x + CGFloat(self.point.x) * sphereRadius
        let y = sceneCenter.y + CGFloat(self.point.y) * sphereRadius
        let z = CGFloat(self.point.z)
        
        self.node.position = CGPoint(x:x, y:y)
        self.node.zPosition = z
    }
    
    func updateStyle() {
        self.updateColor()
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
        let norm = simd_length(vector)
        
        if norm > 0 {
            let angle = Float.pi * norm / Float(self.scene.level.unitSphereDiameter)
            
            let unit = simd_normalize(vector)
            let axis = simd_normalize(simd_cross(unit, Float3d(0, 0, -1)))
            
            let q = simd_quatf(angle: angle, axis: axis)
            self.point = q.act(self.point)
            
            self.update()
        }
    }
}

class Cloud {
    var dots = Array<Dot>()
    
    func add(points: Array<Float3d>, scene: GameScene, color: UIColor) {
        for p in points {
            dots.append(Dot(scene: scene, color: color, point3d: p))
        }
    }
    
    class func generateSymmetricRandomPoints(nbPoints: Int) -> Array<Float3d> {
        var points = Array<Float3d>()
        
        for _ in 1...nbPoints {
            let x = Float.random(in: -1...1)
            let y = Float.random(in: -1...1)
            let z = Float.random(in: -1...1)
            
            points.append(simd_normalize(Float3d(x, y, z)))
            points.append(simd_normalize(Float3d(x, y, -z)))
        }
        
        return points
    }
    
    func clear() {
        for dot in self.dots {
            dot.node.removeFromParent()
        }
        
        self.dots.removeAll()
    }
}

class Level {
    let unitSphereDiameterFactor: CGFloat = 0.6
    let orbDiameterFactor: CGFloat = 0.5
    
    var unitSphereDiameter: CGFloat = 1.0
    var orbDiameter: CGFloat = 1.0
    var orb = SKShapeNode()
    
    var cloud = Cloud()
    
    func new(nbPoints: Int, scene: GameScene, color: UIColor) {
        self.clear()
        
        self.unitSphereDiameter = self.unitSphereDiameterFactor * scene.minSize()
        self.orbDiameter = self.orbDiameterFactor * scene.minSize()
        
        let points = Cloud.generateSymmetricRandomPoints(nbPoints: nbPoints)
        self.cloud.add(points: points, scene: scene, color: color)
        
        self.orb = SKShapeNode.init(circleOfRadius: 0.5 * self.orbDiameter)
        self.orb.fillColor = UIColor(white: 0.0, alpha: 0.4)
        self.orb.strokeColor = UIColor.clear
        self.orb.position = scene.center()
        scene.addChild(self.orb)
    }
    
    func clear() {
        self.orb.removeFromParent()
        self.cloud.clear()
    }
}

class GameScene: SKScene {

    var level = Level()
    
    func minSize() -> CGFloat {
        return min(self.size.width, self.size.height)
    }
    
    func center() -> CGPoint {
        let w = self.size.width
        let h = self.size.height
        return CGPoint(x: 0.5 * w, y: 0.5 * h)
    }
    
    func newLevel() {
        self.level.new(nbPoints: 20, scene: self, color: UIColor(red: 0.5, green: 0.3, blue: 0.5, alpha: 1))
    }
    
    // Scene will appear. Create content here. (not "touch moved")
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor(white: 0.1, alpha: 1)
        self.newLevel()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let dx = Float(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Float(t.location(in: self).y - t.previousLocation(in: self).y)
            
            for dot in self.level.cloud.dots {
                dot.rotate(vector: Float3d(dx, dy, 0))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { self.newLevel() }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
