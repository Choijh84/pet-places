//
//  LoginViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

 /// ViewController that allows a user to login or signup using either Facebook or credentials

class LoginViewController: UIViewController, UITextFieldDelegate {

    /// Email field
    @IBOutlet weak var emailField: AccountTextField!
    /// Password field
    @IBOutlet weak var passwordField: AccountTextField!
    
    /// Login button
    @IBOutlet weak var loginButton: UIButton!
    /// Sign up button
    @IBOutlet weak var signupButton: UIButton!
    /// Facebook login button
    @IBOutlet weak var facebookLoginButton: UIButton!
    /// UIImageView that displays the company's logo
    @IBOutlet weak var companyLogoImageView: UIImageView!
    
    /// Bottom constraint from the facebook button to the bottom of the view, so when the keyboard comes up we can just slide it up easily by adjusting this constraint
    @IBOutlet weak var facebookButtonBottomConstraint: NSLayoutConstraint!
    
    /// Close button, that is only shown if the view is not presented at My Profile view, but presented modally/Full screen
    @IBOutlet weak var closeButton: UIButton!
    
    /// Default value of the facebookButtonBottomConstraint layout constraint
    var defaultFacebookButtonBottomConstraint: CGFloat!
    
    /// Whether to display the login button or not
    var displayCloseButton: Bool = false
    
    /**
     Dismiss the view when the close button is pressed
     */
    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Called after the view is loaded. Adds a shadow to the company logo and registers itself for keyboard notifications.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMotionEffectToCompanyLogo()
        
        loginButton.layer.cornerRadius = 4.0
        facebookLoginButton.layer.cornerRadius = 4.0
        signupButton.layer.cornerRadius = 4.0
        
        companyLogoImageView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.3).cgColor
        companyLogoImageView.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        companyLogoImageView.layer.shadowOpacity = 0.6
        companyLogoImageView.layer.shadowRadius = 10
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.viewWasTapped(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        
        defaultFacebookButtonBottomConstraint = facebookButtonBottomConstraint.constant
        print("this is :\(defaultFacebookButtonBottomConstraint)")
        closeButton.isHidden = !displayCloseButton

    }
    
    /**
     Called when the user taps on the view. Hides the keyboard if visible
     
     - parameter recognizer: the tapRecognizer that listened to the touch event
     */
    func viewWasTapped(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    /**
     Adds a special motion effect to the company logo, which means when you move around the iPhone on it's Y and X axis the logo will also move a bit
     around those axis. Just like the home screen.
     */
    func addMotionEffectToCompanyLogo() {
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -30
        horizontalMotionEffect.maximumRelativeValue = 30
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -20
        verticalMotionEffect.maximumRelativeValue = 20
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        companyLogoImageView.addMotionEffect(motionEffectGroup)
    }
    
    // MARK: keyboard handling
    /**
     Called before showing the keyboard. Slides up all the elements in the view so it is easy to access any buttons/fields
     
     - parameter notification: notification
     */
    func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        if let userInfo = userInfo {
            let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double
            let keyboardSize = keyboardFrame?.cgRectValue
            
            let heightOfKeyboard = keyboardSize?.height
            
            facebookButtonBottomConstraint.constant = heightOfKeyboard!
            
            UIView.animate(withDuration: animationDuration!, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    /**
     Called before the keyboard is about to be dismissed, just reset the default view layout
     
     - parameter notification: notification
     */
    func keyboardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo
        if let userInfo = userInfo
        {
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double
            facebookButtonBottomConstraint.constant = defaultFacebookButtonBottomConstraint
            
            UIView.animate(withDuration: animationDuration!, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: login methods
    /**
     Called when the user taps on Login button, checks if all the fields are edited and tries to log the user in.
     */
    @IBAction func loginUser() {
        if emailField.text == nil {
            self.showAlertViewWithErrorMessage("Email is missing")
            return
        }
        
        if passwordField.text == nil {
            self.showAlertViewWithErrorMessage("Password is missing")
            return
        }
        
        // at this point, we should have a valid email and password
        UserManager.loginUser(withEmail: emailField.text!, password: passwordField.text!) { (successful, errorMessage) -> () in
            if successful == true {
                self.dismissView()
            } else {
                self.showAlertViewWithErrorMessage(errorMessage!)
            }
        }
    }
    
    /**
     Called when the user taps on Sign up button, checks if all the fields are edited and tries to sign them up.
     */
    @IBAction func signupUser() {
        if emailField.text == nil {
            self.showAlertViewWithErrorMessage("Email is missing")
            return
        }
        
        if passwordField.text == nil {
            self.showAlertViewWithErrorMessage("Password is missing")
            return
        }
        
        UserManager.registerUser(withEmail: emailField.text!, password: passwordField.text!) { (successful, errorMessage) -> () in
            if successful == true {
                self.dismissView()
            } else {
                self.showAlertViewWithErrorMessage(errorMessage!)
            }
        }
    }
    
    /**
     Called when the user taps on Login via Facebook
     */
    @IBAction func loginUserViaFacebook() {
        UserManager.loginViaFacebook(withViewController: self) { (successful, errorMessage) -> () in
            if successful == true {
                self.dismissView()
            } else {
                self.showAlertViewWithErrorMessage(errorMessage!)
            }
        }
    }

    
    /**
     Shows an alertView with a given errorMessage
     
     - parameter errorMessage: error message string to show
     */
    func showAlertViewWithErrorMessage(_ errorMessage: String) {
        let alertView = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    /**
     Dismisses the view
     */
    func dismissView() {
        if let parentViewController = parent {
            emailField.text = ""
            passwordField.text = ""
            
            parentViewController.viewDidAppear(true)
            willMove(toParentViewController: nil)
            view.removeFromSuperview()
            didMove(toParentViewController: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: textfield delegate methods
    /**
     Called when the user taps on the Return key of the Keyboard.
     
     - parameter textField: textfield that was the first responder
     
     - returns: true if it should dismiss the keyboard
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
