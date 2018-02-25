//
//  Person.swift
//  RealmContacts
//
//  Created by Sanket  Ray on 23/02/18.
//  Copyright © 2018 Sanket  Ray. All rights reserved.
//

import Foundation
import RealmSwift


@objcMembers class Person: Object{
    dynamic var firstName     :String = ""
    dynamic var lastName      :String = ""
    dynamic var phoneNumber   :String = ""
    dynamic var organization  :String = ""
    dynamic var isFavorite    :Bool   = false
    
    convenience init(firstName: String, lastName: String, phoneNumber: String, organization: String){
        self.init()
        self.firstName    = firstName
        self.lastName     = lastName
        self.phoneNumber  = phoneNumber
        self.organization = organization
    }
    
}
