//
//  AddReviewViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView

 /// ViewController that allows a user to leave a review for a selected Store
class AddReviewViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    /// Custom rating view for handling ratings
    @IBOutlet weak var ratingView: HCSStarRatingView!
    /// TextView for the review's body
    @IBOutlet weak var reviewField: UITextView!
    /// ImageView to display the selected image
    @IBOutlet weak var reviewImageView: UIImageView!
    /// Height constraint of the reviewImageView
    @IBOutlet weak var reviewImageViewHeightConstraint: NSLayoutConstraint!
    /// Button to select an image
    @IBOutlet weak var selectButton: UIButton!
    
    /// Manager object that handles uploading/creatig a new Review
    let reviewManager = ReviewManager()
    /// selected StoreObject to leave the review for
    var selectedStore: Store!
    /// Object that helps selecting an image
    let imagePicker = UIImagePickerController()
    
    /// Overlay view to be shown while creating a new review
    lazy var overlayView: OverlayView = {
        let overlayView = OverlayView()
        return overlayView
    }()
    
    /**
     Creates a new review when the user pressed the send button
     */
    func sendButtonPressed() {
        reviewField.resignFirstResponder()
        
        overlayView.displayView(view, text: "Sending Review...")
        
        reviewManager.uploadNewReview(reviewField.text, selectedFile: reviewImageView.image, rating: (ratingView.value) as NSNumber, store: selectedStore) { (completed, store, errorMessage) in
            self.overlayView.hideView()
            
            if completed == true {
                // if it completed, it will pop this viewController and refresh the reviews
                self.performSegue(withIdentifier: "unwindToReviews", sender: nil)
            } else {
                let alertView = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: image picker
    /**
     Called when the Select an image button pressed, opens an actionsheet and offers various ways (if available) to select an image
     */
    @IBAction func addImageButtonPressed() {
        reviewField.resignFirstResponder()
        
        let actionsheet = UIAlertController(title: "Choose source", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionsheet.addAction(UIAlertAction(title: "Take a picture", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.imagePicker.sourceType = .camera
                self.presentImagePicker()
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionsheet.addAction(UIAlertAction(title: "Choose photo", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                self.imagePicker.sourceType = .photoLibrary
                self.presentImagePicker()
            }))
        }
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionsheet, animated: true, completion: nil)
    }
    
    /**
     Presents the image picker object
     */
    func presentImagePicker() {
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    /**
     Tells the delegate that the user picked a still image or movie.
     
     - parameter picker: The controller object managing the image picker interface.
     - parameter info:   A dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked. The dictionary also contains any relevant editing information. The keys for this dictionary are listed in Editing Information Keys.
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            reviewImageView.image = pickedImage
        }
        
        dismiss(animated: true) { () -> Void in
            self.reviewImageViewHeightConstraint.constant = 100.0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: view methods
    /**
     Some view setup after the view is loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Review"
        
        // show a send button on the navigation bar
        let sendBarButton = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(AddReviewViewController.sendButtonPressed))
        sendBarButton.tintColor = UIColor.rgbColor(red: 235.0, green: 198.0, blue: 16.0)
        navigationItem.rightBarButtonItem = sendBarButton
        
        reviewField.text = ""
        reviewField.layer.borderColor = UIColor.rgbColor(red: 179, green: 179, blue: 179).withAlphaComponent(0.2).cgColor
        reviewField.layer.borderWidth = 1.0
        reviewField.layer.cornerRadius = 4.0
        reviewField.becomeFirstResponder()
        
        reviewImageView.layer.cornerRadius = 4.0
        selectButton.layer.cornerRadius = 4.0
        
        reviewImageViewHeightConstraint.constant = 0.0
        view.layoutIfNeeded()
        
        // Add tap recongizer to the view, so keyboard can be closed easily
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddReviewViewController.viewTapped))
        tapRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapRecognizer)
    }

    /**
     Dismisses the keyboard if the view is tapped
     */
    func viewTapped() {
        reviewField.resignFirstResponder()
    }
    
    /**
     Set the navigation bar visible
     
     - parameter animated: animated
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /**
     Show the white statusbar
     
     - returns: white statusbar
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
}
