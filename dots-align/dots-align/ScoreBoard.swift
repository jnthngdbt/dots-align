//
//  ScoreBoard.swift
//  dots-align
//
//  Created by Jonathan on 2021-07-08.
//

import Foundation
import SpriteKit

class ScoreBoard {
    enum StatType: Int, CaseIterable { case best, average, count }
    
    let title: SKLabelNode
    let homeButton: FooterHomeButton
    
    let hdrGame: SKLabelNode
    let hdrLevel: SKLabelNode
    let hdrTimed: SKLabelNode
    
    let hdrLine = SKShapeNode()
    
    var rowsGame: [SKLabelNode] = []
    var rowsLevel: [SKLabelNode] = []
    var rowsTime: [SKLabelNode] = []
    
    let description: SKLabelNode
    let left: Button
    let right: Button
    
    var statType = StatType.allCases.first!
    
    let titlePosY: CGFloat = 0.85
    let hdrPosY: CGFloat = 0.68
    let hdrSpacing: CGFloat = 0.075
    let rowSpacing: CGFloat = 0.06
    let statTypePosY: CGFloat = 0.3
    
    let colWidth: CGFloat = 0.3
    
    let sidePadding: CGFloat
    let colGamePosX: CGFloat
    let colLevelPosX: CGFloat
    let colTimePosX: CGFloat
    
    init(scene: GameScene) {
        self.title = SKLabelNode(text: "SCORE BOARD")
        self.homeButton = FooterHomeButton(scene: scene)
        
        self.hdrGame = SKLabelNode(text: "GAME TYPE")
        self.hdrLevel = SKLabelNode(text: "LEVEL MODE")
        self.hdrTimed = SKLabelNode(text: "TIME MODE")
        
        self.sidePadding = 0.5 * (1 - 3 * self.colWidth)
        self.colGamePosX = self.sidePadding + 0.5 * self.colWidth
        self.colLevelPosX = self.sidePadding + 1.5 * self.colWidth
        self.colTimePosX = self.sidePadding + 2.5 * self.colWidth
        
        for type in GameType.allCases {
            let bestLevel = DatabaseManager.getBestScore(gameMode: .level, gameType: type)
            let bestTime = DatabaseManager.getBestScore(gameMode: .time, gameType: type)
            
            self.rowsGame.append(SKLabelNode(text: getGameTypeString(type: type)))
            self.rowsLevel.append(SKLabelNode(text: bestLevel != nil ? String(bestLevel!) : "--"))
            self.rowsTime.append(SKLabelNode(text: bestTime != nil ? String(bestTime!) : "--"))
        }
        
        let navButtonSize = CGSize(width: 0.12 * scene.size.width, height: 0.12 * scene.size.width)
        self.description = SKLabelNode(text: "BEST SCORE")
        self.left = Button(scene: scene, text: "◁", size: navButtonSize, id: .scoreBoardLeft)
        self.right = Button(scene: scene, text: "▷", size: navButtonSize, id: .scoreBoardRight)
        
        self.setTitle(scene: scene)
        
        self.setHeaderLabel(scene: scene, label: self.hdrGame, posX: self.colGamePosX)
        self.setHeaderLabel(scene: scene, label: self.hdrLevel, posX: self.colLevelPosX)
        self.setHeaderLabel(scene: scene, label: self.hdrTimed, posX: self.colTimePosX)
        
        self.setHeaderLine(scene: scene)
        
        self.setRowsLabels(scene: scene, labels: self.rowsGame, posX: self.colGamePosX)
        self.setRowsLabels(scene: scene, labels: self.rowsLevel, posX: self.colLevelPosX)
        self.setRowsLabels(scene: scene, labels: self.rowsTime, posX: self.colTimePosX)
        
        self.setDescription(scene: scene)
        self.setNavButtons(scene: scene)
        
        self.animateIn()
    }
    
    private func setTitle(scene: GameScene) {
        self.title.fontColor = labelColor
        self.title.fontName = Const.fontNameTitle
        self.title.fontSize = 0.15 * scene.minSize()
        self.title.position = CGPoint(x: scene.center().x, y: self.titlePosY * scene.size.height)
        self.title.verticalAlignmentMode = .center
        self.title.setScale(0) // will animate
        scene.addChild(self.title)
    }
    
    private func setHeaderLabel(scene: GameScene, label: SKLabelNode, posX: CGFloat) {
        label.fontColor = labelColor
        label.fontName = Const.fontNameLabel
        label.fontSize = 0.05 * scene.minSize()
        label.position = CGPoint(x: posX * scene.size.width, y: self.hdrPosY * scene.size.height)
        label.verticalAlignmentMode = .center
        label.alpha = 0 // will animate
        scene.addChild(label)
    }
    
