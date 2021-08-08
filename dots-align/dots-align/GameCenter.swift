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
    
    static func submit(_ value: Int, leaderboardID: String) {
        GKLeaderboard.submitScore(value, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            print(error.debugDescription)
        }
    }
    
    static func syncWithLocalData() {
        var leaderboardIds: [String] = []
        for id in LeaderboardId.allCases { leaderboardIds.append(id.rawValue) }
        
        GKLeaderboard.loadLeaderboards(IDs: leaderboardIds) { (leaderboards, error) -> Void in
            if (error != nil) {
                print(error!)
            }
            
            if (leaderboards != nil) {
                for board in leaderboards! {
                    syncLeaderboardWithLocalData(leaderboard: board)
                }
            }
        }
    }
    
    static private func syncLeaderboardWithLocalData(leaderboard: GKLeaderboard) {
        leaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: GKLeaderboard.TimeScope.allTime, completionHandler: { (localPlayerEntry, playersEntries, error) -> Void in
            
            // NOTE 2021-08: often getting error Error Domain=NSCocoaErrorDomain Code=4099 "The connection to service on pid 10124 named com.apple.gamed was interrupted, but the message was sent over an additional proxy and therefore this proxy has become invalid."
            // My guess is that it is related to thread / calling callbacks inside callbacks.
            // However, works when only fetching data from 1 leaderboard.
            
            if error != nil {
                print(error.debugDescription)
            } else {
                let leaderboardId = leaderboard.baseLeaderboardID
                let localScore = UserData.loadFromLocalLeaderboard(leaderboardId: leaderboardId)
                let remoteScore = localPlayerEntry?.score ?? 0
                
                if localScore > remoteScore {
                    GameCenter.submit(localScore, leaderboardID: leaderboardId)
                } else if localScore < remoteScore {
                    UserData.saveToLocalLeaderboard(value: remoteScore, leaderboardId: leaderboardId)
                }
            }
        })
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
        case .normal: return LeaderboardId.boardClassicNormalTimed.rawValue
        case .satellite: return LeaderboardId.boardClassicSatelliteTimed.rawValue
        case .shadow: return LeaderboardId.boardClassicShadowTimed.rawValue
        case .mirage: return LeaderboardId.boardClassicMirageTimed.rawValue
        case .rewire: return LeaderboardId.boardClassicRewireTimed.rawValue
        case .transit: return LeaderboardId.boardClassicTransitTimed.rawValue
        }
    }
    
    static private func getLeaderBoardIdForScoreLevels(type: GameType) -> String {
        switch type {
        case .normal: return LeaderboardId.boardClassicNormalLevels.rawValue
        case .satellite: return LeaderboardId.boardClassicSatelliteLevels.rawValue
        case .shadow: return LeaderboardId.boardClassicShadowLevels.rawValue
        case .mirage: return LeaderboardId.boardClassicMirageLevels.rawValue
        case .rewire: return LeaderboardId.boardClassicRewireLevels.rawValue
        case .transit: return LeaderboardId.boardClassicTransitLevels.rawValue
        }
    }
}
