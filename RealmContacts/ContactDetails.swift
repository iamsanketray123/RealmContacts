//
//  ContactDetails.swift
//  RealmContacts
//
//  Created by Sanket  Ray on 24/02/18.
//  Copyright © 2018 Sanket  Ray. All rights reserved.
//

import UIKit

class ContactDetails: UIViewController {

    var person : Person!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var organization: UILabel!
    
    var indexPath : IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateUI()
    }
    
    
    fileprivate func updateUI(){
        
        setupImage()
        
        image.layer.cornerRadius = 128 / 2
        name.text = person.firstName + " " + person.lastName
        name.adjustsFontSizeToFitWidth         = true
        name.adjustsFontForContentSizeCategory = true
        organization.adjustsFontSizeToFitWidth = true
        organization.adjustsFontForContentSizeCategory = true
        phone.text = person.phoneNumber
        organization.text = person.organization == "" ? "None" : person.organization
    }
    
    fileprivate func setupImage(){
        
        let selectedRow = indexPath.row
        let totalNumberOfImages = 15
        let imageNumber = selectedRow % totalNumberOfImages
        image.image = UIImage(named: "\(imageNumber)")
        
    }
    

}
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
