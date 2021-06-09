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
    var games = [GameEntity]()
    var context: NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    init() {
        context = appDelegate?.persistentContainer.viewContext
    }
    
    func addGameResult(game: Game) -> GameEntity {
        let bestScore = self.getBestScore(gameMode: game.mode)
        
        let nbLevels = game.nbCompletedLevels
        
        let gameEntry = GameEntity(context: self.context)
        gameEntry.score = Int32(game.score)
        gameEntry.mode = Int32(game.mode.rawValue)
        gameEntry.bestScore = Int32(bestScore ?? 0)
        gameEntry.avgBoost = nbLevels > 0 ? Float(game.sumBoost) / Float(nbLevels) : 0.0
        gameEntry.avgRotation = nbLevels > 0 ? Float(game.sumRotationRad) / Float(nbLevels) : 0.0
        gameEntry.avgNbDots = nbLevels > 0 ? Float(game.sumNbDots) / Float(nbLevels) : 0.0
        gameEntry.nbLevels = Int32(nbLevels)
            
        appDelegate?.saveContext()
        
        return gameEntry
    }

    func getBestScore(gameMode: GameMode) -> Int? {
        var results = [GameEntity]()
        
        let request:NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        
        request.predicate = NSPredicate(format: "mode == %d", gameMode.rawValue)
        
        let sort = NSSortDescriptor(key: "score", ascending: false)
        request.sortDescriptors = [sort]
            
        do {
            try results = self.context.fetch(request)
        } catch {
            print("[ERROR] Could not fetch data from database.")
        }
        
        return results.count > 0 ? Int(results[0].score) : nil
    }
}
