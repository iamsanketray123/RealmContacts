//
//  RealmService.swift
//  RealmContacts
//
//  Created by Sanket  Ray on 24/02/18.
//  Copyright © 2018 Sanket  Ray. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    
    private init() {}
    static let shared = RealmService()
    
    var realm = try! Realm()
    
    func save<T: Object>(_ person: T) {

        DispatchQueue.main.async {
            try! self.realm.write{
                self.realm.add(person)
            }
        }
    }
    
    func update<T: Object>(_ person: T) {
        do {
            try realm.write {
                (person as! Person).isFavorite = !(person as! Person).isFavorite
                print("Changed favorite property")
            }
        }catch {
            print(error)
        }
    }
    
    func delete<T: Object>(_ person: T) {
        do {
            try realm.write{
                realm.delete(person)
            }
        }catch{
            print(error)
        }
    }
    
}
