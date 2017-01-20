//
//  ReviewsDetailViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView

/// Custom viewcontroller that displays a selected review
class ReviewsDetailViewController: UIViewController {

    /// Selected review to be displayed
    var reviewToDisplay: Review!
    
    /// ImageView to display the review's image
    @IBOutlet weak var reviewImageView: LoadingImageView!
    /// Star view that displays the rating value of the review
    @IBOutlet weak var ratingView: HCSStarRatingView!
    /// Label that displays the review's text
    @IBOutlet weak var reviewTextLabel: UILabel!
    /// Button to close the view
    @IBOutlet weak var closeButton: UIButton!
    /// View that contains all the ui elements
    @IBOutlet weak var containerView: UIView!
    /// Height constraint for the reviewImageView
    @IBOutlet weak var reviewImageViewHeightConstraint: NSLayoutConstraint!

    /**
     <#Description#>
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingView.value = CGFloat(reviewToDisplay.rating)
        reviewTextLabel.text = reviewToDisplay.text
        
        if let imageURL = reviewToDisplay.fileURL {
            reviewImageView.hnk_setImage(from: URL(string: imageURL))
        } else {
            hideReviewImageView()
        }
        
        addShadowsToViews()
    }

    /**
     Hides the imageView if the review doesn't have an image
     */
    func hideReviewImageView() {
        reviewImageViewHeightConstraint.constant = 0.0
        view.layoutIfNeeded()
    }

    /**
     Adds shadows to the close button and the container view
     */
    func addShadowsToViews() {
        reviewImageView.layer.cornerRadius = 4.0
        
        containerView.layer.cornerRadius = 4.0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowRadius = 2.0
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        closeButton.layer.cornerRadius = 4.0
        closeButton.layer.shadowColor = UIColor.black.cgColor
        closeButton.layer.shadowOpacity = 0.5
        closeButton.layer.shadowRadius = 2.0
        closeButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
    
    /**
     Dismiss the current view
     */
    @IBAction func closeButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     Keep the statusbar hidden for this view
     
     - returns: true to hide it
     */
    override var prefersStatusBarHidden : Bool {
        return true
    }

}
