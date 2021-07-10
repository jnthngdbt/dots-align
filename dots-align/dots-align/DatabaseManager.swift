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

    static func getBestScore(gameMode: GameMode, gameType: GameType) -> Int? {
        var results = [GameEntity]()
        
        let request:NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "(mode == %d) AND (type == %d)", gameMode.rawValue, gameType.rawValue)
        
        let sort = NSSortDescriptor(key: "score", ascending: false)
        request.sortDescriptors = [sort]
            
        do {
            let context = DatabaseManager.getContext()
            try results = context.fetch(request)
        } catch {
            print("[ERROR] Could not fetch data from database.")
        }
        
        return results.count > 0 ? Int(results[0].score) : nil
    }
    
    static func getNbGames() -> Int? {
        var count = 0
        
        do {
            let request:NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
            let context = DatabaseManager.getContext()
            try count = context.count(for: request)
        } catch {
            print("[ERROR] Could not fetch data from database.")
        }
        
        return count
    }
}
