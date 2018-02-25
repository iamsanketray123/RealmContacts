//
//  ContactsExtension.swift
//  RealmContacts
//
//  Created by Sanket  Ray on 25/02/18.
//  Copyright © 2018 Sanket  Ray. All rights reserved.
//

import UIKit

extension ContactsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let people = people else {
            return 0
        }
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactCell
        let person = people[indexPath.row]
        cell.configure(with: person)
        if let searchText = sb.text {
            cell.highlightText(contact: person, searchText: searchText)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 102
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPerson = people[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toDetailView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let person = self.people[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            self.deleteContactFromPhone(person: person)
            let realm = RealmService.shared.realm
            RealmService.shared.delete(person)
            self.people = realm.objects(Person.self).sorted(byKeyPath: "firstName", ascending: true)
            self.tableView.reloadData()
            
        }
        let favorite = UIContextualAction(style: .normal, title: "Favorite") { (contextAction: UIContextualAction, sourceView: UIView, completion: (Bool)-> Void) in
            self.tableView.reloadRows(at: [indexPath], with: .none)
            RealmService.shared.update(person)
            self.showToast(message: "Added to Favorites")
            completion(true)
        }
        
        let unfavorite = UIContextualAction(style: .normal, title: "Unfavorite") { (contextAction: UIContextualAction, sourceView: UIView, completion: (Bool)->Void) in
            self.tableView.reloadRows(at: [indexPath], with: .none)
            RealmService.shared.update(person)
            self.showToast(message: "Removed from Favorites")
            completion(true)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        delete.image = #imageLiteral(resourceName: "cross")
        
        favorite.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        favorite.image = #imageLiteral(resourceName: "favorite")
        
        unfavorite.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        unfavorite.image = #imageLiteral(resourceName: "unfavorite")
        
        if !person.isFavorite {
            let configuration =  UISwipeActionsConfiguration(actions: [delete,favorite])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        } else {
            let configuration = UISwipeActionsConfiguration(actions: [delete, unfavorite])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
        }
    }
    
}
