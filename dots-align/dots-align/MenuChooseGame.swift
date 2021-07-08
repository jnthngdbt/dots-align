//
//  MenuChooseGame.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-06-19.
//

import Foundation
import SpriteKit

class MenuChooseGame {
    let title: SKLabelNode!
    var cloud: Cloud?
    let orb: Orb?
    let description: SKLabelNode
    let startButton: FooterButton
    var homeButton: FooterHomeButton!
    var cloudType: GameType!
    var left: Button
    var right: Button
    
    let cloudDiameter: CGFloat
    let cloudRadius: CGFloat
    let dotRadius: CGFloat
    
    init(scene: GameScene) {
        self.cloudDiameter = Const.MenuChooseGame.sphereDiameterFactor * scene.minSize()
        self.cloudRadius = 0.5 * cloudDiameter
        self.dotRadius = Const.MenuChooseGame.dotRadiusFactor * scene.minSize()
        
        self.cloudType = .normal
        
        self.cloud = Utils.makeCloud(type: self.cloudType, nbPoints: Const.MenuChooseGame.nbDots, scene: scene, color: accentColor, radius: self.cloudRadius, dotRadius: self.dotRadius)
        self.cloud?.desalign()
        
        let navButtonWidthSpace = 0.5 * (scene.size.width - self.cloudDiameter)
        let navButtonSize = CGSize(width: 0.8 * navButtonWidthSpace, height: 0.98 * self.cloudDiameter)
        
        self.orb = Orb(scene: scene)
        self.title = SKLabelNode(text: "SELECT GAME")
        self.description = SKLabelNode(text: "SATELLITE // x6 BOOST")
        self.homeButton = FooterHomeButton(scene: scene)
        self.startButton = FooterButton(scene: scene, text: "START", id: .chooseGameStart, widthScaleFactor: Const.MenuChooseGame.startButtonWidthScaleFactor)
        self.left = Button(scene: scene, text: "◁", size: navButtonSize, id: .chooseGameNavLeft)
        self.right = Button(scene: scene, text: "▷", size: navButtonSize, id: .chooseGameNavRight)
        
        let topSpaceLeft = 0.5 * scene.size.height - cloudRadius
        
        self.setTitle(scene: scene, posY: scene.center().y + cloudRadius + 0.65 * topSpaceLeft)
        self.setDescription(scene: scene, posY: scene.center().y + cloudRadius + 0.3 * topSpaceLeft)
        self.setStartButton(scene: scene)
        self.setNavButtons(scene: scene)
        
        self.animateIn()
    }
    
    func getGameTypeString(type: GameType) -> String {
        switch type {
        case .normal: return "NORMAL"
        case .satellite: return "SATELLITE"
        case .shadow: return "SHADOW"
        case .transit: return "TRANSIT"
        }
    }
    
    func setTitle(scene: GameScene, posY: CGFloat) {
        self.title.fontColor = labelColor
        self.title.fontName = Const.fontNameTitle
        self.title.fontSize = 0.15 * scene.minSize()
        self.title.position = CGPoint(x: scene.center().x, y: posY)
        self.title.zPosition = Const.Button.zPosition
        self.title.verticalAlignmentMode = .center
        self.title.setScale(0)
        self.title.alpha = 1
        scene.addChild(self.title)
    }
    
    func setDescription(scene: GameScene, posY: CGFloat) {
        self.description.fontColor = accentColor.offsetHue(0, scaleBrightness: 0.7)
        self.description.fontName = Const.fontNameTitle
        self.description.fontSize = 0.07 * scene.minSize()
        self.description.position = CGPoint(x: scene.center().x, y: posY)
        self.description.zPosition = Const.Button.zPosition
        self.description.verticalAlignmentMode = .center
        self.description.horizontalAlignmentMode = .center
        self.description.lineBreakMode = .byWordWrapping
        self.description.numberOfLines = 0
        self.description.setScale(0)
        self.description.alpha = 1
        scene.addChild(self.description)
        
        self.updateDescription()
    }
    
