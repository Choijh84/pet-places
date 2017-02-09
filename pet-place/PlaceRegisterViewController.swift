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
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        // load text from NSUserDefaults
//        let defaults = UserDefaults.standard
//        if let textFieldContents = defaults.string(forKey: textFieldContentsKey) {
//            nameTextField.text = textFieldContents
//            locationTextField.text = textFieldContents
//        } else {
//            // focus on the text field if it's empty
//            nameTextField.becomeFirstResponder()
//            locationTextField.becomeFirstResponder()
//        }
//    }
//    
//    func saveText() {
//        let defaults = UserDefaults.standard
//        defaults.setValue(nameTextField.text, forKey: textFieldContentsKey)
//        defaults.setValue(locationTextField.text, forKey: textFieldContentsKey)
//    }
    
    /** 
      버튼 액션을 정의, 우선 AlertView를 작업하고 향후 이메일 보내는 것과 연동
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
            self.present(alertView, animated: true, completion: { 
                self.nameTextField.text = ""
                self.locationTextField.text = ""
                self.reasonTextView.text = ""
            })
        }
    }
    
}
