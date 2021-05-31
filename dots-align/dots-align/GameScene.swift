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

class GameScene: SKScene {
    var game: Game?
    var orb: Orb?
    var mainMenu: MainMenu?
    var endGameMenu: EndGameMenu?
    var homeButton: FooterHomeButton?
    var gameMode = GameMode.level
    var orbDiameter: CGFloat = 1.0
    var touchBeganOnButtonId: ButtonId?
    
    func minSize() -> CGFloat {
        return min(self.size.width, self.size.height)
    }
    
    func maxSize() -> CGFloat {
        return max(self.size.width, self.size.height)
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
        
        self.touchRotate(touches: touches)
        self.game!.checkIfLevelSolved()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let buttonId = testButtonHit(touches: touches) {
            self.manageButtonTapBegin(buttonId: buttonId)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let buttonId = testButtonHit(touches: touches) {
            self.manageButtonTapEnd(buttonId: buttonId)
        } else { // no button hit
            self.game?.newLevelIfNecessary(scene: self)
            if self.game?.ended == true {
                self.endGameAnimation()
            }
        }
        
        // Make sure to reset button touch state at touch end.
        self.touchBeganOnButtonId = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func update(_ currentTime: TimeInterval) {
        self.mainMenu?.update()
    }
    
    func touchRotate(touches: Set<UITouch>) {
        if let t = touches.first {
            let dx = Scalar(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Scalar(t.location(in: self).y - t.previousLocation(in: self).y)
            let v = Vector3d(dx, dy, 0)

            if (dx == 0) && (dy == 0) { return }
            
            let radius = self.game!.level.cloud.radius
            if radius > 0 {
                let dir = v / Scalar(radius)
                self.game!.level.rotate(dir: dir, speed: Const.Scene.orbitingSpeed)
            }
        }
    }
    
    func testButtonHit(touches: Set<UITouch>) -> ButtonId? {
        if let t = touches.first {
            let location = t.location(in: self)
            let node = atPoint(location)
            
            if isButton(name: node.name) {
                if t.phase == .began {
                    Button.animateFromHitNode(node: node)
                }
                
                return ButtonId(rawValue: node.name!)
            }
        }
        
        return nil
    }
    
    func manageButtonTapBegin(buttonId: ButtonId?) {
        self.touchBeganOnButtonId = buttonId
    }
    
    func manageButtonTapEnd(buttonId: ButtonId) {
        if buttonId == self.touchBeganOnButtonId {
            if buttonId == ButtonId.tutorialId {
                self.startGame(mode: GameMode.tutorial)
            } else if buttonId == ButtonId.startLevelGameId {
                self.startGame(mode: GameMode.level)
            } else if buttonId == ButtonId.startTimedGameId {
                self.startGame(mode: GameMode.time)
            } else if buttonId == ButtonId.replayGameId {
                self.startGame(mode: self.gameMode)
            } else if buttonId == ButtonId.homeId {
                self.showMainMenu()
            } else if buttonId == ButtonId.tutorialInstructionsId {
                self.game?.tutorialInstructions?.onButtonTap(scene: self)
            }
        }
        
        self.touchBeganOnButtonId = nil
    }
    
    func startGame(mode: GameMode) {
        self.gameMode = mode
        
        self.orb = Orb(scene: self)
        self.homeButton = FooterHomeButton(scene: self)
        self.game = Game(scene: self, mode: mode)
        self.mainMenu = nil
        self.endGameMenu = nil
        
        self.startGameCountdownIfNecessary(mode: mode)
    }
    
    func startGameCountdownIfNecessary(mode: GameMode) {
        if mode != GameMode.time { return }
        
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
