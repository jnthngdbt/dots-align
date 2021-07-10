//
//  Constants.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit
import GoogleMobileAds

enum IndicatorNames: Int, CaseIterable { case left, dots, boost, score  }
enum GameMode: Int, CaseIterable { case tutorial, level, time  } // keep order, saved in core data
enum GameType: Int, CaseIterable { case normal, satellite, shadow, transit } // keep order, saved in core data

enum ButtonId: String, CaseIterable { case
    none = "",
    tutorialId = "tutorial",
    startLevelGameId = "startLevelGame",
    startTimedGameId = "startTimedGame",
    scoreBoard = "scoreBoard",
    replayGameId = "replayGame",
    homeId = "home",
    endGameHomeId = "endGameHomeId",
    tutorialInstructionsId = "tutorialInstructions",
    chooseGameStart = "chooseGameStart",
    chooseGameNavLeft = "chooseGameNavLeft",
    chooseGameNavRight = "chooseGameNavRight"
}

func isButton(name: String?) -> Bool {
    if name == nil { return false }
    let id = ButtonId(rawValue: name!)
    return (id != nil) && (id != ButtonId.none)
}

let labelColor = UIColor(white: 0.55, alpha: 1)
let accentColor = UIColor(red: 0.55, green: 0.45, blue: 1.0, alpha: 1)

class Const {
    class Ads {
        static let bannerSize = kGADAdSizeBanner
        static let adUnitIdBannerTest = "ca-app-pub-3940256099942544/2934735716"
        static let adUnitIdBannerProd = "ca-app-pub-5717735254954222/5157693143"
        static let adUnitIdInterstitialTest = "ca-app-pub-3940256099942544/4411468910"
        static let adUnitIdInterstitialProd = "ca-app-pub-5717735254954222/7972053580"
        static let nbGamesForInterstitialAd = 3
    }
    
    class Dot {
        static let colorBrightnessFactorAmplitude: CGFloat = 0.5
        static let colorBrightnessFactorAmplitudeShadow: CGFloat = 1.5
        static let colorHueAmplitude: CGFloat = 0.03
    }
    
    class Cloud {
        static let alignedOrientation = Vector3d(0, 0, 1)
        static let alignedDistThresh = 0.05
        static let color = accentColor
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
        static let sphereDiameterFactor: CGFloat = 0.6
        static let dotRadiusFactor: CGFloat = 0.022
        static let levelScoreFontSizeFactor: CGFloat = 0.1
        static let levelScoreEndPosOffsetFactor: CGFloat = 0.035
        static let makeBoostDecreaseWithTimeInTimeGame = true
        static let boostCountdownSec = 6.0
        static let boostCountdownNbSteps = 20
        static let boostCountdownKey = "boostCountdown"
        static let boostPerAngle = 1 / (0.45 * Scalar.pi)
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
        static let sphereDiameterFactor: CGFloat = 0.6
        static let dotRadiusFactor: CGFloat = 0.022
        static let startButtonWidthScaleFactor: CGFloat = 2.0
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
        static let showStats = false
    }
    
    static let backgroundColor = UIColor(white: 0.0, alpha: 1)
    
    // Default: HelveticaNeue-UltraLight.
    // Some nice: HelveticaNeue, AvenirNextCondensed, AvenirNext
    // Heavy, Bold, DemiBold, Medium, Regular, UltraLight.
    static let fontNameText = "AvenirNextCondensed-DemiBold"
    static let fontNameLabel = "AvenirNextCondensed-Bold"
    static let fontNameTitle = "AvenirNextCondensed-Heavy"

}

func getMaxBoost(type: GameType) -> Int {
    switch type {
    case .normal: return 4
    case .satellite: return 6
    case .shadow: return 8
    case .transit: return 10
    }
}

func getGameTypeString(type: GameType) -> String {
    switch type {
    case .normal: return "NORMAL"
    case .satellite: return "SATELLITE"
    case .shadow: return "SHADOW"
    case .transit: return "TRANSIT"
    }
}
