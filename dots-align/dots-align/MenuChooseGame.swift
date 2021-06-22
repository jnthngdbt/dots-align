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
    let cloud: Cloud?
    let orb: Orb?
    let description: SKLabelNode
    let startButton: FooterButton
    var homeButton: FooterHomeButton!
    var cloudType: GameType!
    
    init(scene: GameScene) {
        // Set cloud.
        let radius = 0.5 * Const.MenuChooseGame.sphereDiameterFactor * scene.minSize()
        let dotRadius = Const.MenuChooseGame.dotRadiusFactor * scene.minSize()
        
        self.cloudType = .shadow
        
        self.cloud = Cloud(nbPoints: 20, scene: scene, color: accentColor, radius: radius, dotRadius: dotRadius, type: self.cloudType)
        self.cloud?.desalign()
        
        self.orb = Orb(scene: scene)
        self.title = SKLabelNode(text: "SELECT TYPE")
        self.description = SKLabelNode(text: "SATELLITE // x6 BOOST")
        self.homeButton = FooterHomeButton(scene: scene)
        self.startButton = FooterButton(scene: scene, text: "START", id: .chooseGameStart, widthScaleFactor: Const.MenuChooseGame.startButtonWidthScaleFactor)
        
        self.setTitle(scene: scene)
        self.setDescription(scene: scene)
        self.setStartButton(scene: scene)
        
        self.animateIn()
    }
    
    func getGameTypeString(type: GameType) -> String {
        switch type {
        case .normal: return "NORMAL"
        case .satellite: return "SATELLITE"
        case .shadow: return "SHADOW"
        case .morph: return "MORPH"
        case .random: return "RANDOM"
        }
    }
    
    func setTitle(scene: GameScene) {
        let sphereRadius = 0.5 * Const.MenuChooseGame.sphereDiameterFactor * scene.minSize()
        let spaceLeft = 0.5 * scene.size.height - sphereRadius
        let posY = scene.center().y + sphereRadius + 0.5 * spaceLeft
        
        self.title.fontColor = labelColor
        self.title.fontName = Const.fontNameTitle
        self.title.fontSize = 0.15 * scene.minSize()
        self.title.position = CGPoint(x: scene.center().x, y: posY)
        self.title.zPosition = Const.Button.zPosition
        self.title.verticalAlignmentMode = .center
        scene.addChild(self.title)
    }
    
    func setDescription(scene: GameScene) {
        self.description.fontColor = labelColor
        self.description.fontName = Const.fontNameTitle
        self.description.fontSize = 0.07 * scene.minSize()
        self.description.position = CGPoint(x: scene.center().x, y: 0.2 * scene.size.height)
        self.description.zPosition = Const.Button.zPosition
        self.description.text = self.getGameTypeString(type: self.cloudType) + " // x6 BOOST"
        self.description.verticalAlignmentMode = .center
        self.description.horizontalAlignmentMode = .center
        self.description.lineBreakMode = .byWordWrapping
        self.description.numberOfLines = 0
        scene.addChild(self.description)
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
    
    private func animateIn() {
        self.animateInCloud()
        
        self.description.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeAlpha(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        self.startButton.animate(action: SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeAlpha(to: 1, duration: Const.Animation.expandSec)
        ]))
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
