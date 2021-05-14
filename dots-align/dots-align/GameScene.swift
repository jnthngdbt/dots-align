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
    
    var unitSphereDiameter: CGFloat = 1.0
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
        self.backgroundColor = Const.backgroudColor
        
        self.unitSphereDiameter = Const.Scene.unitSphereDiameterFactor * self.minSize()
        self.orbDiameter = Const.Scene.orbDiameterFactor * self.minSize()
        
        self.showMainMenu()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.game == nil) {
            return
        }
        
        if self.game!.level.solved {
            return
        }
        
        if let t = touches.first {
            let dx = Scalar(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Scalar(t.location(in: self).y - t.previousLocation(in: self).y)
            let v = Vector3d(dx, dy, 0)
            
            if self.unitSphereDiameter > 0 {
                let dir = 2 * v / Scalar(self.unitSphereDiameter) // normalize by radius
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
            if self.game?.isGameEnded == true {
                self.showEndGameMenu()
            }
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func manageButtonTap(touches: Set<UITouch>) -> Bool {
        if let t = touches.first {
            let location = t.location(in: self)
            let node = atPoint(location)
            
            if node.name == Const.Button.startLevelGameId {
                self.startGame()
                return true
            } else if node.name == Const.Button.replayGameId {
                self.startGame()
                return true
            }
        }
        
        return false
    }
    
    func startGame() {
        self.orb = Orb(scene: self)
        self.game = Game(scene: self)
        self.mainMenu = nil
        self.endGameMenu = nil
    }
    
    func showMainMenu() {
        self.orb = nil
        self.game = nil
        self.mainMenu = MainMenu(scene: self)
        self.endGameMenu = nil
    }
    
    func showEndGameMenu() {
        self.orb = nil
        self.game = nil
        self.mainMenu = nil
        self.endGameMenu = EndGameMenu(scene: self)
    }
}