    private func setHeaderLine(scene: GameScene) {
        let posY = (self.hdrPosY - 0.5 * self.hdrSpacing) * scene.size.height
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: scene.size.width * self.sidePadding, y: posY))
        pathToDraw.addLine(to: CGPoint(x: scene.size.width * (1 - self.sidePadding), y: posY))
        
        self.hdrLine.path = pathToDraw
        self.hdrLine.strokeColor = UIColor(white: 0.2, alpha: 1)
        self.hdrLine.alpha = 0 // will animate
        scene.addChild(self.hdrLine)
    }
    
    private func setRowsLabels(scene: GameScene, labels: [SKLabelNode], posX: CGFloat) {
        var row: CGFloat = 1
        for label in labels {
            let spacing = row == 1 ? self.hdrSpacing : self.hdrSpacing + (row - 1) * self.rowSpacing
            label.fontColor = accentColor
            label.fontName = Const.fontNameLabel
            label.fontSize = 0.05 * scene.minSize()
            label.position = CGPoint(x: posX * scene.size.width, y: (self.hdrPosY - spacing) * scene.size.height)
            label.verticalAlignmentMode = .center
            label.alpha = 0 // will animate
            scene.addChild(label)
            row += 1
        }
    }
    
    private func setDescription(scene: GameScene) {
        self.description.fontColor = labelColor
        self.description.fontName = Const.fontNameLabel
        self.description.fontSize = 0.05 * scene.minSize()
        self.description.position = CGPoint(x: scene.center().x, y: self.statTypePosY * scene.size.height)
        self.description.zPosition = Const.Button.zPosition
        self.description.verticalAlignmentMode = .center
        self.description.horizontalAlignmentMode = .center
        self.description.lineBreakMode = .byWordWrapping
        self.description.numberOfLines = 0
        self.description.alpha = 0 // will animate
        scene.addChild(self.description)
        
        self.updateDescription()
    }
    
    func setNavButtons(scene: GameScene) {
        let padding = (self.sidePadding + 0.5 * self.colWidth) * scene.size.width
        self.left.shape.position = CGPoint(x: padding, y: self.statTypePosY * scene.size.height)
        self.right.shape.position = CGPoint(x: scene.size.width - padding, y: self.statTypePosY * scene.size.height)
        
        self.left.shape.fillColor = UIColor.clear
        self.right.shape.fillColor = UIColor.clear
        
        self.updateNavButtons()
    }
    
    private func getStatTypeString(type: StatType) -> String {
        switch type {
        case .best: return "BEST SCORE"
        case .average: return "AVERAGE SCORE"
        case .count: return "GAME COUNT"
        }
    }
    
    func updateDescription() {
        self.description.text = self.getStatTypeString(type: self.statType)
    }
    
    func updateNavButtons() {
        self.left.shape.alpha = self.mustShowLeftNavButton() ? 1 : 0
        self.right.shape.alpha = self.mustShowRightNavButton() ? 1 : 0
    }
    
    func mustShowLeftNavButton() -> Bool {
        return self.statType.rawValue > 0
    }
    
    func mustShowRightNavButton() -> Bool {
        return self.statType.rawValue < StatType.allCases.count - 1
    }
    
    func onLeftTap(scene: GameScene) {
        self.changeStatType(type: StatType(rawValue: self.statType.rawValue - 1))
    }
    
    func onRightTap(scene: GameScene) {
        self.changeStatType(type: StatType(rawValue: self.statType.rawValue + 1))
    }
    
    private func changeStatType(type: StatType?) {
        if type == nil { return }
        self.statType = type!
        self.updateDescription()
        self.updateNavButtons()
    }
    
    private func animateIn() {
        self.title.run(SKAction.sequence([
            SKAction.wait(forDuration: Const.Animation.titleAppearWait),
            SKAction.scale(to: 1, duration: Const.Animation.expandSec)
        ]))
        
        let tableAnimation = SKAction.sequence([
            SKAction.wait(forDuration: 2.0 * Const.Animation.titleAppearWait),
            SKAction.fadeAlpha(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.hdrGame.run(tableAnimation)
        self.hdrLevel.run(tableAnimation)
        self.hdrTimed.run(tableAnimation)
        
        self.hdrLine.run(tableAnimation)
        
        for row in self.rowsGame { row.run(tableAnimation) }
        for row in self.rowsLevel { row.run(tableAnimation) }
        for row in self.rowsTime { row.run(tableAnimation) }
        
        let statTypeAnimation = SKAction.sequence([
            SKAction.fadeAlpha(to: 0, duration: 0),
            SKAction.wait(forDuration: 3.0 * Const.Animation.titleAppearWait),
            SKAction.fadeAlpha(to: 1, duration: Const.Animation.expandSec)
        ])
        
        self.description.run(statTypeAnimation)
        if (self.mustShowLeftNavButton()) { self.left.animate(action: statTypeAnimation) }
        if (self.mustShowRightNavButton()) { self.right.animate(action: statTypeAnimation) }
    }
    
    deinit {
        self.title.removeFromParent()
        
        self.hdrGame.removeFromParent()
        self.hdrLevel.removeFromParent()
        self.hdrTimed.removeFromParent()
        
        self.hdrLine.removeFromParent()
        
        for row in self.rowsGame { row.removeFromParent() }
        for row in self.rowsLevel { row.removeFromParent() }
        for row in self.rowsTime { row.removeFromParent() }
        
        self.description.removeFromParent()
    }
}
