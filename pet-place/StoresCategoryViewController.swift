//
//  StoresCategoryViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class StoresCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LocationHandlerProtocol {

    @IBOutlet weak var tableView: LoadingTableView!
    
    /// Categories that needs to be displayed
    let section = ["PET PLACES"]
    
    /// A handler object that responsible for getting the user's location
    var locationHandler: LocationHandler!
    /// Last saved location
    var lastLocation: CLLocation?
    /// Variable to check whether user picked a location or not
    var isConfirmedLocation = false
    
    /// Save the selected storeCategory as a reference
    var selectedCategory: StoreCategory?
    /// Array to hold all the downloaded categories
    var allStoreCategories: [StoreCategory] = []
    
    /// User selected Location(coordinate & address)
    var selectedLocation = CLLocationCoordinate2D()
    var selectedAddress = ""
    
    /// Address Presentation
    @IBOutlet weak var formattedAddress: UILabel!
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return section.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStoreCategories.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCategoryListTableViewCell
        
        // Configure the cell
        let serviceName = allStoreCategories[indexPath.row]
        cell.nameLabel.text = serviceName.name
        if (UIImage(named: serviceName.name!) == nil) {
            // default image file if there is no matched image file
            cell.categoryImage.image = #imageLiteral(resourceName: "pethotel2")
        } else {
            // Load the category image with the same name image file
            // Maybe try to load the image file from the server later
            cell.categoryImage.image = UIImage(named: serviceName.name!)
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PLACES CATEGORY"
        self.tabBarController?.tabBar.isTranslucent = false
        
        downloadStoreCategories()
        checkLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        checkLocation()
    }
    
    func checkLocation() {
        locationHandler = LocationHandler()
        locationHandler.locationHandlerProtocol = self
        locationHandler.startLocationTracking()
        
        if isConfirmedLocation == false {
            var userLocation = locationHandler.locationManager.location
            print("userLocation: \(userLocation)")
            if userLocation == nil {
                userLocation = lastLocation
                locationHandler.geocodeLocation(userLocation!) { (geocodedName, placeMark, error) -> () in
                    if let geocodedName = geocodedName {
                        self.formattedAddress.text = geocodedName
                    } else {
                        self.formattedAddress.text = "Example Address"
                    }
                }
            } else {
                locationHandler.geocodeLocation(userLocation!) { (geocodedName, placeMark, error) -> () in
                    if let geocodedName = geocodedName {
                        self.formattedAddress.text = geocodedName
                    } else {
                        self.formattedAddress.text = "Example Address"
                    }
                }
            }
        } else {
            formattedAddress.text = selectedAddress
        }
    }
    
    // MARK: Location Handler Protocol
    
    func locationHandlerDidUpdateLocation(_ location: CLLocation) {
        if isConfirmedLocation == false {
            if let lastLocation = lastLocation {
                // only request new store objects when the user moved 1000 meters or more, since the last saved location
                if lastLocation.distance(from: location) > 1000 {
                    //downloadManager.userCoordinate = location.coordinate
                    //downloadStores()
                }
                self.lastLocation = location
            } else {
                //downloadManager.userCoordinate = location.coordinate
                self.lastLocation = location
            }
        } else {
            print("Fixed the location")
        }
        
    }
    
    /**
     Tells the delegate that the specified row is now selected. Just deselect it, selection will be covered by segues.
     
     :param: tableView A table-view object informing the delegate about the new row selection.
     :param: indexPath An index path locating the new selected row in tableView.
     */
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//    }
 
    /**
     Called when the segue is about to be performed. Get the storyObject that is connected with the cell, and assign it to the destination viewController.
     
     :param: segue  The segue object containing information about the view controllers involved in the segue.
     :param: sender The object that initiated the segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// segue name: findPlaces
        
        if segue.identifier == "findPlaces" {
            let destinationVC  = segue.destination as! StoresListImageViewController
            if let sender = sender {
                
                if ((sender as AnyObject) is IndexPath) {
                    let indexPath:IndexPath = sender as! IndexPath
                    print("This is selected store type: \(allStoreCategories[indexPath.row])")
                    destinationVC.selectedStoreType = allStoreCategories[indexPath.row]
                } else if (sender as AnyObject).isKind(of: StoreCategory.self) {
                    let indexPath:IndexPath = sender as! IndexPath
                    print("This is selected store type: \(allStoreCategories[indexPath.row])")
                    destinationVC.selectedStoreType = allStoreCategories[indexPath.row]
                } else if (sender as AnyObject).isKind(of: StoreCategoryListTableViewCell.self) {
                    /// 여기서 핸들링됨
                    let cell = sender as! StoreCategoryListTableViewCell
                    let indexPath = tableView.indexPath(for: cell)
                    print("This is selected store type: \(allStoreCategories[(indexPath?.row)!])")
                    destinationVC.selectedStoreType = allStoreCategories[(indexPath?.row)!]
                    if isConfirmedLocation == true {
                        destinationVC.pickedLocation = CLLocation(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude)
                        destinationVC.isConfirmedLocation = isConfirmedLocation
                    }
                }
                
            }
        }
    }
    
    /**
     Downloads all the Category objects
     */
    func downloadStoreCategories() {
        self.tableView.showLoadingIndicator()
        
        let categoryDownload = CategoryDownloadManager()
        categoryDownload.downloadStoreCategories { (categories, errorMessage) in
            DispatchQueue.main.async(execute: { 
                if let errorMessage = errorMessage {
                    let alertView = UIAlertController(title: "Error", message: errorMessage as String, preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) in
                        self.downloadStoreCategories()
                    }))
                    self.present(alertView, animated: true, completion: nil)
                } else {
                    if let categories = categories {
                        self.allStoreCategories = categories
                    }
                    self.tableView.reloadData()
                    self.tableView.hideLoadingIndicator()
                }
            })
        }
    }
    
    /**
     Returns the preferred statusbar style, this case Light(White)
     
     :returns: the statusbar style (White)
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func cancelToCategory (segue: UIStoryboardSegue) {
        print("Cencelled")
    }
    
    @IBAction func confirmLocation (segue: UIStoryboardSegue) {
        let LocationControlVC = segue.source as! LocationControlViewController
        let address = LocationControlVC.formattedAddress
        let coordinate = LocationControlVC.coordinate
        
        if address == "" {
            print("Address is nil")
        } else {
            selectedAddress = address
            selectedLocation = coordinate
            isConfirmedLocation = true
        }
    }

}
