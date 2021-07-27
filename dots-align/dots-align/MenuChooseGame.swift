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
    let lockedText: SKLabelNode
    let startButton: FooterButton
    var homeButton: FooterHomeButton!
    var cloudType: GameType!
    var left: Button
    var right: Button
    
    let cloudDiameter: CGFloat
    let cloudRadius: CGFloat
    let dotRadius: CGFloat
    let nbGamesPlayed: Int
    
    let disalignment = 0.9 // diagonal coordinate
    let rotationOffset = 0.9 // how rotation animation offsets from diagonal
    let rotationSpeed = 0.01
    
    init(scene: GameScene) {
        self.cloudDiameter = Const.MenuChooseGame.sphereDiameterFactor * scene.minSize()
        self.cloudRadius = 0.5 * cloudDiameter
        self.dotRadius = Const.MenuChooseGame.dotRadiusFactor * scene.minSize()
        self.nbGamesPlayed = DatabaseManager.getGameCount() ?? 0
        
        let lastGameType = UserDefaults.standard.integer(forKey: Const.DefaultsKeys.lastGameTypeSelected) // returns 0 if not set yet
        self.cloudType = GameType(rawValue: lastGameType)
        
        self.cloud = Utils.makeCloud(type: self.cloudType, nbPoints: Const.MenuChooseGame.nbDots, scene: scene, color: MenuChooseGame.getCloudColor(type: cloudType, nbGamesPlayed: self.nbGamesPlayed), radius: self.cloudRadius, dotRadius: self.dotRadius)
        self.cloud?.desalign(x: self.disalignment, y: self.disalignment)
        
        let navButtonWidthSpace = 0.5 * (scene.size.width - self.cloudDiameter)
        let navButtonSize = CGSize(width: 0.8 * navButtonWidthSpace, height: 0.98 * self.cloudDiameter)
        
        self.orb = Orb(scene: scene)
        self.title = SKLabelNode(text: "SELECT GAME")
        self.description = SKLabelNode(text: "SATELLITE // x6 BOOST")
        self.lockedText = SKLabelNode(text: "PLAY 10 MORE GAMES TO UNLOCK")
        self.homeButton = FooterHomeButton(scene: scene)
        self.startButton = FooterButton(scene: scene, text: "START", id: .chooseGameStart, widthScaleFactor: Const.MenuChooseGame.startButtonWidthScaleFactor)
        self.left = Button(scene: scene, text: "◁", size: navButtonSize, id: .chooseGameNavLeft)
        self.right = Button(scene: scene, text: "▷", size: navButtonSize, id: .chooseGameNavRight)
        
        let topSpaceLeft = 0.5 * scene.size.height - cloudRadius
        
        self.setTitle(scene: scene, posY: scene.center().y + cloudRadius + 0.65 * topSpaceLeft)
        self.setDescription(scene: scene, posY: scene.center().y + cloudRadius + 0.3 * topSpaceLeft)
        self.setStartButton(scene: scene)
        self.setNavButtons(scene: scene)
        self.setLockedText(scene: scene) // set after start footer button to get its position
        
        self.animateIn()
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
        let typeStr = getGameTypeString(type: self.cloudType)
        let boostStr = String(getMaxBoost(type: self.cloudType))
        self.description.text = typeStr + " // x" + boostStr + " BOOST"
    }
    
    func setLockedText(scene: GameScene) {
        let footerButtonTop = self.startButton.shape.position.y + 0.5 * self.startButton.size().height
        let cloudBottom = scene.center().y - self.cloudRadius // - self.dotRadius
        let bottomSpaceCenter = 0.5 * (footerButtonTop + cloudBottom)
        
        self.lockedText.fontColor = accentColor
        self.lockedText.fontName = Const.fontNameTitle
        self.lockedText.fontSize = 0.04 * scene.minSize()
        self.lockedText.position = CGPoint(x: scene.center().x, y: bottomSpaceCenter)
        self.lockedText.zPosition = Const.Button.zPosition
        self.lockedText.verticalAlignmentMode = .center
        self.lockedText.horizontalAlignmentMode = .center
        self.lockedText.setScale(0)
        self.lockedText.alpha = 1
        scene.addChild(self.lockedText)
        
        self.updateLockedText(animate: false)
    }
    
    func updateLockedText(animate: Bool = true) {
        let nbGamesLeft = max(0, getNbGamesToUnlock(type: self.cloudType) - self.nbGamesPlayed)
        self.lockedText.text = "PLAY " + String(nbGamesLeft) + " MORE GAMES TO UNLOCK"
        if animate {
            self.lockedText.run(SKAction.scale(to: self.isGameTypeLocked() ? 1 : 0, duration: 0))
        }
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
        self.startButton.label.fontSize = 0.85 * self.startButton.label.fontSize
        
        self.updateStartButton()
    }
    
    func updateStartButton() {
        if self.isGameTypeLocked() {
            self.startButton.label.fontColor = disabledButtonFontColor
            self.startButton.label.text = "LOCKED"
        } else {
            self.startButton.label.fontColor = accentColor
            self.startButton.label.text = "START"
        }
    }
    
    func getCloudColor() -> UIColor {
        return MenuChooseGame.getCloudColor(type: self.cloudType, nbGamesPlayed: self.nbGamesPlayed)
    }
    
    static func getCloudColor(type: GameType, nbGamesPlayed: Int) -> UIColor {
        return self.isGameTypeLocked(type: type, nbGamesPlayed: nbGamesPlayed) ? Const.Cloud.lockedColor : Const.Cloud.color
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
        
        self.cloud = Utils.makeCloud(type: self.cloudType, nbPoints: Const.MenuChooseGame.nbDots, scene: scene, color: self.getCloudColor(), radius: self.cloudRadius, dotRadius: self.dotRadius)
        self.cloud?.desalign(x: self.disalignment, y: self.disalignment)
        self.cloud?.animateIn(wait: 0.0)
        
        UserDefaults.standard.set(self.cloudType.rawValue, forKey: Const.DefaultsKeys.lastGameTypeSelected)
        
        self.updateDescription()
        self.updateLockedText()
        self.updateNavButtons()
        self.updateStartButton()
    }
    
    func isGameTypeLocked() -> Bool {
        return MenuChooseGame.isGameTypeLocked(type: self.cloudType, nbGamesPlayed: self.nbGamesPlayed)
    }
    
    static func isGameTypeLocked(type: GameType, nbGamesPlayed: Int) -> Bool {
        return (Const.buildMode == .demo) ? false : (nbGamesPlayed < getNbGamesToUnlock(type: type))
    }
    
    private func animateIn() {
        let titleAnimation = SKAction.sequence([
            SKAction.wait(forDuration: Const.Animation.titleAppearWait),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.title.run(titleAnimation)
        self.description.run(titleAnimation)
        if self.isGameTypeLocked() { self.lockedText.run(titleAnimation) }
        
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
        
        self.cloud?.animateIn(wait: 0.2)
        
        self.orb?.node.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
    }
    
    func update() {
        // Rotate slightly off diagonal. The cloud disalignment is on the diagonal.
        // If perfectly on diagonal, when it aligns while rotating, creates weird visual glitch.
        let dir = simd_normalize(Vector3d(x: self.rotationOffset, y: 1, z: 0))
        self.cloud?.rotate(dir: dir, speed: self.rotationSpeed)
    }
    
    deinit {
        self.title.removeFromParent()
        self.description.removeFromParent()
        self.lockedText.removeFromParent()
    }
}
