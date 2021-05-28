//
//  Constants.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

enum IndicatorNames: Int, CaseIterable { case left, dots, boost, score  }
enum GameMode: Int, CaseIterable { case tutorial, level, time  }

enum ButtonId: String, CaseIterable { case
    none = "",
    tutorialId = "tutorial",
    startLevelGameId = "startLevelGame",
    startTimedGameId = "startTimedGame",
    replayGameId = "replayGame",
    homeId = "home",
    tutorialInstructionsId = "tutorialInstructions"
}

func isButton(name: String?) -> Bool {
    if name == nil { return false }
    let id = ButtonId(rawValue: name!)
    return (id != nil) && (id != ButtonId.none)
}

let labelColor = UIColor(white: 0.45, alpha: 1)
let accentColor = UIColor(red: 0.55, green: 0.45, blue: 1.0, alpha: 1)

class Const {
    class Dot {
        static let radiusFactor: CGFloat = 0.022
        static let colorBrightnessFactorAmplitude: CGFloat = 0.5
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
    }
    
    class Level {
        static let maxMultiplier: Int = 5
        static let maxAngleCumul = 1.5 * Scalar.pi
    }
    
    class Game {
        static let minNbPoints = 4
        static let maxNbPoints = 30
        static let startNbPoints = 15
        static let maxLevel = 20
        static let maxSeconds = 60
        static let countdownKey = "gameCountdown"
        static let sphereDiameterFactor: CGFloat = 0.6
    }
    
    class Scene {
        static let orbitingSpeed = 2.0
        static let orbDiameterFactor: CGFloat = 0.5
    }
    
    class Indicators {
        static let fontColor = labelColor
        static let fontColorHighlight = UIColor(white: 0.8, alpha: 1)
        static let sidePaddingFactor: CGFloat = 0.14
    }
    
    class Menu {
        static let spacingFactor: CGFloat = 0.025
        static let sphereDiameterFactor: CGFloat = 2.0
        static let sphereNbDots = 220
        static let sphereDotsColor = UIColor(white: 0.3, alpha: 1)
        static let dotRadiusFactor: CGFloat = 0.005
    }
    
    class Button {
        static let fillColor = UIColor(white: 0.15, alpha: 1)
        static let fontColor = accentColor
        static let fontSizeFactor: CGFloat = 0.07
        static let widthFactor: CGFloat = 0.65
        static let heightFactor: CGFloat = 0.14
        static let zPosition: CGFloat = 5.0
    }
    
    class Animation {
        static let collapseSec = 0.15
        static let expandSec = 0.15
        static let blinkSec = 0.06
        static let blinkWaitSec = 0.3
        static let scoreRiseSec = 0.2
    }
    
    static let backgroundColor = UIColor(white: 0.0, alpha: 1)
    
    // Default: HelveticaNeue-UltraLight.
    // Some nice: HelveticaNeue, AvenirNextCondensed, AvenirNext
    // Heavy, Bold, DemiBold, Medium, Regular, UltraLight.
    static let fontNameText = "AvenirNextCondensed-DemiBold"
    static let fontNameLabel = "AvenirNextCondensed-Bold"
    static let fontNameTitle = "AvenirNextCondensed-Heavy"
    
    static let debug = false
}
