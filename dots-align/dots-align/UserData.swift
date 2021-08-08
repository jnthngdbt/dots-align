//
//  UserData.swift
//  dots-align
//
//  Created by Jonathan on 2021-08-04.
//

import Foundation

class UserData {
    static func lastGameTypeSelected() -> GameType {
        let raw = UserDefaults.standard.integer(forKey: Const.UserDataKeys.lastGameTypeSelected) // returns 0 if not set yet
        return GameType(rawValue: raw) ?? .normal
    }
    
    static func lastGameTypeSelected(type: GameType) {
        UserDefaults.standard.set(type.rawValue, forKey: Const.UserDataKeys.lastGameTypeSelected)
    }
    
    static func isSoundMuted() -> Bool{
        return UserDefaults.standard.bool(forKey: Const.UserDataKeys.isSoundMuted) // returns false if not set yet
    }
    
    static func isSoundMuted(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: Const.UserDataKeys.isSoundMuted)
    }
    
    static func getBestScore(mode: GameMode, type: GameType) -> Int {
        return loadFromLocalLeaderboard(leaderboardId: GameCenter.getLeaderBoardIdForScore(mode: mode, type: type))
    }
    
    static func setBestScoreIfNecessary(score: Int, mode: GameMode, type: GameType) {
        let key = GameCenter.getLeaderBoardIdForScore(mode: mode, type: type)
        GameCenter.submit(score, leaderboardID: key)
        
        if score > getBestScore(mode: mode, type: type) {
            saveToLocalLeaderboard(value: score, leaderboardId: key)
        }
    }
    
    static func getBestScoreOverall() -> Int {
        return loadFromLocalLeaderboard(leaderboardId: LeaderboardId.boardClassicOverallBest.rawValue)
    }
    
    static func setBestScoreOverallIfNecessary(score: Int) {
        let key = LeaderboardId.boardClassicOverallBest.rawValue
        GameCenter.submit(score, leaderboardID: key)
        
        if score > getBestScoreOverall() {
            saveToLocalLeaderboard(value: score, leaderboardId: key)
        }
    }
    
    static func getGameCountOverall() -> Int {
        return loadFromLocalLeaderboard(leaderboardId: LeaderboardId.boardClassicOverallCount.rawValue)
    }
    
    static func incrementGameCountOverall() {
        let newCount = getGameCountOverall() + 1
        let key = LeaderboardId.boardClassicOverallCount.rawValue
        GameCenter.submit(newCount, leaderboardID: key)
        saveToLocalLeaderboard(value: newCount, leaderboardId: key)
    }
    
    static func getLastScore(mode: GameMode, type: GameType) -> Int {
        return loadFromLocalLeaderboard(leaderboardId: getLastScoreKey(mode: mode, type: type))
    }
    
    static func setLastScore(score: Int, mode: GameMode, type: GameType) {
        saveToLocalLeaderboard(value: score, leaderboardId: getLastScoreKey(mode: mode, type: type))
    }
    
    static private func getLastScoreKey(mode: GameMode, type: GameType) -> String {
        return GameCenter.getLeaderBoardIdForScore(mode: mode, type: type) + ".last"
    }
    
    static func addGameResult(game: Game) {
        game.score = 2244
        setBestScoreIfNecessary(score: game.score, mode: game.mode, type: game.type)
        setBestScoreOverallIfNecessary(score: game.score)
        setLastScore(score: game.score, mode: game.mode, type: game.type)
        incrementGameCountOverall()
    }
    
    static func saveToLocalLeaderboard(value: Int, leaderboardId: String) {
        UserDefaults.standard.set(value, forKey: leaderboardId)
    }
    
    static func loadFromLocalLeaderboard(leaderboardId: String) -> Int {
        return UserDefaults.standard.integer(forKey: leaderboardId)
    }
}
