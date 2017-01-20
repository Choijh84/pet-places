//
//  StoresCategoryViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 2..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class StoresCategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /// Categories that needs to be displayed
    let section = ["PET PLACES", "PET SERVICES"]
    let items = [["Pet Pension", "Pet Cafe", "Hotel with Pet", "Restaurant with Pet", "Pet Hospital", "Pet Shops"],
                 ["Pet Beauty", "Pet Daycare", "Pet Hoteling"]]
    
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
        return items[section].count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StoreCategoryListTableViewCell
        
        // Configure the cell
        let serviceName = self.items[indexPath.section][indexPath.row]
        cell.nameLabel.text = serviceName
        if (UIImage(named: serviceName) == nil) {
            cell.categoryImage.image = #imageLiteral(resourceName: "pethotel2")
        } else {
            cell.categoryImage.image = UIImage(named: serviceName)
        }
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PLACES CATEGORY"
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
                    destinationVC.selectedStoreType = items[indexPath.section][indexPath.row]
                }
                
            }
        }
    }
    
    /**
     Returns the preferred statusbar style, this case Light(White)
     
     :returns: the statusbar style (White)
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}
