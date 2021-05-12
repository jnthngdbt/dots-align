//
//  GameScene.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import SpriteKit
import GameplayKit

typealias Scalar = Double
typealias Vector3d = SIMD3<Scalar>
typealias Quat = simd_quatd

extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 100), 0) / 100
        switch percentage {
            case 0: return self
            case 1: return color
            default:
                var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
                guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

                return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                               green: CGFloat(g1 + (g2 - g1) * percentage),
                               blue: CGFloat(b1 + (b2 - b1) * percentage),
                               alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
}

enum IndicatorNames: Int, CaseIterable { case left, dots, bonus, score  }

class Const {
    class Dot {
        static let radiusFactor: CGFloat = 0.02
        static let depthColorAmplitude: CGFloat = 0.3
    }
    
    class Cloud {
        static let alignedOrientation = Vector3d(0, 0, 1)
        static let alignedDistThresh = 0.05
        static let color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    }
    
    class Level {
        static let minNbPoints = 4
        static let maxNbPoints = 30
        static let maxMultiplier = 5
        static let maxAngleCumul = 1.5 * Scalar.pi
    }
    
    class Game {
        static let maxLevel = 20
    }
    
    class Scene {
        static let orbitingSpeed = 2.0
        static let unitSphereDiameterFactor: CGFloat = 0.6
        static let orbDiameterFactor: CGFloat = 0.5
    }
    
    class Indicators {
        // Default: HelveticaNeue-UltraLight.
        // Some nice: HelveticaNeue, AvenirNextCondensed, AvenirNext
        // Heavy, Bold, DemiBold, Medium, Regular, UltraLight.
        static let fontName = "AvenirNextCondensed-Bold"
        static let fontColor = UIColor(white: 0.4, alpha: 1)
        static let fontColorHighlight = UIColor(white: 0.8, alpha: 1)
    }
    
    static let debug = false
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

class Dot {
    var node: SKShapeNode
    var point: Vector3d
    let scene: GameScene
    let color: UIColor
    var radius: CGFloat = 0.0

