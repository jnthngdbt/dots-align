//
//  MainMenu.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

class MenuMain: Menu {
    let cloud: Cloud?
    let title: SKLabelNode!
    let soundButton: Button
    
    init(scene: GameScene) {
        // Set cloud.
        let radius = 0.5 * Const.MenuMain.sphereDiameterFactor * scene.minSize()
        let dotRadius = Const.MenuMain.dotRadiusFactor * scene.minSize()
        self.cloud = Cloud(nbPoints: Const.MenuMain.sphereNbDots, scene: scene, color: Const.MenuMain.sphereDotsColor, radius: radius, dotRadius: dotRadius)
        self.cloud?.desalign()
        
        self.title = SKLabelNode(text: "ALIGN DOTS")
        
        let soundRadius = Const.Button.Menu.heightFactor * scene.minSize()
        self.soundButton = Button(scene: scene, text: "SOUND", size: CGSize(width: soundRadius, height: soundRadius), id: .soundsToggle)
        
        super.init()
        
        self.buttons.append(MenuButton(scene: scene, text: "GET STARTED", id: ButtonId.tutorialId))
        
        let levelGameText = "PLAY " + String(Const.Game.maxLevel) + " LEVELS"
        self.buttons.append(MenuButton(scene: scene, text: levelGameText, id: ButtonId.startLevelGameId))
        
        let timeGameText = "PLAY " + String(Const.Game.maxSeconds) + " SECONDS"
        self.buttons.append(MenuButton(scene: scene, text: timeGameText, id: ButtonId.startTimedGameId))
        
        self.buttons.append(MenuButton(scene: scene, text: "SCORE BOARD", id: ButtonId.scoreBoard))
        
        self.arrange(scene: scene)
        
        self.setTitle(scene: scene)
        self.setSoundButton(scene: scene)
        
        self.animateIn()
    }
    
    func setTitle(scene: GameScene) {
        // Center title between screen top and buttons.
        let buttonTopPos = self.getTopPosition(scene: scene)
        let titlePosX = self.buttons.last!.shape.position.x
        let titlePosY = buttonTopPos.y + 0.5 * (scene.size.height - buttonTopPos.y)
        
        self.title.fontColor = labelColor
        self.title.fontName = Const.fontNameTitle
        self.title.fontSize = 0.16 * scene.minSize()
        self.title.position = CGPoint(x: titlePosX, y: titlePosY)
        self.title.zPosition = self.buttons.last!.shape.zPosition
        self.title.verticalAlignmentMode = .center
        self.title.setScale(0)
        scene.addChild(self.title)
    }
    
    func setSoundButton(scene: GameScene) {
        let x = scene.center().x
        let y = self.getBottomPosition(scene: scene).y - (Const.MenuMain.spacingFactor + 0.5 * Const.Button.Menu.heightFactor) * scene.minSize()
        self.soundButton.shape.fillColor = UIColor.clear
        self.soundButton.shape.strokeColor = Const.Button.fillColor
        self.soundButton.shape.lineWidth = 3
        self.soundButton.shape.position = CGPoint(x: x, y: y)
        self.soundButton.label.fontColor = labelColor
        self.soundButton.label.fontSize = 0.03 * scene.minSize()
        self.updateSoundButton()
    }
    
    func updateSoundButton() {
        self.soundButton.label.fontColor = Music.instance.isMuted() ? labelColor : accentColor
    }
    
    func update() {
        let dt = 0.016 // ms for 60 hz
        let radPerSec = Scalar.pi / 60
        let rad = dt * radPerSec
        let q = Quat(angle: rad, axis: simd_normalize(Vector3d(-1, 1, 0)))
        self.cloud?.rotate(quaternion: q)
    }
    
    private func animateIn() {
        self.title.run(SKAction.sequence([
            SKAction.wait(forDuration: Const.Animation.titleAppearWait),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        self.animateInButtons()
        self.animateInCloud()
    }
    
    private func animateInCloud() {
        let animation = SKAction.sequence([
            SKAction.fadeAlpha(to: 0, duration: 0.0),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeAlpha(to: 1, duration: 1.0)
        ])
        
        self.cloud?.animateIn(action: animation)
    }
    
    private func animateInButtons() {
        let animation = SKAction.sequence([
            SKAction.scale(to: 0, duration: 0.0),
            SKAction.wait(forDuration: 0.25),
            SKAction.fadeAlpha(to: 1, duration: 0.0),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.animateButtons(action: animation)
        
        self.soundButton.animate(action: animation)
    }
    
    deinit {
        self.title.removeFromParent()
    }
}
