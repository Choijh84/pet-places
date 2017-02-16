//
//  ReviewsViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class ReviewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// Button to leave a review
    @IBOutlet weak var reviewButton: UIButton!
    /// TableView that displays all the reviews
    @IBOutlet weak var tableView: LoadingTableView!
    
    /// Manager that handles downloading reviews
    let reviewDownloadManager = ReviewManager()
    /// The selected store object, which reviews should be displayed
    var selectedStoreObject: Store!
    /// Array of reviews to be displayed
    var reviewsArray: [Review] = []
    /// Refresh control
    var refreshControl: UIRefreshControl!
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    let reviewPresentManager : ReviewPresentManager = ReviewPresentManager()
    
    /**
     Called after you successfully left a review for the selected Store, from AddReviewViewController. Will reload all the reviews
     
     - parameter unwindSegue: segue
     */
    @IBAction func unwindFromAddNewReviewController(_ unwindSegue: UIStoryboardSegue) {
        loadReviews()
    }

    /**
     Called after the view is loaded. Sets up the tableView, and downloads the reviews.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reviews"
        
        reviewButton.layer.cornerRadius = 6.0
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .globalTintColor()
        refreshControl.addTarget(self, action: #selector(ReviewsViewController.loadReviews), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        DispatchQueue.main.async { 
            self.loadReviews()
        }
        
    }
    
    /**
     Set the navigation bar visible
     
     - parameter animated: animated
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // If user is not logged in, change the button to Login, to make sure user is logged in before leaving a review
        if UserManager.isUserLoggedIn() {
            reviewButton.setTitle("Leave a review", for: UIControlState())
        } else {
            reviewButton.setTitle("Login", for: UIControlState())
        }
    }
    
    /**
     Load the reviews for the selected Store
     */
    func loadReviews() {
        tableView.showLoadingIndicator()
        refreshControl.beginRefreshing()
        
        reviewDownloadManager.downloadReviewCountsAndReviewsForStore(selectedStoreObject) { (reviews, error) -> () in
            self.refreshControl.endRefreshing()
            if error != nil {
                // handle error here
            } else {
                if let reviews = reviews {
                    self.reviewsArray = reviews
                }
            }
            
            self.tableView.hideLoadingIndicator()
            self.tableView.reloadData()
        }
    }

    // MARK: tableView methods
    /**
     How many rows to display, in this case the number of reviews.
     
     - parameter tableView: tableView
     - parameter section:   at which section
     
     - returns: number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewsArray.count
    }

    /**
     Asks the data source for a cell to insert in a particular location of the table view. Get the right review and set the cell.
     
     - parameter tableView: tableView
     - parameter indexPath: which indexPath
     
     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reviewCell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewTableViewCell
        
        let reviewObject = reviewsArray[indexPath.row]
        reviewCell.reviewTextLabel.text = reviewObject.text
        reviewCell.setRating(reviewObject.rating)
        reviewCell.dateLabel.text = dateFormatter.string(from: reviewObject.created as Date)
        
        if let fileURL = reviewObject.fileURL {
            reviewCell.setReviewImageViewHidden(false)
            let imageArray = fileURL.components(separatedBy: ",")
            if imageArray.count == 1 {
                reviewCell.reviewImageView.hnk_setImage(from: URL(string: fileURL))
            } else {
                reviewCell.reviewImageView.hnk_setImage(from: URL(string: imageArray[0]))
                // Add UIView which can explain the number of photos behind
                let myLabel = UILabel(frame: CGRect(x: reviewCell.reviewImageView.frame.width-30, y: reviewCell.reviewImageView.frame.height-30, width: 30, height: 30))
                myLabel.textAlignment = .center
                myLabel.backgroundColor = UIColor(red: 211, green: 211, blue: 211, alpha: 0.8)
                myLabel.text = "+\(imageArray.count-1)"
                myLabel.font = UIFont(name: "Avenir", size: 12)
                reviewCell.reviewImageView.addSubview(myLabel)
                reviewCell.reviewImageView.bringSubview(toFront: myLabel)
            }
        } else {
            reviewCell.setReviewImageViewHidden(true)
        }
        
        return reviewCell
    }
    
    // Create a overlay UIView
    func placeUIView(_ count: Int) {
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "showReview", sender: indexPath)
    }

    // MARK: - Navigation
    /**
     Called before performing a segue. Need to assign the selected Store object to the AddReviewViewController, to be able to leave a review on that Store object.
     
     - parameter segue:  segue
     - parameter sender: sender
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddNewReview" {
            let destinationController = segue.destination as! AddReviewViewController
            destinationController.selectedStore = selectedStoreObject
        } else if segue.identifier == "showReview", let indexPath = sender as? IndexPath {
            let selectedReview = reviewsArray[indexPath.row]
            let destinationController = segue.destination as! ReviewsDetailViewController
            destinationController.reviewToDisplay = selectedReview
            destinationController.transitioningDelegate = reviewPresentManager
        }
    }
    
    /**
     Determines whether the segue with the specified identifier should be performed. In our case, if user is not logged in, we present the loginViewController instead of performing the segue
     
     - parameter identifier: identifier of the segue
     - parameter sender:     sender
     
     - returns: YES, if it should be executed
     */
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showAddNewReview" {
            if UserManager.isUserLoggedIn() {
                return true
            } else {
                // display login view
                let loginViewController = StoryboardManager.loginViewController()
                loginViewController.displayCloseButton = true
                present(loginViewController, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }
    
    /**
     Which statusbar style to display, white in this case.
     
     - returns: White statusbar.
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}
