//
//  ProfileInfoViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView

/// A viewcontroller that displays the currently logged in user's information
/// After this work, should work on the next views

class ProfileInfoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    /// profile picure of the user
    @IBOutlet weak var profilePicture: UIImageView!
    /// the nickname label for the logged in user
    @IBOutlet weak var nicknameLabel: UILabel!
    /// Label that show the email address of the user
    @IBOutlet weak var loggedInEmailLabel: UILabel!
    //// The logout Button
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    
    var isProfilePictureChanged = false
    
    /// Lazy loader for LoginViewController, cause we might not need to initialize it in the first place
    lazy var loginViewController: LoginViewController = {
        let loginViewController = StoryboardManager.loginViewController()
        return loginViewController
    }()
     
    /**
     Called when user taps on logout button, present an alertview asking for confirmation
     */
    @IBAction func logoutButtonPressed() {
        let alertView = UIAlertController(title: "Logout?", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alertView.addAction(UIAlertAction(title: "Log out", style: .default, handler: { (alertAction) -> Void in
            self.logoutUser()
        }))
        present(alertView, animated: true, completion: nil)
    }
    
    /**
     Log out the user and present the login viewcontroller
     */
    func logoutUser() {
        UserManager.logoutUser { (successful, errorMessage) -> () in
            if successful {
                self.presentLoginViewController()
            } else {
                // Present error
                self.displayAlertView(errorMessage!, title: "Error")
            }
        }
    }
    
    /**
     <#Description#>
     
     - parameter message: <#message description#>
     - parameter title:   <#title description#>
     */
    func displayAlertView(_ message: String, title: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    /**
     Here we can customise your view, I just assign the user's username to the label to show it
     */
    func customiseView() {
        
        profilePicture.layer.cornerRadius = profilePicture.layer.frame.width/2
        
        if UserManager.isUserLoggedIn() == true {
            print("User has been logged")
            
            if isProfilePictureChanged == false {
                DispatchQueue.main.async(execute: {
                    if let profile = UserManager.currentUser()?.getProperty("profileURL") {
                        let url = profile as! String
                        self.profilePicture.hnk_setImage(from: URL(string: url))
                        print("This is profileURL1: \(url)")
                    }
                })
            } else {
                print("profile picture has changed")
            }
            
            if let email = UserManager.currentUser()?.email {
                loggedInEmailLabel.text = email as String
                print("This is email: \(email)")
                
            } else {
                loggedInEmailLabel.text = UserManager.currentUser()?.name as String?
            }
            
            if let nickname = UserManager.currentUser()?.getProperty("nickname") {
                nicknameLabel.text = nickname as! String
                print("This is nickname: \(nickname)")
            } else {
                nicknameLabel.text = UserManager.currentUser()?.name as String?
            }
        } else {
            print("User hasn't been logged")
        }    
        
    }
    

    
    /**
     Checks if the loginViewController is already presented, if not, it adds it as a subview to our view
     */
    func presentLoginViewController() {
        if loginViewController.view.superview == nil {
            loginViewController.view.frame = view.frame
            loginViewController.willMove(toParentViewController: self)
            view.addSubview(loginViewController.view)
            loginViewController.didMove(toParentViewController: self)
            addChildViewController(loginViewController)
        }
    }
    
    /**
     Dismisses the login viewController if it is visible
     */
    func dismissLoginViewController() {
        if loginViewController.view.superview != nil {
            loginViewController.dismissView()
        }
    }
    
    /**
     Check if the user is logged in or not. If yes, dismiss the login view if visible. If not present it
     
     - parameter animated: If true, the view is being added to the window using an animation.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserManager.isUserLoggedIn() {
            dismissLoginViewController()
            let currentUser = UserManager.currentUser()
            print("Current User: \(currentUser!)")
        } else {
            loggedInEmailLabel.text = ""
            presentLoginViewController()
        }
    }
    
    /**
     Customises the view after it appeares
     
     - parameter animated: animated
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customiseView()
    }
    
    /**
     Use the default statusbar here (Black)
     
     - returns: the default statusbar
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Profile"
        
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(img:)))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func imageTapped(img: AnyObject) {
        print("Tapped on Image")
    }
    
    @IBAction func profilePictureChange(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.delegate = self
        /// Need to change later
        controller.sourceType = .photoLibrary
        
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        profilePicture.image = selectedImage
        isProfilePictureChanged = true
        DispatchQueue.main.async { 
            self.imageUploadAsync(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil )
    }
    
    func imageUploadAsync(image: UIImage!) {
        print("\n============ Uploading image with the ASYNC API ============")
    
        if let selectedImage = image {
            let fileName = String(format: "%0.0f.jpeg", Date().timeIntervalSince1970)
            let filePath = "profileImages/\(fileName)"
            let content = UIImageJPEGRepresentation(selectedImage, 1.0)
            
            Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
                let fileURL = uploadedFile?.fileURL
                print(fileURL!)
                self.profilePicture.hnk_setImage(from: URL(string: fileURL!))
                print("This is profileURL2: \(fileURL!)")
                
                let property = ["profileURL" : fileURL!]
                UserManager.currentUser()!.updateProperties(property)
                Backendless.sharedInstance().userService.update(UserManager.currentUser()!, response: { (updateUser) in
                    print("Updated user: \(updateUser!)")
                    self.isProfilePictureChanged = false
                }, error: { (fault) in
                    print("Server reported an error (2): \(fault!)")
                })
            }, error: { (fault) in
                print(fault.debugDescription)
            })
        } else {
            print("There is no data")
        }
    }

}
