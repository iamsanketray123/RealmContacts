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
    
    var notificationToken : NotificationToken?
    var selectedPerson    : Person?
    var selectedIndexPath : IndexPath?
    
    
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
        }
        
        tableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.contentInset = UIEdgeInsetsMake(12, 0, 0, 0)
    }
    
    
    fileprivate func fetchContactsFromPhone(){
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access",err)
                return
            }
            if granted {
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
            destination.indexPath = selectedIndexPath
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

extension ContactsViewController {
//    Helper method
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 25, y: self.view.center.y+50, width: (view.frame.width - 50), height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 20;
        toastLabel.clipsToBounds  =  true
        self.tableView.addSubview(toastLabel)
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}











