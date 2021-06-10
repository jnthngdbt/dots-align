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
        let bestScore = DatabaseManager.getBestScore(gameMode: game.mode)
        
        let nbLevels = game.nbCompletedLevels
        
        let gameEntry = GameEntity(context: DatabaseManager.getContext())
        gameEntry.score = Int32(game.score)
        gameEntry.mode = Int32(game.mode.rawValue)
        gameEntry.bestScore = Int32(bestScore ?? 0)
        gameEntry.avgBoost = nbLevels > 0 ? Float(game.sumBoost) / Float(nbLevels) : 0.0
        gameEntry.avgRotation = nbLevels > 0 ? Float(game.sumRotationRad) / Float(nbLevels) : 0.0
        gameEntry.avgNbDots = nbLevels > 0 ? Float(game.sumNbDots) / Float(nbLevels) : 0.0
        gameEntry.nbLevels = Int32(nbLevels)
            
        DatabaseManager.getAppDelegate()?.saveContext()
        
        return gameEntry
    }

    static func getBestScore(gameMode: GameMode) -> Int? {
        var results = [GameEntity]()
        
        let request:NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "mode == %d", gameMode.rawValue)
        
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
}
