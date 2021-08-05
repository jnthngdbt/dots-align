//
//  GameCenter.swift
//  dots-align
//
//  Created by Jonathan on 2021-08-02.
//

import Foundation
import GameKit

class GameCenter {
    static func isAuthenticated() -> Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    static func submit(_ value: Int, leaderboard: String) {
        GKLeaderboard.submitScore(value, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboard]) { error in
            print(error.debugDescription)
        }
    }
    
    static func getLeaderBoardIdForScore(mode: GameMode, type: GameType) -> String {
        switch mode {
        case .level: return GameCenter.getLeaderBoardIdForScoreLevels(type: type)
        case .time: return GameCenter.getLeaderBoardIdForScoreTimed(type: type)
        case .tutorial: return "" // should not happen
        }
    }
    
    static private func getLeaderBoardIdForScoreTimed(type: GameType) -> String {
        switch type {
        case .normal: return Const.GameCenter.boardClassicNormalTimed
        case .satellite: return Const.GameCenter.boardClassicSatelliteTimed
        case .shadow: return Const.GameCenter.boardClassicShadowTimed
        case .mirage: return Const.GameCenter.boardClassicMirageTimed
        case .rewire: return Const.GameCenter.boardClassicRewireTimed
        case .transit: return Const.GameCenter.boardClassicTransitTimed
        }
    }
    
    static private func getLeaderBoardIdForScoreLevels(type: GameType) -> String {
        switch type {
        case .normal: return Const.GameCenter.boardClassicNormalLevels
        case .satellite: return Const.GameCenter.boardClassicSatelliteLevels
        case .shadow: return Const.GameCenter.boardClassicShadowLevels
        case .mirage: return Const.GameCenter.boardClassicMirageLevels
        case .rewire: return Const.GameCenter.boardClassicRewireLevels
        case .transit: return Const.GameCenter.boardClassicTransitLevels
        }
    }
}
