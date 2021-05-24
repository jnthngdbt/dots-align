//
//  GameScene.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import SpriteKit
import GameplayKit

class Orb {
    let node: SKShapeNode
    init(scene: GameScene) {
        self.node = SKShapeNode.init(circleOfRadius: 0.5 * scene.orbDiameter)
        self.node.fillColor = Const.Orb.color
        self.node.strokeColor = UIColor.clear
        self.node.position = scene.center()
        scene.addChild(self.node)
    }
    
    deinit {
        self.node.removeFromParent()
    }
}

class HomeButton {
    let label: SKLabelNode
    let shape: SKShapeNode
    
    init(scene: GameScene) {
        self.label = SKLabelNode(text: "×")
        self.label.fontColor = Const.Button.fontColor
        self.label.fontName = "AvenirNextCondensed-Regular"
        self.label.fontSize = 0.1 * scene.minSize()
        self.label.verticalAlignmentMode = .center
        self.label.horizontalAlignmentMode = .center
        self.label.name = Const.Button.homeId
        
        self.shape = SKShapeNode(circleOfRadius: 0.05 * scene.minSize())
        self.shape.fillColor = Const.Button.fillColor
        self.shape.strokeColor = UIColor.clear
        self.shape.position = CGPoint(x: Const.Indicators.sidePaddingFactor * scene.minSize(), y: 0.1 * scene.minSize())
        self.shape.name = Const.Button.homeId
        
        self.shape.addChild(self.label)
        
        self.shape.zPosition = 2.0 // make to be in foreground (max z of sphere dots is 1)
        
        scene.addChild(self.shape)
    }
    
    deinit {
        self.shape.removeFromParent() // removes child label also
    }
}

class GameScene: SKScene {
    var game: Game?
    var orb: Orb?
    var mainMenu: MainMenu?
    var endGameMenu: EndGameMenu?
    var homeButton: HomeButton?
    
    var gameMode = GameMode.level
    
    var orbDiameter: CGFloat = 1.0
    
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
        self.backgroundColor = Const.backgroundColor
        
        self.orbDiameter = Const.Scene.orbDiameterFactor * self.minSize()
        
        self.showMainMenu()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.game == nil) {
            return
        }
        
        if self.game!.level.ended || self.game!.ended {
            return
        }
        
        if let t = touches.first {
            let dx = Scalar(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Scalar(t.location(in: self).y - t.previousLocation(in: self).y)
            let v = Vector3d(dx, dy, 0)
            
            let radius = self.game!.level.cloud.radius
            if radius > 0 {
                let dir = v / Scalar(radius)
                self.game!.level.rotate(dir: dir, speed: Const.Scene.orbitingSpeed)
            }
        }
        
        self.game!.checkIfLevelSolved()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let isButtonTapped = self.manageButtonTap(touches: touches)
        
        if !isButtonTapped {
            self.game?.newLevelIfNecessary(scene: self)
            if self.game?.ended == true {
                self.endGameAnimation()
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func update(_ currentTime: TimeInterval) {
        self.mainMenu?.update()
    }
    
    func manageButtonTap(touches: Set<UITouch>) -> Bool {
        if let t = touches.first {
            let location = t.location(in: self)
            let node = atPoint(location)
            
            if node.name == Const.Button.tutorialId {
                self.startGame(mode: GameMode.tutorial)
                return true
            } else if node.name == Const.Button.startLevelGameId {
                self.startGame(mode: GameMode.level)
                return true
            } else if node.name == Const.Button.startTimedGameId {
                self.startGame(mode: GameMode.time)
                return true
            } else if node.name == Const.Button.replayGameId {
                self.startGame(mode: self.gameMode)
                return true
            } else if node.name == Const.Button.homeId {
                self.showMainMenu()
                return true
            }
        }
        
        return false
    }
    
    func startGame(mode: GameMode) {
        self.gameMode = mode
        
        self.orb = Orb(scene: self)
        self.homeButton = HomeButton(scene: self)
        self.game = Game(scene: self, mode: mode)
        self.mainMenu = nil
        self.endGameMenu = nil
        
        if mode == GameMode.time {
            let countdownStep = SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run(self.game!.timeCountdown)
            ])

            let countdown = SKAction.sequence([
                SKAction.repeat(countdownStep, count: Const.Game.maxSeconds),
                SKAction.run(self.endGameAnimation)
            ])
            
            run(countdown, withKey: Const.Game.countdownKey)
        }
    }
    
    func endGameAnimation() {
        self.game?.ended = true
        self.game?.level.cloud.animate(action: SKAction.scale(to: 0, duration: Const.Animation.collapseSec))
        self.game?.indicators?.animate(action: SKAction.scale(to: 0, duration: Const.Animation.collapseSec))
        
        let animation = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.scale(to: 0, duration: Const.Animation.collapseSec)
        ])
        
        self.orb?.node.run(animation) {
            self.showEndGameMenu()
        }
    }
    
    func showMainMenu() {
        self.orb = nil
        self.clearGame()
        self.mainMenu = MainMenu(scene: self)
        self.endGameMenu = nil
    }
    
    func showEndGameMenu() {
        let score = self.game?.score ?? 0
        self.orb = nil
        self.clearGame()
        self.mainMenu = nil
        self.endGameMenu = EndGameMenu(scene: self, score: score)
    }
    
    func clearGame() {
        self.game = nil
        self.homeButton = nil
        self.removeAction(forKey: Const.Game.countdownKey)
    }
}
