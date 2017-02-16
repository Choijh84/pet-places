//
//  ReviewsDetailViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SKPhotoBrowser

/// Custom viewcontroller that displays a selected review
class ReviewsDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    /// Selected review to be displayed
    var reviewToDisplay: Review!
    
    /// creator Profile Image View
    @IBOutlet weak var creatorProfileImageView: LoadingImageView!
    /// crator name
    @IBOutlet weak var creatorName: UILabel!
    /// creator timeline Label
    @IBOutlet weak var timeLineLabel: UILabel!
    
    
    /// Star view that displays the rating value of the review
    @IBOutlet weak var ratingView: HCSStarRatingView!
    /// Label that displays the review's text
    @IBOutlet weak var reviewTextLabel: UILabel!
    /// Button to close the view
    @IBOutlet weak var closeButton: UIButton!
    /// View that contains all the ui elements
    @IBOutlet weak var containerView: UIView!
    /// Collectionview for photo view
    @IBOutlet weak var photoView: UICollectionView!
    /// Contraint on collectionview Height
    @IBOutlet weak var reviewCollectionHeight: NSLayoutConstraint!
    
    /// Datasource array for photo URLs
    var imageURL : [String] = [""]
    
    /// UIImage array 
    var imageArray = [UIImage]()
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    /**
     
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingView.value = CGFloat(reviewToDisplay.rating)
        reviewTextLabel.text = reviewToDisplay.text
        
        if let imageArray = reviewToDisplay.fileURL {
            imageURL = imageArray.components(separatedBy: ",")
            if imageURL.count == 0 {
                hideReviewImageView()
            }
        }
        creatorProfileImageView.layer.cornerRadius = (creatorProfileImageView.layer.frame.width/2)
        creatorProfileImageView.clipsToBounds = true
        creatorProfileImageView.contentMode = .scaleAspectFit
        
        configureProfile()
        addShadowsToViews()
    }
    
    func configureProfile() {
        let user = reviewToDisplay.creator
        if let user = user {
            let nickname = user.getProperty("nickname") as! String
            creatorName.text = nickname
            
            let profileURL = user.getProperty("profileURL") as! String
            DispatchQueue.main.async(execute: { 
                self.creatorProfileImageView.hnk_setImage(fromFile: profileURL)
            })
        }
        timeLineLabel.text = dateFormatter.string(from: reviewToDisplay.created as Date)
    }

    /**
     Hides the collectionView if the review doesn't have an image
     */
    func hideReviewImageView() {
        reviewCollectionHeight.constant = 0.0
        view.layoutIfNeeded()
    }

    /**
     Adds shadows to the close button and the container view
     */
    func addShadowsToViews() {
        
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
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellImage", for: indexPath) as! ReviewDetailPhotosCVC
        
        print("This is IMAGEURL: \(imageURL[indexPath.row])")
        let url = URL(string: imageURL[indexPath.row])
        cell.reviewPhotos.hnk_setImage(from: url, placeholder: nil, success: { (image) in
            self.imageArray.append(image!)
            cell.reviewPhotos.image = image
        }) { (error) in
            print("There is an error to fetch the image in review")
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        if cell?.isSelected == true {
            var images = [SKPhoto]()
            for image in imageArray {
                let photo = SKPhoto.photoWithImage(image)
                images.append(photo)
            }
            
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(indexPath.row)
            present(browser, animated: true, completion: nil)
        }
    }

}
