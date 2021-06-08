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
    
    func addGameResult(game: Game) {
        let gameEntry = GameEntity(context: self.context)
      
        gameEntry.score = Int32(game.score)
            
        appDelegate?.saveContext()
    }

    func getBestScore() -> Int? {
        var results = [GameEntity]()
        
        let request:NSFetchRequest<GameEntity> = GameEntity.fetchRequest()
        
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
