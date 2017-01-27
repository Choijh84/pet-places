//
//  StoreDetailViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import MapKit
import HCSStarRatingView
import MessageUI


class StoreDetailViewController: UIViewController {

    /// Datasource object that is responsible for managing data for the tableView
    var dataSource: StoreDetailViewDatasource!
    
    /// TableView that displays all the different sections and rows to be displayed
    @IBOutlet var tableView: UITableView!
    /// To show the store's image
    @IBOutlet var storeImageView: LoadingImageView!
    /// To show the name
    @IBOutlet var storeNameLabel: UILabel!
    /// to show the detail text
    @IBOutlet var storeSubtitleLabel: UILabel!
    /// To show the rating of the store
    @IBOutlet var storeRatingView: HCSStarRatingView!
    /// TO show the number of rating and average rating value
    @IBOutlet var storeRatingLabel: UILabel!
    /// Custom navigation bar view that displayed on top of the view, gets adjusted when tableview is scrolled
    @IBOutlet var customNavigationBarView: GradientHeaderView!
    /// Back Button 
    @IBOutlet var backButton: UIButton!
    
    
    /// the store object we want to display
    var storeToDisplay: Store!
    
    /// Manager that downloads the reviews for the selected Store
    let reviewManager: ReviewManager = ReviewManager()
    /// Array of downloaded Reviews
    var downloadedReviews: [Review] = []
    /// Section to display the reviews
    var reviewsSection: StoreDetailSectionDatasource<ReviewTableViewCell>!
    
    /// Section that displays the "Read more reviews" or "Leave a review" button
    var reviewButtonSection: StoreDetailSectionDatasource<ReviewOptionsTableViewCell>!
    
    /// Section to display the Reviews headerView (which in our case is a simple Cell).
    var reviewSectionHeaderRow: StoreDetailRowDatasource<UITableViewCell>! = nil
    
    /// The default headerView height
    fileprivate let kTableHeaderHeight: CGFloat = 240
    /// Headerview reference to be able to create the stretchy headerView effect
    var headerView: UIView!
    
    /// Dismisses the view when the back button is pressed
    @IBAction func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    /**
     Sets up the stretchy header view of the tableView
     */
    func setupHeaderView() {
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        updateHeaderView()
    }
    
    /**
     Adjusts the headerView according to the contentOffset of the tableView
     */
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    /**
     Update the headerView when the layout changes
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderView()
    }
    
    // MARK: view methods
    /**
     Calls when the view is loaded. Load all the details from the store object to the labels, and adjust the view
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /// set up the Self-Sizing Table View Cells
        
        tableView.estimatedRowHeight = 60.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        setupDatasource()
        
        storeNameLabel.text = storeToDisplay.name
        storeSubtitleLabel.text = storeToDisplay.storeSubtitle
        
        self.storeRatingView.alpha = 1.0
        self.storeRatingView.value = CGFloat(storeToDisplay.reviewAverage ?? 0)
        
        if let imageURL = storeToDisplay.imageURL {
            storeImageView.hnk_setImage(from: URL(string: imageURL))
        }
        
        setupHeaderView()
        tableView.tableFooterView = UIView(frame: .zero)
        
        // Hide the navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidLayoutSubviews()
    }
    
    
    /**
     Set up the datasource for the tableView
     */
    func setupDatasource() {
        // define all your sections and rows here
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "reviewCell")
        