    func updateDescription() {
        let typeStr = self.getGameTypeString(type: self.cloudType)
        let boostStr = String(getMaxBoost(type: self.cloudType))
        self.description.text = typeStr + " // x" + boostStr + " BOOST"
    }
    
    func setNavButtons(scene: GameScene) {
        let width = self.left.size().width
        self.left.shape.position = CGPoint(x: 0.5 * width, y: scene.center().y)
        self.right.shape.position = CGPoint(x: scene.size.width - 0.5 * width, y: scene.center().y)
        
        self.left.shape.fillColor = UIColor.clear
        self.right.shape.fillColor = UIColor.clear
        
        self.updateNavButtons()
    }
    
    func updateNavButtons() {
        self.left.shape.alpha = self.mustShowLeftNavButton() ? 1 : 0
        self.right.shape.alpha = self.mustShowRightNavButton() ? 1 : 0
    }
    
    func mustShowLeftNavButton() -> Bool {
        return self.cloudType.rawValue > 0
    }
    
    func mustShowRightNavButton() -> Bool {
        return self.cloudType.rawValue < GameType.allCases.count - 1
    }
    
    func setStartButton(scene: GameScene) {
        let leftFooterPaddingFactor = Const.Indicators.sidePaddingFactor - 0.5 * Const.Button.Footer.widthFactor
        let buttonWidth = Const.Button.Footer.widthFactor * Const.MenuChooseGame.startButtonWidthScaleFactor
        self.startButton.shape.position.x = scene.size.width - (leftFooterPaddingFactor + 0.5 * buttonWidth) * scene.minSize()
    }
    
    func rotate(dir: Vector3d, speed: Scalar = 1) {
        if self.cloud == nil { return }
        
        let radius = self.cloud!.radius
        if radius <= 0 { return }
        let dirNorm = dir / Scalar(radius)
            
        let q = Utils.quaternionFromDir(dir: dirNorm, speed: speed)
        self.cloud!.rotate(quaternion: q)
    }
    
    func onLeftTap(scene: GameScene) {
        self.newCloud(scene: scene, type: GameType(rawValue: self.cloudType.rawValue - 1))
    }
    
    func onRightTap(scene: GameScene) {
        self.newCloud(scene: scene, type: GameType(rawValue: self.cloudType.rawValue + 1))
    }
    
    private func newCloud(scene: GameScene, type: GameType?) {
        if type == nil { return }
        self.cloudType = type
        
        self.cloud = Utils.makeCloud(type: self.cloudType, nbPoints: Const.MenuChooseGame.nbDots, scene: scene, color: accentColor, radius: self.cloudRadius, dotRadius: self.dotRadius)
        self.cloud?.desalign()
        
        self.updateDescription()
        self.updateNavButtons()
    }
    
    private func animateIn() {
        let titleAnimation = SKAction.sequence([
            SKAction.wait(forDuration: Const.Animation.titleAppearWait),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.title.run(titleAnimation)
        self.description.run(titleAnimation)
        
        let buttonsAnimation = SKAction.sequence([
            SKAction.scale(to: 0, duration: 0),
            SKAction.fadeAlpha(to: 1, duration: 0),
            SKAction.wait(forDuration: 0.2),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.homeButton.animate(action: buttonsAnimation)
        self.startButton.animate(action: buttonsAnimation)
        if (self.mustShowLeftNavButton()) { self.left.animate(action: buttonsAnimation) }
        if (self.mustShowRightNavButton()) { self.right.animate(action: buttonsAnimation) }
        
        self.animateInCloud()
    }
    
    private func animateInCloud() {
        let animation = SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.0),
            SKAction.wait(forDuration: 0.2),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.cloud?.animate(action: animation)
    }
    
    deinit {
        self.title.removeFromParent()
        self.description.removeFromParent()
    }
}
