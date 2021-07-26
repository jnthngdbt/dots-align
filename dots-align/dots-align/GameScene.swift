//
//  GameScene.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-01.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var game: Game?
    var menuMain: MenuMain?
    var menuEndGame: MenuEndGame?
    var menuChooseGame: MenuChooseGame?
    var scoreBoard: ScoreBoard?
    var gameMode = GameMode.level
    var gameType = GameType.normal
    var touchBeganOnButtonId: ButtonId?
    var adsDelegate: GameViewController?
    var gameCountForInterstitialAd = 0
    
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
    
    func getSafeAreaBottomPadding() -> CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows[0]
            return window.safeAreaInsets.bottom
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0
        }
    }
    
    // Scene will appear. Create content here. (not "touch moved")
    override func didMove(to view: SKView) {
        self.backgroundColor = Const.backgroundColor
        
        Music.instance.updateSounds(songIfUnmute: Const.Music.menu)
        
        self.showMainMenu()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.game != nil) {
            if self.game!.level.ended || self.game!.ended {
                return
            }
            
            self.touchRotate(touches: touches)
            self.game!.checkIfLevelSolved()
            if self.game!.level.ended {
                self.removeAction(forKey: Const.Level.boostCountdownKey) // otherwise it continues poping between levels
            }
        }
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
                if self.gameMode != .time { // end game animation is called by timer in this case
                    self.endGameAnimation()
                }
            }
        }
        
        // Make sure to reset button touch state at touch end.
        self.touchBeganOnButtonId = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) { }
    
    override func update(_ currentTime: TimeInterval) {
        self.menuMain?.update()
        self.menuChooseGame?.update()
    }
    
    func touchRotate(touches: Set<UITouch>) {
        if let t = touches.first {
            let dx = Scalar(t.location(in: self).x - t.previousLocation(in: self).x)
            let dy = Scalar(t.location(in: self).y - t.previousLocation(in: self).y)
            let v = Vector3d(dx, dy, 0)

            if (dx == 0) && (dy == 0) { return }
            
            self.game?.level.rotate(dir: v, speed: Const.Scene.orbitingSpeed)
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
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        self.touchBeganOnButtonId = buttonId
    }
    
    func manageButtonTapEnd(buttonId: ButtonId) {
        if buttonId == self.touchBeganOnButtonId {
            
            if buttonId == .tutorialId {
                self.startGame(mode: GameMode.tutorial)
            }
            else if buttonId == .startLevelGameId {
                self.showMenuChooseGame(mode: GameMode.level, type: self.gameType)
            }
            else if buttonId == .startTimedGameId {
                self.showMenuChooseGame(mode: GameMode.time, type: self.gameType)
            }
            else if buttonId == .replayGameId {
                self.showInterstitialAdIfNecessary({
                    self.startGame(mode: self.gameMode, type: self.gameType)
                })
            }
            else if buttonId == .homeId {
                self.showMainMenu()
            }
            else if buttonId == .endGameHomeId {
                self.showMainMenu()
            }
            else if buttonId == .tutorialInstructionsId {
                self.game?.instructions?.onButtonTap(scene: self)
            }
            else if buttonId == .chooseGameStart {
                if self.menuChooseGame != nil {
                    if !self.menuChooseGame!.isGameTypeLocked() {
                        self.showInterstitialAdIfNecessary({
                            self.startGame(mode: self.gameMode, type: self.menuChooseGame!.cloudType)
                        })
                    }
                }
            }
            else if buttonId == .chooseGameNavLeft {
                self.menuChooseGame?.onLeftTap(scene: self)
            }
            else if buttonId == .chooseGameNavRight {
                self.menuChooseGame?.onRightTap(scene: self)
            }
            else if buttonId == .scoreBoard {
                self.showScoreBoard()
            }
            else if buttonId == .scoreBoardLeft {
                self.scoreBoard?.onLeftTap(scene: self)
            }
            else if buttonId == .scoreBoardRight {
                self.scoreBoard?.onRightTap(scene: self)
            }
            else if buttonId == .soundsToggle {
                Music.instance.toggleSounds(songIfUnmute: Const.Music.menu)
                self.menuMain?.updateSoundButton()
            }
        }
        
        self.touchBeganOnButtonId = nil
    }
    
    func startGame(mode: GameMode, type: GameType = .normal) {
        self.gameMode = mode
        self.gameType = type
        
        self.clearScene()
        self.game = Game(scene: self, mode: mode, type: type)
        
        self.game?.animateIn()
        self.startGameCountdownIfNecessary(mode: mode)
        
        Music.instance.playSong(mode == .tutorial ? Const.Music.menu : Const.Music.game)
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
        let gameResults = self.game!.end()
        
        self.removeAction(forKey: Const.Level.boostCountdownKey) // otherwise it continues poping after animated out
        
        self.game?.level.cloud.animate(action: SKAction.scale(to: 0, duration: Const.Animation.collapseSec))
        self.game?.indicators?.animate(action: SKAction.scale(to: 0, duration: Const.Animation.collapseSec))
        
        let animation = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.scale(to: 0, duration: Const.Animation.collapseSec)
        ])
        
        if self.game?.orb != nil {
            self.game!.orb!.node.run(animation) {
                self.showEndGameMenu(gameResults: gameResults)
            }
        } else {
            self.showEndGameMenu(gameResults: gameResults)
        }
    }
    
    func showMainMenu() {
        self.clearScene()
        self.menuMain = MenuMain(scene: self)
        
        Music.instance.playSong(Const.Music.menu)
    }
    
    func showMenuChooseGame(mode: GameMode, type: GameType) {
        self.gameMode = mode
        self.gameType = type
        
        self.clearScene()
        self.menuChooseGame = MenuChooseGame(scene: self)
        
        Music.instance.playSong(Const.Music.menu)
    }
    
    func showEndGameMenu(gameResults: GameEntity?) {
        self.gameCountForInterstitialAd += 1 // only consider completed games for interstitial ads, I'm a good guy
        
        let score = self.game?.score ?? 0
        let bestScore = gameResults?.bestScore ?? 0
        
        self.clearScene()
        self.menuEndGame = MenuEndGame(scene: self, score: score, bestScore: Int(bestScore))
        
        Music.instance.playSong(Const.Music.game)
    }
    
    func showScoreBoard() {
        self.clearScene()
        self.scoreBoard = ScoreBoard(scene: self)
        
        Music.instance.playSong(Const.Music.menu)
    }
    
    func clearGame() {
        self.game = nil
        self.removeAction(forKey: Const.Game.countdownKey)
        self.removeAction(forKey: Const.Level.boostCountdownKey) // otherwise, game stays in bg when clicking home button
    }
    
    func clearScene() {
        self.clearGame()
        self.menuMain = nil
        self.menuEndGame = nil
        self.menuChooseGame = nil
        self.scoreBoard = nil
    }
    
    func showInterstitialAdIfNecessary(_ completionHandler: (() -> Void)? = nil) {
        if self.gameCountForInterstitialAd < Const.Ads.nbGamesForInterstitialAd {
            completionHandler?() // no ad, just execute callback directly
        } else { // show ad
            self.gameCountForInterstitialAd = 0
            if self.adsDelegate != nil {
                Music.instance.stop()
                self.adsDelegate?.showInterstitialAd(completionHandler)
            }
        }
    }
}
