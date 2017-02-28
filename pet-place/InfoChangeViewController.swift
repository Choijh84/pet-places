//
//  InfoChangeViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

class InfoChangeViewController: UIViewController {

    var user = Backendless.sharedInstance().userService.currentUser
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var mobileTextfield: UITextField!
    
    @IBAction func passwordChange(_ sender: Any) {
        Backendless.sharedInstance().userService.restorePassword(user?.email! as String!, response: { (response) in
            SCLAlertView().showSuccess("Password Change", subTitle: "Complete")
            _ = self.navigationController?.popViewController(animated: true)
        }) { (Fault) in
            SCLAlertView().showError("Reported an error", subTitle: (Fault?.description)!)
            
        }    }
    
    @IBAction func nameChange(_ sender: Any) {
        let name = nameTextfield.text
        user?.setProperty("name", object: name)
        _ = Backendless.sharedInstance().userService.update(user)
        SCLAlertView().showSuccess("Name Change", subTitle: "Complete")
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nicknameChange(_ sender: Any) {
        let nickname = nicknameTextField.text
        user?.setProperty("nickname", object: nickname)
        _ = Backendless.sharedInstance().userService.update(user)
        SCLAlertView().showSuccess("Nickname Change", subTitle: "Complete")
    }
    
    @IBAction func phoneChange(_ sender: Any) {
        let phoneNumber = mobileTextfield.text
        print("this is phoneNumber: \(phoneNumber)")
        user?.setProperty("phoneNumber", object: phoneNumber)
        _ = Backendless.sharedInstance().userService.update(user)
        SCLAlertView().showSuccess("Phone Change", subTitle: "Complete")
        
    }

    @IBAction func deleteUser(_ sender: Any) {
        /// How to delete User? Just change the ACL first?
        let dataStore = Backendless.sharedInstance().data.of(Users.ofClass())
        _ = dataStore?.remove(user)
        SCLAlertView().showSuccess("User deleted", subTitle: "Complete")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchUserInfo()
        setupInitialView()
        
        // print(user?.retrieveProperties())
    }
    
    func setupInitialView() {
        emailLabel.text = user?.email as String?
    }
    
    func fetchUserInfo() {
        if (user != nil) {
            if let name = user?.getProperty("name") {
                nameTextfield.text = name as? String
            }
            if let nickname = user?.getProperty("nickname") {
                nicknameTextField.text = nickname as? String
            }
            if let phoneNumber = user?.getProperty("phoneNumber") {
                print("this is phoneNumber: \(phoneNumber)")
                mobileTextfield.text = phoneNumber as? String
            }
        } else {
            print("user has not logged in")
        }
    }
    
    func describeUserAsync() {
        
        Backendless.sharedInstance().userService.describeUserClass({ (property) in
            print("This is user property: \(property)")
        }) { (Fault) in
            print("This is fault: \(Fault?.description)")
        }

    }
}


class Users: NSObject {
    
    var objectId: String!
    var email: String!
    var name: String?
    var nickname: String?
    var password: String!
    var petProfiles: [PetProfile]?
    var phoneNumber: String?
    var profileURL: String?
    var socialAccount: String?
    
}