        // About Section
         let aboutSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) in
            cell.textLabel?.text = "About"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        let aboutSection = StoreDetailRowDatasource<DescriptionTableViewCell>(identifier: "descriptionCell", setupBlock: { (cell) in
            self.configureDescriptionCell(cell)
        }) { 
            // add method here to handle cell selection
        }
        
        // Info Section
        let infoSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) in
            cell.textLabel?.text = "Info"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        let infoSection = StoreDetailSectionDatasource<InfoWithIconTableViewCell>(cellIdentifier: "infoWithIcon", numberOfRows: 3, setupBlock: { (cell, row) in
            self.configureInfoSectionCell(cell, row: row)
        }) { (cell, row) in
            self.infoSectionCellWasSelected(cell, row: row)
        }
        
        // Photo Section
        let photoSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) in
            cell.textLabel?.text = "Photo"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }

        let photoSection = StoreDetailRowDatasource<storePhotoTableViewCell>(identifier: "storePhotoCell") { (cell) in
            DispatchQueue.main.async(execute: { 
                self.configureStorePhotoCell(cell)
            })
            
        }
        
        // Map Section
        let locationSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) in
            cell.textLabel?.text = "Location"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        let mapSection = StoreDetailRowDatasource<StoreMapTableViewCell>(identifier: "mapCell", setupBlock: { (cell) in
            DispatchQueue.main.async(execute: {
                self.configureMapCell(cell)
            })
        }) {
            // add method here to handle cell selection
        }
        
        let mapInfoSection = StoreDetailRowDatasource<InfoWithIconTableViewCell>(identifier:"infoWithIcon", setupBlock: { (cell) in
            self.configureMapInfoSectionCell(cell)
        }) { 
            let placeMark = MKPlacemark(coordinate: self.storeToDisplay.coordinate(), addressDictionary: nil)
            let destination = MKMapItem(placemark: placeMark)
            destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking])
        }
        
        // Review section
        reviewSectionHeaderRow = StoreDetailRowDatasource<UITableViewCell>(identifier: "sectionHeaderSpaceCell") { (cell) -> () in
            cell.textLabel?.text = "Reviews"
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        reviewsSection = StoreDetailSectionDatasource<ReviewTableViewCell>(cellIdentifier: "reviewCell", numberOfRows: downloadedReviews.count, setupBlock: { (cell, row) -> () in
            self.configureReviewsCells(cell, row: row)
        }) { (cell, row) -> () in
            // add method here to handle cell selection
        }
        
        reviewButtonSection = StoreDetailSectionDatasource<ReviewOptionsTableViewCell>(cellIdentifier: "reviewButtons", numberOfRows: 1, setupBlock: { (cell, row) -> () in
            self.configureReviewButtonsCell(cell, row: row)
        }) { (cell, row) -> () in
            // add method here to handle cell selection
        }
        
        dataSource = StoreDetailViewDatasource(sectionSources: [aboutSectionHeaderRow, aboutSection, infoSectionHeaderRow, infoSection, photoSectionHeaderRow, photoSection, locationSectionHeaderRow, mapInfoSection, mapSection, reviewSectionHeaderRow, reviewsSection, reviewButtonSection])
        
        // Need to add: reviewSectionHeaderRow, reviewSection, reviewButtonSection
        
        dataSource.tableView = tableView
        tableView.dataSource = dataSource
        tableView.reloadData()
        
        downloadReviews()
    }
    
    /**
     Download the reviews, updates the rating view, and displays the reviews if any is available
     */
    func downloadReviews() {
        let limit = 3 // only display 3 items here
        reviewManager.downloadReviewCountsAndReviewsForStore(storeToDisplay) { (reviews, error) -> () in
            if (reviews?.count)! > 0 {
                self.downloadedReviews = reviews!
                self.reviewsSection.numberOfRows = (limit < reviews!.count) ? limit : reviews!.count
                
                self.storeToDisplay.reviews = reviews!
                self.storeRatingLabel.alpha = 1.0
                self.storeRatingView.value = CGFloat(self.storeToDisplay.reviewAverage ?? 0)
            } else {
                // remove the review section header and reload the tableView if there are no reviews to show.
                self.dataSource.removeSectionAtIndex((self.reviewSectionHeaderRow?.sectionIndex)!)
                self.tableView.reloadData()
            }
            
            if self.storeToDisplay.reviewCount != 0 {
                self.storeRatingLabel.text = "\(String(format: "%.1f", self.storeToDisplay.reviewAverage!.floatValue)) of \(self.storeToDisplay.reviews.count) ratings"
            } else {
                self.storeRatingLabel.text = ""
            }
        }
    }
    
    // MARK: configuration methods for cells
    /**
     Configures the description cell
     
     - parameter cell: cell to set
     */
    func configureDescriptionCell(_ cell: DescriptionTableViewCell) {
        cell.descriptionLabel.text = storeToDisplay.storeDescription
    }
    
    /**
     Configures the info sectin cells, sets the phone number, website and email address
     
     - parameter cell: cell to set
     - parameter row:  at which row
     */
    func configureInfoSectionCell(_ cell: InfoWithIconTableViewCell, row: Int) {
        if row == 0 {
            cell.infoLabel.text = storeToDisplay.phoneNumber
            cell.iconImageView.image = UIImage(named: "phoneIcon")
        } else if row == 1 {
            cell.infoLabel.text = storeToDisplay.emailAddress
            cell.iconImageView.image = UIImage(named: "emailIcon")
        } else {
            cell.infoLabel.text = storeToDisplay.website
            cell.iconImageView.image = UIImage(named: "visitIcon")
        }
    }
    
    /**
     Configures the store Photo cell
     - parameter cell: cell to configure
     */
    func configureStorePhotoCell(_ cell: storePhotoTableViewCell) {
        
        cell.scrollView.delaysContentTouches = false
        
        if storeToDisplay.imageArray != nil {
            if let imageArray = storeToDisplay.imageArray {
                
                let storePhotos = imageArray.components(separatedBy: ",")
                
                for i in 0..<(storePhotos.count) {
                    
                    if let url = URL(string: storePhotos[i]) {
                        print("This is photo url: \(url)")
                        cell.storePhotoImage.contentMode = .scaleAspectFill
                        cell.storePhotoImage.hnk_setImage(from: url, placeholder: UIImage(named: "loadingIndicator"), success: { (image) in
                            
                            let imageView = UIImageView()
                            imageView.image = image
                            let xPosition = self.view.frame.width * CGFloat(i)
                            imageView.frame = CGRect(x: xPosition, y: 0, width: cell.scrollView.frame.width, height: cell.scrollView.frame.height)
                            cell.scrollView.contentSize.width = cell.scrollView.frame.width * CGFloat(i+1)
                            cell.scrollView.addSubview(imageView)
                            
                            
                        }, failure: { (error) in
                            print("there is an error on fetching store photos")
                        })
                        
                    } else {
                        print("url is nil")
                    }
                }
                self.view.setNeedsLayout()
            }
        } else {
            let imageArray = [#imageLiteral(resourceName: "backgroundImage")]
            for i in 0..<(imageArray.count) {
                
                let imageView = UIImageView()
                imageView.image = imageArray[i]
                imageView.contentMode = .scaleAspectFill
                
                let xPosition = self.view.frame.width * CGFloat(i)
                imageView.frame = CGRect(x: xPosition, y: 0, width: cell.scrollView.frame.width, height: cell.scrollView.frame.height)
                
                cell.scrollView.contentSize.width = cell.scrollView.frame.width * CGFloat(i+1)
                cell.scrollView.addSubview(imageView)
            }
        }
    }
    
    /**
     Configures the map cell
     
     - parameter cell: cell to configure
     */
    func configureMapCell(_ cell: StoreMapTableViewCell) {
        cell.zoomMapToStoreLocation(storeToDisplay)
    }
    
    /**
     Configures the map info section
     
     - parameter cell: cell to configure
     */
    func configureMapInfoSectionCell(_ cell: InfoWithIconTableViewCell) {
        cell.infoLabel.text = storeToDisplay.address
        cell.iconImageView.image = UIImage(named: "cellLocationIcon")
    }
    
    /**
     Configures the reviews cell
     
     - parameter cell: cell to configure
     - parameter row:  at which row
     */
    func configureReviewsCells(_ cell: ReviewTableViewCell, row: Int) {
        let review = downloadedReviews[row]
        cell.reviewTextLabel.text = review.text
        cell.setRating(review.rating)
        
        if let fileURL = review.fileURL {
            cell.setReviewImageViewHidden(false)
            cell.reviewImageView.hnk_setImage(from: URL(string: fileURL))
        } else {
            cell.setReviewImageViewHidden(true)
        }
    }
    
    /**
     Configures the reviews button cell
     
     - parameter cell: cell to configure
     */
    func configureReviewButtonsCell(_ cell: ReviewOptionsTableViewCell, row: Int) {
        if downloadedReviews.count == 0 {
            cell.changeButtonTitle("Leave a review")
            cell.removeButtonTargets(self, action: #selector(StoreDetailViewController.leaveAReviewButtonPressed))
            cell.addButtonTarget(self, action: #selector(StoreDetailViewController.leaveAReviewButtonPressed), forControlEvents: .touchUpInside)
        } else {
            cell.changeButtonTitle("Read more reviews")
            cell.removeButtonTargets(self, action: #selector(StoreDetailViewController.readMoreReviewsPressed))
            cell.addButtonTarget(self, action: #selector(StoreDetailViewController.readMoreReviewsPressed), forControlEvents: .touchUpInside)
        }
    }
    
    /**
     Show the ReviewsViewController and display all the reviews for the selected Store
     */
    func readMoreReviewsPressed() {
        let reviewsController = StoryboardManager.reviewsViewController()
        reviewsController.selectedStoreObject = storeToDisplay
        
        navigationController?.pushViewController(reviewsController, animated: true)
        
    }
    
    /**
     Called when the leave a review button is selected, first it checks if the user is logged in or not. If not, presents the login
     */
    func leaveAReviewButtonPressed() {
        if UserManager.isUserLoggedIn() {
            readMoreReviewsPressed()
        } else {
            // display login view
            let loginViewController = StoryboardManager.loginViewController()
            loginViewController.displayCloseButton = true
            present(loginViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Handle selection
    /**
    Called when any of the info section's row is selected
     
     - parameter cell: cell that was selected
     - parameter row: which row was selected
    */
    func infoSectionCellWasSelected(_ cell: InfoWithIconTableViewCell, row: Int) {
        if row == 0 {
            callButtonPressed()
        } else if row == 1 {
//            emailButtonPressed()
        } else {
//            webButtonPressed()
        }
    }

    /**
     Calls the datasource's section selection block when the user selected a row
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath that was selected
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dataSource.sectionSources[indexPath.section].tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    /**
     Presents an alertView to be able to call the store's phoneNumber
     */
    func callButtonPressed () {
        let alertViewController = UIAlertController(title: NSLocalizedString("Call", comment: ""), message: "\(storeToDisplay.phoneNumber)", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Call", style: .default, handler: { (alertAction) -> Void in
            let phoneNumberString = "telprompt://\(self.storeToDisplay.phoneNumber)"
            UIApplication.shared.open(URL(string: phoneNumberString)!, options: [:], completionHandler: nil)
        }))
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) -> Void in
            alertViewController.dismiss(animated: true, completion: nil)
        }))
        present(alertViewController, animated: true, completion: nil)
    }

    /**
     What status bar style we want to use
     
     :returns: light statusbar style
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}

// MARK: - Extension of the viewController
extension StoreDetailViewController {
    
    /**
     Called when the user scrolled the tableView. Updates the headerView and checks to change the navigation bar's backgroundColor to solid or not.
     
     - parameter scrollView: ScrollView
     */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
        
        if scrollView.contentOffset.y >= -(customNavigationBarView.frame).height {
            customNavigationBarView.adjustBackground(false)
        } else {
            customNavigationBarView.adjustBackground(true)
        }
    }
}
