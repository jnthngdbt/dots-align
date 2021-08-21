//
//  MenuGameUnlocked.swift
//  dots-align
//
//  Created by Jonathan on 2021-07-30.
//

import Foundation
import SpriteKit

class MenuGameUnlocked {
    let title: SKLabelNode
    let explanation: SKLabelNode
    let gameDescription: SKLabelNode
    var cloud: Cloud?
    let orb: Orb?
    let button: MenuButton
    
    let cloudScale: CGFloat = 0.9
    let disalignment = 0.9 // diagonal coordinate
    let rotationOffset = 0.9 // how rotation animation offsets from diagonal
    let rotationSpeed = 0.01
    
    var titlePosY: CGFloat
    
    init(scene: GameScene, gameTypeData: GameTypeData) {
        self.title = SKLabelNode(text: "CONGRATS")
        self.explanation = SKLabelNode(text: "YOU PLAYED " + String(gameTypeData.nbGamesToUnlock) + " GAMES TO UNLOCK")
        self.gameDescription = SKLabelNode(text: gameTypeData.description())
        
        self.cloud = Utils.makeCloud(
            type: gameTypeData.type,
            nbPoints: Const.MenuChooseGame.nbDots,
            scene: scene,
            color: Const.accentColor,
            radius: self.cloudScale * 0.5 * Const.Cloud.sphereDiameterFactor * scene.minSize(),
            dotRadius: self.cloudScale * Const.Cloud.dotRadiusFactor * scene.minSize())
        self.cloud?.desalign(x: self.disalignment, y: self.disalignment)
        
        self.orb = Orb(scene: scene, diameter: self.cloudScale * Const.Orb.diameterFactor)
        self.button = MenuButton(scene: scene, text: "NICE", id: .unlockedGameOk)
        
        self.titlePosY = 0.92 * scene.size.height
        
        let explanationPosY = self.getTopSpaceCenterPosY(scene: scene) + 0.032 * scene.minSize()
        self.setTitle(scene: scene, posY: self.titlePosY)
        self.setExplanation(scene: scene, posY: explanationPosY)
        self.setGameDescription(scene: scene, posY: explanationPosY - 0.06 * scene.minSize()) // using minsize for fixed spacing
        self.button.shape.position = CGPoint(x: scene.center().x, y: self.getBottomSpaceCenterPosY(scene: scene))
        
        self.animateIn()
    }
    
    private func setTitle(scene: GameScene, posY: CGFloat) {
        self.title.fontColor = Const.labelColor
        self.title.fontName = Const.fontNameTitle
        self.title.fontSize = 0.15 * scene.minSize()
        self.title.position = CGPoint(x: scene.center().x, y: posY)
        self.title.verticalAlignmentMode = .center
        self.title.setScale(0) // will animate
        scene.addChild(self.title)
    }
    
    private func setExplanation(scene: GameScene, posY: CGFloat) {
        self.explanation.fontColor = Const.labelColor
        self.explanation.fontName = Const.fontNameLabel
        self.explanation.fontSize = 0.04 * scene.minSize()
        self.explanation.position = CGPoint(x: scene.center().x, y: posY)
        self.explanation.verticalAlignmentMode = .center
        self.explanation.setScale(0) // will animate
        scene.addChild(self.explanation)
    }
    
    private func setGameDescription(scene: GameScene, posY: CGFloat) {
        self.gameDescription.fontColor = Const.accentColor
        self.gameDescription.fontName = Const.fontNameTitle
        self.gameDescription.fontSize = 0.07 * scene.minSize()
        self.gameDescription.position = CGPoint(x: scene.center().x, y: posY)
        self.gameDescription.verticalAlignmentMode = .center
        self.gameDescription.setScale(0) // will animate
        scene.addChild(self.gameDescription)
    }
    
    private func getTopSpaceCenterPosY(scene: GameScene) -> CGFloat {
        // Not perfect, but adapts good enough.
        let orbRadius = 0.5 * self.cloudScale * Const.Orb.diameterFactor * scene.minSize()
        let orbTop = scene.center().y + orbRadius
        let center = 0.5 * (orbTop + self.titlePosY)
        return center
    }
    
    private func getBottomSpaceCenterPosY(scene: GameScene) -> CGFloat {
        let cloudRadius = 0.5 * self.cloudScale * Const.Cloud.sphereDiameterFactor * scene.minSize()
        let cloudBottom = scene.center().y - cloudRadius
        let bannerTop = Const.getBannerAdHeight()
        let center = 0.5 * (cloudBottom + bannerTop)
        return center
    }
    
    private func animateIn() {
        self.title.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        self.explanation.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        self.gameDescription.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        self.orb?.node.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        self.cloud?.animate(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        self.button.animate(SKAction.sequence([
            SKAction.scale(to: 0, duration: 0),
            SKAction.fadeAlpha(to: 1, duration: 0),
            SKAction.wait(forDuration: 0.4),
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
        self.explanation.removeFromParent()
        self.gameDescription.removeFromParent()
    }
}
