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
    
    func delete<T: Object>(_ person: T) {
        do {
            try realm.write{
                realm.delete(person)
            }
        }catch{
            post(error)
        }
    }
    func post(_ error : Error) {
        NotificationCenter.default.post(name: Notification.Name("RealmError"), object: error)
    }
    func observeRealmErrors(in vc: UIViewController, completion: @escaping (Error?)-> Void) {
        NotificationCenter.default.addObserver(forName: Notification.Name("RealmError"), object: nil, queue: nil) { (notification) in
            completion(notification.object as? Error)
        }
    }
    func stopObservingErrors(in vc: UIViewController){
        NotificationCenter.default.removeObserver(vc, name: Notification.Name("RealmError"), object: nil)
    }
    
    
}
