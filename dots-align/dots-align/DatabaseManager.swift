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
    var moc: NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
}
