//
//  ContactCell.swift
//  RealmContacts
//
//  Created by Sanket  Ray on 24/02/18.
//  Copyright © 2018 Sanket  Ray. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var organization: UILabel!
    
    
    func configure(with contact: Person){
        name.text = contact.firstName + " " + contact.lastName
        phoneNumber.text = contact.phoneNumber
        organization.text = contact.organization
    }
    
    func highlightText(contact: Person, searchText: String){
        
        let initialOrganizationText = contact.organization
        let organizationAttributedText = NSMutableAttributedString(string: initialOrganizationText)
        let rangeOrganization = (initialOrganizationText as NSString).range(of: searchText, options: .caseInsensitive)
        organizationAttributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: rangeOrganization)
        organization.attributedText = organizationAttributedText
        
        let initialPhoneNumber = contact.phoneNumber
        let phoneNumberAttributedText = NSMutableAttributedString(string: initialPhoneNumber)
        let rangePhoneNumber = (initialPhoneNumber as NSString).range(of: searchText, options: .caseInsensitive)
        phoneNumberAttributedText.addAttribute(.foregroundColor, value: UIColor.red, range: rangePhoneNumber)
        phoneNumber.attributedText = phoneNumberAttributedText
        
        let initialName = contact.firstName + " " + contact.lastName
        let nameAttributedText = NSMutableAttributedString(string: initialName)
        let rangeName = (initialName as NSString).range(of: searchText, options: .caseInsensitive)
        nameAttributedText.addAttribute(.foregroundColor, value: UIColor.red, range: rangeName)
        name.attributedText = nameAttributedText
    }

}
