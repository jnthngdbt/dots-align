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
    
    static func submit(score: Int, mode: GameMode, type: GameType) {
        let leaderboardIDs = GameCenter.getLeaderBoardIds(mode: mode, type: type)
        
        if leaderboardIDs.count > 0 {
            GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: leaderboardIDs) { error in
                print(error.debugDescription)
            }
        }
    }
    
    static private func getLeaderBoardIds(mode: GameMode, type: GameType) -> [String] {
        var ids: [String] = []
        
        switch mode {
        case .level: ids = GameCenter.getLeaderBoardIdsLevels(type: type)
        case .time: ids = GameCenter.getLeaderBoardIdsTimed(type: type)
        case .tutorial: break // should not happen
        }
        
        ids.append(Const.GameCenter.boardClassisOverallBest)
        
        return ids
    }
    
    static private func getLeaderBoardIdsTimed(type: GameType) -> [String] {
        var ids: [String] = []
        
        switch type {
        case .normal:
            ids.append(Const.GameCenter.boardClassicNormalTimed)
            break
        case .satellite:
            ids.append(Const.GameCenter.boardClassicSatelliteTimed)
            break
        case .shadow:
            ids.append(Const.GameCenter.boardClassicShadowTimed)
            break
        case .mirage:
            ids.append(Const.GameCenter.boardClassicMirageTimed)
            break
        case .rewire:
            ids.append(Const.GameCenter.boardClassicRewireTimed)
            break
        case .transit:
            ids.append(Const.GameCenter.boardClassicTransitTimed)
            break
        }
        
        return ids
    }
    
    static private func getLeaderBoardIdsLevels(type: GameType) -> [String] {
        var ids: [String] = []
        
        switch type {
        case .normal:
            ids.append(Const.GameCenter.boardClassisNormalLevels)
            break
        case .satellite:
            ids.append(Const.GameCenter.boardClassisSatelliteLevels)
            break
        case .shadow:
            ids.append(Const.GameCenter.boardClassisShadowLevels)
            break
        case .mirage:
            ids.append(Const.GameCenter.boardClassisMirageLevels)
            break
        case .rewire:
            ids.append(Const.GameCenter.boardClassisRewireLevels)
            break
        case .transit:
            ids.append(Const.GameCenter.boardClassisTransitLevels)
            break
        }
        
        return ids
    }
}
