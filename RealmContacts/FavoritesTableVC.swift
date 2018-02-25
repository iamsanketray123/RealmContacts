//
//  FavoritesTableVC.swift
//  RealmContacts
//
//  Created by Sanket  Ray on 25/02/18.
//  Copyright © 2018 Sanket  Ray. All rights reserved.
//

import UIKit
import RealmSwift

class FavoritesTableVC: UITableViewController {

    var people : Results<Person>?

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchFavoriteContacts()
    }
    
    func fetchFavoriteContacts(){
        let realm = RealmService.shared.realm
        let predicate = NSPredicate(format: "isFavorite == true")
        people =  realm.objects(Person.self).filter(predicate).sorted(byKeyPath: "firstName", ascending: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell")
        let person = people![indexPath.row]
        cell?.textLabel?.text = person.firstName + " " + person.lastName
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cell?.textLabel?.textColor = .white
        return cell!
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
