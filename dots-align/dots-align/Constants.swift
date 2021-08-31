//
//  Constants.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit
import GoogleMobileAds

enum BuildMode { case dev, demo, publish }
enum IndicatorNames: Int, CaseIterable { case left, dots, boost, score  }
enum GameMode: Int, CaseIterable { case tutorial, level, time  } // keep order, saved in core data
enum GameType: Int, CaseIterable { case normal, satellite, shadow, transit, rewire, mirage } // keep order, saved in core data

enum ButtonId: String, CaseIterable { case
    none = "",
    tutorialId = "tutorial",
    startLevelGameId = "startLevelGame",
    startTimedGameId = "startTimedGame",
    scoreBoard = "scoreBoard",
    soundsToggle = "soundsToggle",
    replayGameId = "replayGame",
    homeId = "home",
    endGameHomeId = "endGameHomeId",
    tutorialInstructionsId = "tutorialInstructions",
    chooseGameStart = "chooseGameStart",
    chooseGameNavLeft = "chooseGameNavLeft",
    chooseGameNavRight = "chooseGameNavRight",
    scoreBoardLeft = "scoreBoardLeft",
    scoreBoardRight = "scoreBoardRight",
    scoreBoardLeaderboards = "scoreBoardLeaderboards",
    unlockedGameOk = "unlockedGameOk"
}

enum LeaderboardId: String, CaseIterable { case
    boardClassicNormalTimed  = "classic.normal.timed",
    boardClassicNormalLevels = "classic.normal.levels",
    boardClassicSatelliteTimed  = "classic.satellite.timed",
    boardClassicSatelliteLevels = "classic.satellite.levels",
    boardClassicShadowTimed  = "classic.shadow.timed",
    boardClassicShadowLevels = "classic.shadow.levels",
    boardClassicMirageTimed  = "classic.mirage.timed",
    boardClassicMirageLevels = "classic.mirage.levels",
    boardClassicRewireTimed  = "classic.rewire.timed",
    boardClassicRewireLevels = "classic.rewire.levels",
    boardClassicTransitTimed  = "classic.transit.timed",
    boardClassicTransitLevels = "classic.transit.levels",
    boardClassicOverallBest = "classic.overall.best",
    boardClassicOverallCount = "classic.overall.count"
//        static let boardClassicOverallTotal = "classic.overall.total"
}

class GameTypeData {
    let type: GameType
    let maxBoost: Int
    let nbGamesToUnlock: Int
    let string: String
    
    init(type: GameType, maxBoost: Int, nbGamesToUnlock: Int, string: String) {
        self.type = type
        self.maxBoost = maxBoost
        self.nbGamesToUnlock = nbGamesToUnlock
        self.string = string
    }
    
    func description() -> String {
        return self.string + " // x" + String(self.maxBoost) + " BOOST"
    }
}

func isButton(name: String?) -> Bool {
    if name == nil { return false }
    let id = ButtonId(rawValue: name!)
    return (id != nil) && (id != ButtonId.none)
}

class Const {
    static let backgroundColor = UIColor(white: 0.0, alpha: 1)
    static let labelColor = UIColor(white: 0.55, alpha: 1)
    static let accentColor = UIColor(red: 0.55, green: 0.45, blue: 1.0, alpha: 1)
    static let disabledButtonFontColor = UIColor(white: 0.3, alpha: 1)
    
    static let buildMode = BuildMode.publish
    
    // Default: HelveticaNeue-UltraLight.
    // Some nice: HelveticaNeue, AvenirNextCondensed, AvenirNext
    // Heavy, Bold, DemiBold, Medium, Regular, UltraLight.
    static let fontNameText = "AvenirNextCondensed-DemiBold"
    static let fontNameLabel = "AvenirNextCondensed-Bold"
    static let fontNameTitle = "AvenirNextCondensed-Heavy"
    
    static let gameTypeDataArray = [
        GameTypeData(type: .normal      , maxBoost: 4   , nbGamesToUnlock: 0   , string: "NORMAL"      ),
        GameTypeData(type: .satellite   , maxBoost: 6   , nbGamesToUnlock: 10  , string: "SATELLITE"   ),
        GameTypeData(type: .shadow      , maxBoost: 8   , nbGamesToUnlock: 20  , string: "SHADOW"      ),
        GameTypeData(type: .mirage      , maxBoost: 10  , nbGamesToUnlock: 30  , string: "MIRAGE"      ),
        GameTypeData(type: .rewire      , maxBoost: 12  , nbGamesToUnlock: 40  , string: "REWIRE"      ),
        GameTypeData(type: .transit     , maxBoost: 14  , nbGamesToUnlock: 50  , string: "TRANSIT"     ),
    ]
    
    class Ads {
        static let bannerSize = kGADAdSizeBanner
        static let adUnitIdBannerTest = "ca-app-pub-3940256099942544/2934735716"
        static let adUnitIdBannerProd = "ca-app-pub-5717735254954222/5157693143"
        static let adUnitIdInterstitialTest = "ca-app-pub-3940256099942544/4411468910"
        static let adUnitIdInterstitialProd = "ca-app-pub-5717735254954222/7972053580"
        static let nbGamesForInterstitialAd = 3
    }
    
    class AppStore {
        static let nbGamesMultipleForAskReview = 11
    }
    
