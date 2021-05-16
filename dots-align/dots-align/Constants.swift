//
//  Constants.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-05-12.
//

import Foundation
import SpriteKit

enum IndicatorNames: Int, CaseIterable { case left, dots, bonus, score  }

class Const {
    class Dot {
        static let radiusFactor: CGFloat = 0.02
        static let depthColorAmplitude: CGFloat = 0.3
    }
    
    class Cloud {
        static let alignedOrientation = Vector3d(0, 0, 1)
        static let alignedDistThresh = 0.05
        static let color = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    }
    
    class Orb {
        static let color = UIColor(white: 0, alpha: 0.4)
    }
    
    class Level {
        static let minNbPoints = 4
        static let maxNbPoints = 30
        static let maxMultiplier = 5
        static let maxAngleCumul = 1.5 * Scalar.pi
    }
    
    class Game {
        static let maxLevel = 5
        static let maxSeconds = 60
        static let sphereDiameterFactor: CGFloat = 0.6
    }
    
    class Scene {
        static let orbitingSpeed = 2.0
        static let orbDiameterFactor: CGFloat = 0.5
    }
    
    class Indicators {
        static let fontColor = UIColor(white: 0.4, alpha: 1)
        static let fontColorHighlight = UIColor(white: 0.8, alpha: 1)
    }
    
    class Menu {
        static let spacingFactor: CGFloat = 0.025
        static let sphereDiameterFactor: CGFloat = 2.0
        static let sphereNbDots = 200
        static let sphereDotsColor = UIColor(white: 0.3, alpha: 0.6)
    }
    
    class Button {
        static let fillColor = UIColor(white: 0.1, alpha: 1)
        static let fontColor = UIColor(red: 0.5, green: 0.5, blue: 0.8, alpha: 1)
        static let fontSizeFactor: CGFloat = 0.08
        static let widthFactor: CGFloat = 0.75
        static let heightFactor: CGFloat = 0.18
        
        static let tutorialId = "tutorial"
        static let startLevelGameId = "startLevelGame"
        static let startTimedGameId = "startTimedGame"
        static let replayGameId = "replayGame"
        static let homeId = "home"
    }
    
    static let backgroudColor = UIColor(white: 0.15, alpha: 0)
    
    // Default: HelveticaNeue-UltraLight.
    // Some nice: HelveticaNeue, AvenirNextCondensed, AvenirNext
    // Heavy, Bold, DemiBold, Medium, Regular, UltraLight.
    static let fontName = "AvenirNextCondensed-Bold"
    
    static let debug = false
}
