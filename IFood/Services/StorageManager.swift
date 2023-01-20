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
    
    static func saveObjects(_ places: [Place]) {
        try! realm.write{
            realm.add(places)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write{
            realm.delete(place)
        }
    }
    
    static func firstDataRetrieving() -> Results<Place> {
        let places = StorageManager.realm.objects(Place.self)
        if !places.isEmpty {
            return places
        } else {
            Place.saveMockPlacesInRealm()
            return StorageManager.realm.objects(Place.self)
        }
    }
}
