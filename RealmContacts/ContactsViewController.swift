//
//  ContactsViewController.swift
//  RealmContacts
//
//  Created by Sanket  Ray on 23/02/18.
//  Copyright © 2018 Sanket  Ray. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift
import SVProgressHUD

class ContactsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sb: UISearchBar!
    
    var people : Results<Person>!
    
    var notificationToken: NotificationToken?
    var selectedPerson : Person?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = RealmService.shared.realm
        people = realm.objects(Person.self).sorted(byKeyPath: "firstName", ascending: true)

        notificationToken = realm.observe { (notification, realm) in
            self.tableView.reloadData()
        }
        
        if people.count == 0 {
            fetchContactsFromPhone()
        }else {
            print(people.count)
            people = realm.objects(Person.self).sorted(byKeyPath: "firstName", ascending: true)
            tableView.reloadData()
            print("We already have contacts to display")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        notificationToken?.invalidate()
    }
    
    
    fileprivate func fetchContactsFromPhone(){
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access",err)
                return
            }
            if granted {
                print("Access granted")
                DispatchQueue.main.async{
                    SVProgressHUD.show(withStatus: "Loading...")
                    SVProgressHUD.setDefaultMaskType(.gradient)
                }
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactOrganizationNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? "No phone number"
                        let person = Person(firstName: contact.givenName, lastName: contact.familyName, phoneNumber: String(describing: phoneNumber), organization: contact.organizationName)
                        
//                                    Save contact to Realm!
                        RealmService.shared.save(person)
                    })
                    DispatchQueue.main.async{
                        SVProgressHUD.dismiss()
                    }
                }
                catch let err{
                    print("Failed to enumerate contacts", err)
                }
            }
            else {
                print("Access denied")
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailView" {
            let destination = segue.destination as! ContactDetails
            destination.person = selectedPerson
        }
    }
    func deleteContactFromPhone(person: Person){
        let store = CNContactStore()
        let predicate = CNContact.predicateForContacts(matchingName: "\(person.firstName) \(person.lastName)")
        let toFetch = [CNContactEmailAddressesKey]
        
        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: toFetch as [CNKeyDescriptor])
            guard contacts.count > 0 else {
                print("No Contacts Found")
                return
            }
            guard let contact = contacts.first else {
                return
            }
            let req = CNSaveRequest()
            let mutableContact = contact.mutableCopy() as! CNMutableContact
            req.delete(mutableContact)
            do {
                try store.execute(req)
                print("You sucessfully deleted the user")
            } catch {
                print("Error", error)
            }
        }catch {
            print("Something went wrong",error)
        }
        
    }

}

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
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            let person = self.people[indexPath.row]
            self.deleteContactFromPhone(person: person)
            let realm = RealmService.shared.realm
            RealmService.shared.delete(person)
            self.people = realm.objects(Person.self).sorted(byKeyPath: "firstName", ascending: true)
            self.tableView.reloadData()
            
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        delete.image = #imageLiteral(resourceName: "cross")
        let configuration =  UISwipeActionsConfiguration(actions: [delete])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    
}

extension ContactsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            people = nil
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let realm = try! Realm()
                
                let firstNamePredicate = NSPredicate(format: "firstName CONTAINS[c] %@",searchText)
                let lastNamePredicate = NSPredicate(format: "lastName CONTAINS[c] %@",searchText)
                let phonePredicate = NSPredicate(format: "phoneNumber CONTAINS[c] %@",searchText)
                let organizationPredicate = NSPredicate(format:"organization CONTAINS[c] %@",searchText)
                
                let orCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [firstNamePredicate,lastNamePredicate,phonePredicate,organizationPredicate])
                
                self.people = realm.objects(Person.self).filter(orCompoundPredicate).sorted(byKeyPath: "firstName", ascending: true)
                self.tableView.reloadData()
            }
        } else {
            let realm = RealmService.shared.realm
            people = realm.objects(Person.self).sorted(byKeyPath: "firstName", ascending: true)
            tableView.reloadData()
        }
    }
}