    init(scene: GameScene, color: UIColor, point3d: Vector3d) {
        self.scene = scene
        self.color = color
        self.point = simd_normalize(point3d)
        
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
        let sphereRadius = 0.5 * self.scene.unitSphereDiameter
        
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

class Cloud {
    var dots = Array<Dot>()
    var orientation = Vector3d(0, 0, 1)
    var alignedDist = 0.0
    
    init(points: Array<Vector3d>, scene: GameScene, color: UIColor) {
        for p in points {
            dots.append(Dot(scene: scene, color: color, point3d: p))
        }
        
        if Const.debug {
            dots.append(Dot(scene: scene, color: UIColor.red, point3d: Const.Cloud.alignedOrientation))
            dots.append(Dot(scene: scene, color: UIColor.red, point3d: -Const.Cloud.alignedOrientation))
        }
    }
    
    class func generateSymmetricRandomPoints(nbPoints: Int) -> Array<Vector3d> {
        var points = Array<Vector3d>()
        
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
        let z = 1.0
        let p = simd_normalize(Vector3d(x,y,z))
        
        let dir = p - Const.Cloud.alignedOrientation
        
        self.rotate(dir: dir)
    }
    
    func isAligned() -> Bool {
        return self.alignedDist < Const.Cloud.alignedDistThresh
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

class Level {
    var cloud: Cloud!
    var indicators: Indicators!
    
    var nbPatternPoints = 0
    var angleCumul = 0.0
    var solved = false
    
    init(scene: GameScene, indicators: Indicators) {
        self.indicators = indicators
        
        self.nbPatternPoints = Utils.randomOdd(inMin:Const.Level.minNbPoints, inMax:Const.Level.maxNbPoints) // odd random integer in range
        let points = Cloud.generateSymmetricRandomPoints(nbPoints: nbPatternPoints)
        
        self.cloud = Cloud(points: points, scene: scene, color: Const.Cloud.color)
        self.cloud.desalign()
        
        self.animateIn()
        
        self.indicators.update(name: IndicatorNames.dots, value: self.getTotalNbDots())
        self.indicators.update(name: IndicatorNames.bonus, value: Const.Level.maxMultiplier, prefix: "x")
    }
    
    func getTotalNbDots() -> Int {
        return 2 * self.nbPatternPoints
    }
    
    func computeMultiplier() -> Int {
        let steps = Const.Level.maxAngleCumul / Scalar(Const.Level.maxMultiplier - 1)
        let multiplier = Const.Level.maxMultiplier - Int(angleCumul / steps)
        return max(1, multiplier)
    }
    
    func rotate(dir: Vector3d, speed: Scalar = 1) {
        let q = Utils.quaternionFromDir(dir: dir, speed: speed)
        self.cloud.rotate(quaternion: q)
        
        self.angleCumul += q.angle
        self.indicators.update(name: IndicatorNames.bonus, value: self.computeMultiplier(), prefix: "x")
    }
    
    func solve() {
        self.solved = true

        let dir = Const.Cloud.alignedOrientation - self.cloud.orientation
        self.cloud.rotate(dir: dir)
        
        self.animateOut()
    }
    
    func computeScore() -> Int {
        return self.getTotalNbDots() * self.computeMultiplier()
    }
    
    func animateIn() {
        for dot in self.cloud.dots {
            dot.node.setScale(0)
            dot.node.run(SKAction.scale(to: 1, duration: 0.1))
        }
    }
    
    func animateOut() {
        for dot in self.cloud.dots {
            let expand = SKAction.group([
                SKAction.fadeAlpha(to: 0.9, duration: 0.05),
                SKAction.scale(to: 1.5, duration: 0.05)
            ])
            
            let back = SKAction.group([
                SKAction.fadeAlpha(to: 1.0, duration: 0.05),
                SKAction.scale(to: 1.0, duration: 0.05)
            ])
            
            let collapse = SKAction.group([
                SKAction.fadeAlpha(to: 0.0, duration: 0.1),
                SKAction.scale(to: 0, duration: 0.1)
            ])
            
            let animation = SKAction.sequence([
                expand,
                back,
                SKAction.wait(forDuration: 0.3),
                collapse
            ])

            dot.node.run(animation)
        }
    }
}

class Game {
    var level: Level!
    var indicators: Indicators!
    var score = 0
    
    init(scene: GameScene) {
        self.indicators = Indicators(scene: scene)
        self.level = Level(scene: scene, indicators: self.indicators)
    }
    
    func checkIfLevelSolved() {
        if self.level.cloud.isAligned() {
            self.level.solve()
            
            let levelScore = self.level.computeScore()
            self.score += levelScore
            self.indicators.update(name: IndicatorNames.score, value: levelScore, prefix: "+", highlight: true)
        }
    }
    
    func newLevelIfNecessary(scene: GameScene) {
        if self.level.solved {
            self.level = Level(scene: scene, indicators: self.indicators)
            self.indicators.update(name: IndicatorNames.score, value: self.score)
        }
    }
}

class Indicator {
    var label = SKLabelNode(text: "LABEL")
    var data = SKLabelNode(text: "DATA")

    init(scene: GameScene, idx: Int) {
        let h = scene.size.height
        let w = scene.size.width

        let labelPosY = h * (1 - 0.05)
        let dataPosY = labelPosY - 0.08 * scene.minSize()

        let nbIndicators = IndicatorNames.allCases.count
        let posX = w * CGFloat(idx + 1) / CGFloat(nbIndicators + 1)
        
        label.position = CGPoint(x: posX, y: labelPosY)
        data.position = CGPoint(x: posX, y: dataPosY)

        label.fontSize = 0.04 * scene.minSize()
        data.fontSize = 0.08 * scene.minSize()

        label.fontName = Const.Indicators.fontName
        data.fontName = Const.Indicators.fontName

        label.fontColor = Const.Indicators.fontColor
        data.fontColor = Const.Indicators.fontColor

        scene.addChild(label)
        scene.addChild(data)
    }

    func updateData(value: Int, prefix: String = "", highlight: Bool = false) {
        self.data.text = prefix + String(value)
        if highlight {
            self.data.fontColor = Const.Indicators.fontColorHighlight
        } else {
            self.data.fontColor = Const.Indicators.fontColor
        }
    }
    
    deinit {
        self.label.removeFromParent()
        self.data.removeFromParent()
    }
}

class Indicators {
    var indicators = Array<Indicator>()
    
    init(scene: GameScene) {
        for i in 0..<IndicatorNames.allCases.count {
            self.indicators.append(Indicator(scene: scene, idx: i))
        }
        
        self.indicators[IndicatorNames.left.rawValue].label.text = "LEFT"
        self.indicators[IndicatorNames.left.rawValue].data.text = "20"
        
        self.indicators[IndicatorNames.dots.rawValue].label.text = "DOTS"
        self.indicators[IndicatorNames.dots.rawValue].data.text = "0"
        
        self.indicators[IndicatorNames.bonus.rawValue].label.text = "BONUS"
        self.indicators[IndicatorNames.bonus.rawValue].data.text = "x0"
        
        self.indicators[IndicatorNames.score.rawValue].label.text = "SCORE"
        self.indicators[IndicatorNames.score.rawValue].data.text = "0"
    }
    
    func update(name: IndicatorNames, value: Int, prefix: String = "", highlight: Bool = false) {
        if indicators.count > name.rawValue {
            indicators[name.rawValue].updateData(value: value, prefix: prefix, highlight: highlight)
        }
    }
}

class GameScene: SKScene {
    var game: Game!
    
    var unitSphereDiameter: CGFloat = 1.0
    var orbDiameter: CGFloat = 1.0
    var orb = SKShapeNode()
    
    func minSize() -> CGFloat {
        return min(self.size.width, self.size.height)
    }
    
    func center() -> CGPoint {
        let w = self.size.width
        let h = self.size.height
        return CGPoint(x: 0.5 * w, y: 0.5 * h)
    }
    
    // Scene will appear. Create content here. (not "touch moved")
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor(white: 0.1, alpha: 1)
        
        self.unitSphereDiameter = Const.Scene.unitSphereDiameterFactor * self.minSize()
        self.orbDiameter = Const.Scene.orbDiameterFactor * self.minSize()
        
        self.orb = SKShapeNode.init(circleOfRadius: 0.5 * self.orbDiameter)
        self.orb.fillColor = UIColor(white: 0.0, alpha: 0.4)
        self.orb.strokeColor = UIColor.clear
        self.orb.position = self.center()
        self.addChild(self.orb)
        
        self.game = Game(scene: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.game.level.solved {
            return
        }
        
        if let t = touches.first {
            let dx = Scalar(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Scalar(t.location(in: self).y - t.previousLocation(in: self).y)
            let v = Vector3d(dx, dy, 0)
            
            if self.unitSphereDiameter > 0 {
                let dir = 2 * v / Scalar(self.unitSphereDiameter) // normalize by radius
                self.game.level.rotate(dir: dir, speed: Const.Scene.orbitingSpeed)
            }
        }
        
        self.game.checkIfLevelSolved()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.game.newLevelIfNecessary(scene: self)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
