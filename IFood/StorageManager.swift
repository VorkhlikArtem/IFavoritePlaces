//
//  StorageManager.swift
//  IFood
//
//  Created by Артём on 29.12.2022.
//

import RealmSwift

class StorageManager {
    
    static let realm = try! Realm()
    
    static func saveObject(_ place: Place) {
        try! realm.write{
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write{
            realm.delete(place)
        }
    }
}
