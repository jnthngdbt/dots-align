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
    
    let depthRadiusAmplitude: CGFloat = 0.4
    let depthColorAmplitude: CGFloat = 0.4
    
    var node: SKShapeNode
    var point: Float3d
    let scene: SKScene
    let color: UIColor
    let sphereDiameterFactor: CGFloat = 0.6
    let sphereDiameter: CGFloat
    let sceneSize: CGFloat

    init(scene: SKScene, color: UIColor, point3d: Float3d) {
        self.scene = scene
        self.color = color
        self.point = simd_normalize(point3d)
        
        self.sceneSize = min(self.scene.size.width, self.scene.size.height)
        
        let nominalRadius = self.nominalRadiusSceneFactor * self.sceneSize
        self.node = SKShapeNode.init(circleOfRadius: nominalRadius)
        self.node.glowWidth = nominalRadius * self.glowWidthFactor
        
        self.sphereDiameter = self.sphereDiameterFactor * self.sceneSize
        
        self.update()
    }
    
    func update() {
        self.updatePosition()
        self.updateStyle()
    }
    
    func updatePosition() {
        let w = self.scene.size.width
        let h = self.scene.size.height
        
        let sceneCenter = CGPoint(x: 0.5 * w, y: 0.5 * h)
        let sphereRadius = 0.5 * self.sphereDiameter
        
        let x = sceneCenter.x + CGFloat(self.point.x) * sphereRadius
        let y = sceneCenter.y + CGFloat(self.point.y) * sphereRadius
        let z = CGFloat(self.point.z)
        
        self.node.position = CGPoint(x:x, y:y)
        self.node.zPosition = z
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
    
    func addToScene() {
        self.scene.addChild(self.node)
    }
    
    func rotate(vector: Float3d) {
        let norm = simd_length(vector)
        
        if norm > 0 {
            let angle = Float.pi * norm / Float(self.sphereDiameter)
            
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
    
    func add(points: Array<Float3d>, scene: SKScene, color: UIColor) {
        for p in points {
            dots.append(Dot(scene: scene, color: color, point3d: p))
        }
    }
    
    class func generateRandomPoints(nbPoints: Int) -> Array<Float3d> {
        var points = Array<Float3d>()
        
        for _ in 1...nbPoints {
            let x = Float.random(in: -1...1)
            let y = Float.random(in: -1...1)
            let z = Float.random(in: -1...1)
            
            let point = simd_normalize(Float3d(x, y, z))
            points.append(point)
        }
        
        return points
    }
        
    func addToScene() {
        for dot in self.dots {
            dot.addToScene()
        }
    }
}

class GameScene: SKScene {
    
    private var cloud = Cloud()
    private var model = Cloud()
    
    // Scene will appear. Create content here. (not "touch moved")
    override func didMove(to view: SKView) {
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 1)
        
        let points = Cloud.generateRandomPoints(nbPoints: 4)
        self.cloud.add(points: points, scene: self, color: UIColor.init(white: 0.5, alpha: 1))
        self.model.add(points: points, scene: self, color: UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.9))
        
        self.cloud.addToScene()
        self.model.addToScene()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let dx = Float(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Float(t.location(in: self).y - t.previousLocation(in: self).y)
            
            for dot in self.cloud.dots {
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
