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
}
