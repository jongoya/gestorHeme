//
//  UserDefaults.swift
//  GestorHeme
//
//  Created by jon mikel on 04/05/2020.
//  Copyright © 2020 jon mikel. All rights reserved.
//

import UIKit

class UserPreferences: NSObject {

    static func saveValueInUserDefaults(value: Any, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static func checkValueInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.value(forKey: key) != nil
    }
    
    static func getValueFromUserDefaults(key: String) -> Any {
        return UserDefaults.standard.value(forKey: key)!
    }
}