    class UserDataKeys {
        static let isSoundMuted = "isSoundMuted"
        static let lastGameTypeSelected = "lastGameTypeSelected"
        static let isUserRegisteredToLeaderboards = "isUserRegisteredToLeaderboards"
        // using GameCenter leaderboard IDs as keys for scores
    }
    
    class Dot {
        static let colorBrightnessFactorAmplitude: CGFloat = 0.5
        static let colorBrightnessFactorAmplitudeShadow: CGFloat = 1.5
        static let colorHueAmplitude: CGFloat = 0.03
    }
    
    class Cloud {
        static let sphereDiameterFactor: CGFloat = 0.6
        static let dotRadiusFactor: CGFloat = 0.022
        static let alignedOrientation = Vector3d(0, 0, 1)
        static let alignedDistThresh = 0.05
        static let color = accentColor
        static let lockedColor = UIColor(white: 0.3, alpha: 1)
        static let guideDotsColor = UIColor.red
    }
    
    class Tutorial {
        static let dotsColor = accentColor
    }
    
    class Orb {
        static let color = UIColor(white: 0.2, alpha: 0.55)
        static let diameterFactor: CGFloat = 0.5
    }
    
    class Level {
        static let levelScoreFontSizeFactor: CGFloat = 0.1
        static let levelScoreEndPosOffsetFactor: CGFloat = 0.035
        static let boostCountdownKey = "boostCountdown"
        static let boostCountdownBaseDuration: CGFloat = 5.0
        static let boostCountdownDurationRampFactorSecsPerBoost: CGFloat = 0.6 // duration = baseDuration + (maxBoost - minBoost) * factor
        static let boostPerAngle = 1 / (0.45 * Scalar.pi)
        static let boostStepSec: CGFloat = 0.1
    }
    
    class Game {
        static let minNbPoints = 4
        static let maxNbPoints = 30
        static let startNbPoints = 15
        static let maxLevel = 10
        static let maxSeconds = 30
        static let countdownKey = "gameCountdown"
    }
    
    class Scene {
        static let orbitingSpeed = 2.0
    }
    
    class Indicators {
        static let fontColor = labelColor
        static let fontColorHighlight = UIColor(white: 0.8, alpha: 1)
        static let layoutSphereFactor: CGFloat = 0.88
        static let sidePaddingFactor: CGFloat = 0.14
        static let verticalSpacingFactor: CGFloat = 0.08
        static let gaugeWidthFactor: CGFloat = 0.1
        static let gaugeHeightFactor: CGFloat = 0.02
        static let newValueAnimationScale: CGFloat = 1.3
    }
    
    class MenuMain {
        static let spacingFactor: CGFloat = 0.025
        static let sphereDiameterFactor: CGFloat = 2.0
        static let sphereNbDots = 220
        static let sphereDotsColor = UIColor(white: 0.3, alpha: 1)
        static let dotRadiusFactor: CGFloat = 0.003
    }
    
    class MenuChooseGame {
        static let nbDots = 20
        static let startButtonWidthScaleFactor: CGFloat = 2.0
    }
    
    class ScoreBoard {
        static let leaderboardsButtonWidthScaleFactor: CGFloat = 3.2
    }
    
    class Button {
        static let fillColor = UIColor(white: 0.15, alpha: 1)
        static let fontColor = accentColor
        static let zPosition: CGFloat = 5.0
        
        class Menu {
            static let fontSizeFactor: CGFloat = 0.07
            static let widthFactor: CGFloat = 0.65
            static let heightFactor: CGFloat = 0.14
        }
        
        class Footer {
            static let fontSizeFactor: CGFloat = 0.06
            static let widthFactor: CGFloat = 0.15
            static let heightFactor: CGFloat = 0.1
        }
    }
    
    class Animation {
        static let collapseSec = 0.15
        static let expandSec = 0.15
        static let blinkSec = 0.06
        static let blinkWaitSec = 0.3
        static let scoreRiseSec = 0.2
        static let scoreRiseWaitSec = 0.3
        static let titleAppearWait = 0.1
    }
    
    class Music {
        static let game = "Game"
        static let menu = "Menu"
        static let beeps = ["Beep.C2", "Beep.G2", "Beep.C3"] // enough, but not too much, getting the C3 is accessible
    }
    
    class Debug {
        static let showBtnEdges = false
        static let showGuideDots = false
        static let showCloudDebug = false
        static let showStats = false
        static let skipSaveGameResult = false
    }

    static func mustShowAds() -> Bool {
        return Const.buildMode != .demo
    }
    
    static func getBannerAdHeight() -> CGFloat {
        return Const.mustShowAds() ? Const.Ads.bannerSize.size.height : 0
    }
    
    static func getGameTypeData(_ type: GameType) -> GameTypeData {
        for g in Const.gameTypeDataArray {
            if g.type == type { return g }
        }
        return Const.gameTypeDataArray.first!
    }
    
    static func getGameTypeDataIndex(_ type: GameType) -> Int {
        for i in 0..<Const.gameTypeDataArray.count {
            if Const.gameTypeDataArray[i].type == type { return i }
        }
        return 0
    }
    
    static func getNextUnlockedGame(gameCount: Int) -> GameTypeData? {
        var next: GameTypeData? = nil
        
        for g in Const.gameTypeDataArray {
            if gameCount < g.nbGamesToUnlock {
                if (next == nil) || (g.nbGamesToUnlock < next!.nbGamesToUnlock) {
                    next = g
                } 
            }
        }
        
        return next
    }
}
