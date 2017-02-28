//
//  PlaceRegisterViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 5..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation

class PlaceRegisterViewController: UIViewController, UITextFieldDelegate {
    
    let textFieldContentsKey = "textFieldContents"
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var locationTextField: UITextField!
    
    @IBOutlet weak var reasonTextView: UITextView!

    
    override func viewDidLoad() {
        nameTextField.layer.cornerRadius = 5.0
        locationTextField.layer.cornerRadius = 5.0
    }
    
    /** 
      Define the action when user tap the submit button
     */
    
    @IBAction func submitOnTap(_ sender: Any) {
        print("name: \(nameTextField.text), location: \(locationTextField.text)")
        
        if nameTextField.text?.isEmpty == true || locationTextField.text?.isEmpty == true || nameTextField.text == "매장명을 입력해주세요" || locationTextField.text == "위치나 주소를 입력해주세요" {
            let alertView = UIAlertController(title: "입력 필요", message: "입력 확인부탁드립니다", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertView, animated: true, completion: nil)
        } else {
            let alertView = UIAlertController(title: "제출 완료", message: "제출되었습니다", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.sendEmail()
            self.present(alertView, animated: true, completion: { 
                self.nameTextField.text = ""
                self.locationTextField.text = ""
                self.reasonTextView.text = ""
            })
        }
    }
    
    /**
     Send email to designated person 
     - param:
     */
    
    func sendEmail() {
        let userEmail = Backendless.sharedInstance().userService.currentUser.email
        let name = nameTextField.text
        let reason = reasonTextView.text
        
        let subject = "Recommendation from User"
        let body = "This is an email sent by \(userEmail!).\n User recommends this place: \(name!) and the reason is like this - \(reason!)"
        let recipient = "ourpro.choi@gmail.com"
        Backendless.sharedInstance().messagingService.sendHTMLEmail(subject, body: body, to: [recipient], response: { (response) in
            print("Email has sent")
        }) { (Fault) in
            print("Server reported an error: \(Fault?.description)")
        }
    }
    
}
