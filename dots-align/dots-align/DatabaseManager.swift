//
//  Database.swift
//  dots-align
//
//  Created by Jonathan Godbout on 2021-06-04.
//

import Foundation
import SpriteKit
import CoreData

class DatabaseManager {
    private static func getAppDelegate() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private static func getContext() -> NSManagedObjectContext {
        return (DatabaseManager.getAppDelegate()?.persistentContainer.viewContext)!
    }
    
    static func addGameResult(game: Game) -> GameEntity {
        let bestScore = DatabaseManager.getBestScore(gameMode: game.mode, gameType: game.type)
        
        let nbLevels = game.nbCompletedLevels
        
        let gameEntry = GameEntity(context: DatabaseManager.getContext())
        gameEntry.date = Date()
        gameEntry.score = Int32(game.score)
        gameEntry.mode = Int32(game.mode.rawValue)
        gameEntry.type = Int32(game.type.rawValue)
        gameEntry.bestScore = Int32(bestScore ?? 0)
        gameEntry.avgBoost = nbLevels > 0 ? Float(game.sumBoost) / Float(nbLevels) : 0.0
        gameEntry.avgRotation = nbLevels > 0 ? Float(game.sumRotationRad) / Float(nbLevels) : 0.0
        gameEntry.avgNbDots = nbLevels > 0 ? Float(game.sumNbDots) / Float(nbLevels) : 0.0
        gameEntry.nbLevels = Int32(nbLevels)
            
        DatabaseManager.getAppDelegate()?.saveContext()
        
        return gameEntry
    }
    
    static private func getGameRequest() -> NSFetchRequest<GameEntity> {
        let request: NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        return request
    }

    static private func getGameRequest(gameMode: GameMode, gameType: GameType) -> NSFetchRequest<GameEntity> {
        let request: NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        request.predicate = NSPredicate(format: "(mode == %d) AND (type == %d)", gameMode.rawValue, gameType.rawValue)
        return request
    }
    
    static func getLastGame() -> GameEntity? {
        var result = [GameEntity]()
        
        let request: NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
        
        do {
            let context = DatabaseManager.getContext()
            try result = context.fetch(request)
        } catch {
            print("[ERROR] Could not fetch data from database.")
        }
        
        return result.count > 0 ? result[0] : nil
    }
    
    static func getBestScore(gameMode: GameMode, gameType: GameType) -> Int? {
        var result = [GameEntity]()
        
        let request = getGameRequest(gameMode: gameMode, gameType: gameType)
        let sort = NSSortDescriptor(key: "score", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchLimit = 1
            
        do {
            let context = DatabaseManager.getContext()
            try result = context.fetch(request)
        } catch {
            print("[ERROR] Could not fetch data from database.")
        }
        
        return result.count > 0 ? Int(result[0].score) : nil
    }
    
    static func getAverageScore(gameMode: GameMode, gameType: GameType) -> Int? {
            
        var results = [GameEntity]()
        
        do {
            let request = getGameRequest(gameMode: gameMode, gameType: gameType)
            let context = DatabaseManager.getContext()
            try results = context.fetch(request)
        } catch {
            print("[ERROR] Could not fetch data from database.")
        }
        
        var sum = 0
        var count = 0
        
        for game in results {
            sum += Int(game.score)
            count += 1
        }
        
        return count > 0 ? Int(sum / count) : nil
    }
    
    static func getGameCount(gameMode: GameMode, gameType: GameType) -> Int? {
        var count = 0
        
        do {
            let request = getGameRequest(gameMode: gameMode, gameType: gameType)
            let context = DatabaseManager.getContext()
            try count = context.count(for: request)
        } catch {
            print("[ERROR] Could not fetch data from database.")
        }
        
        return count
    }
    
    static func getGameCount() -> Int? {
        var count = 0
        
        do {
            let request = getGameRequest()
            let context = DatabaseManager.getContext()
            try count = context.count(for: request)
        } catch {
            print("[ERROR] Could not fetch data from database.")
        }
        
        return count
    }
}
