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

    
    /// Buttons for the next View
    @IBOutlet weak var favoriteListButton: UIButton!
    @IBOutlet weak var petProfileButton: UIButton!
    @IBOutlet weak var myInfoButton: UIButton!
    @IBOutlet weak var inquiryButton: UIButton!
    @IBOutlet weak var recommendButton: UIButton!
    @IBOutlet weak var myReviewButton: UIButton!
    
    /**
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var envSettingButton: UIButton!
    
    var announcementButtonCenter: CGPoint!
    var eventButtonCenter: CGPoint!
    var envSettingButtonCenter: CGPoint!
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "more-black"), offImage: #imageLiteral(resourceName: "more"))
    }
    
    @IBAction func eventButtonPressed(_ sender: UIButton) {
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "more-black"), offImage: #imageLiteral(resourceName: "more"))
    }
    
    @IBAction func envButtonPressed(_ sender: UIButton) {
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "more-black"), offImage: #imageLiteral(resourceName: "more"))
    }
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        if moreButton.currentImage == #imageLiteral(resourceName: "more") {
            UIView.animate(withDuration: 0.3, animations: { 
                self.announcementButton.alpha = 1
                self.eventButton.alpha = 1
                self.envSettingButton.alpha = 1
                
                self.announcementButton.center = self.announcementButtonCenter
                self.eventButton.center = self.eventButtonCenter
                self.envSettingButton.center = self.envSettingButtonCenter
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.announcementButton.alpha = 0
                self.eventButton.alpha = 0
                self.envSettingButton.alpha = 0
                
                self.announcementButton.center = self.moreButton.center
                self.eventButton.center = self.moreButton.center
                self.envSettingButton.center = self.moreButton.center
            })
        }
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "more-black"), offImage: #imageLiteral(resourceName: "more"))
    }
    
    func toggleButton(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == offImage {
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }
     */
    
    var isProfilePictureChanged = false
    
    /// Lazy loader for LoginViewController, cause we might not need to initialize it in the first place
    lazy var loginViewController: LoginViewController = {
        let loginViewController = StoryboardManager.loginViewController()
        return loginViewController
    }()
    
    /// Pet Profile Show, Done
    @IBAction func petProfileButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showPetProfile", sender: nil)
    }
    
    /// Favorite List Show, Done
    @IBAction func favoriteListButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showFavoriteList", sender: nil)
    }
    
    @IBAction func myReviewButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showMyReview", sender: nil)
    }
    
    /// Place Recommendation Show, Done
    @IBAction func recommendButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showPlaceRegister", sender: nil)
    }
    
    @IBAction func inquiryButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showInquiry", sender: nil)
    }
    
    @IBAction func myInfoButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showMyInfo", sender: nil)
    }
    
    /// Currently no use - bcs only use the current user information
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPetProfile" {
            print("This is Pet Profile Page")
        } else if segue.identifier == "showPlaceRegister" {
            print("This is place register page")
        }
    }
    
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
     Display alert
     
     - parameter message: message to user
     - parameter title:   alert title
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
                        if let url = profile as? String {
                            if url == "<null>" {
                                print("there is no profile pic")
                            } else {
                                self.profilePicture.hnk_setImage(from: URL(string: url))
                                print("This is profileURL1: \(url)")
                            }
                        }
                        
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
                if nickname == nil {
                    nicknameLabel.text = "no nickname"
                } else {
                    nicknameLabel.text = nickname as? String
                    print("This is nickname: \(nickname)")
                }
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
            loginViewController.view.frame = self.view.bounds
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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Profile"
        
        // Do any additional setup after loading the view.
        /**
        announcementButtonCenter = announcementButton.center
        eventButtonCenter = eventButton.center
        envSettingButtonCenter = envSettingButton.center
        
        announcementButton.center = moreButton.center
        eventButton.center = moreButton.center
        envSettingButton.center = moreButton.center
        */
        
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

    /// When the pencil, the button to change the profile picture clicked
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
        
        /// First, change the view
        profilePicture.image = selectedImage
        isProfilePictureChanged = true
        /// Start the image upload
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
                
                let user = Backendless.sharedInstance().userService.currentUser
                _ = user?.setProperty("profileURL", object: fileURL)
                Backendless.sharedInstance().userService.update(user, response: { (updateUser) in
                    print("Change the profile Image")
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
