//
//  LocationControlViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import GooglePlaces
import SCLAlertView

class LocationControlViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var autoCompleteButton: UIButton!
    
    @IBOutlet weak var addressline: UILabel!
    
    @IBOutlet weak var tableView: LoadingTableView!
    
    // Array to hold the search history - object GMSPlace ID
    var history = [String]()
    
    // Declare variables to hold address form values.
    var formattedAddress: String = ""
    var placeName: String = ""
    var placeID: String = ""
    var coordinate = CLLocationCoordinate2D()
    
    @IBAction func autocompleteClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Set a filter to return only address
        let addressFilter = GMSAutocompleteFilter()
        addressFilter.type = .noFilter
        autocompleteController.autocompleteFilter = addressFilter
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UserDefaults에서 불러 읽어옴 - 없는 경우를 대비해서
        if let dict = UserDefaults.standard.value(forKey: "SavedAddressHistory") {
            history = dict as! [String]
        } else {
            history = []
        }
        
        autoCompleteButton.layer.cornerRadius = 15
        
        // Tableview tpxld
        tableView.showLoadingIndicator()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.hideLoadingIndicator()
        
        // UserDefau기ts 프린트 한 번 하기
        // print(UserDefaults.standard.dictionaryRepresentation())
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CancelToList" {
            print("Cancelled")
        } else if segue.identifier == "ConfirmLocation" {
            print("Confirmed")
        }
    }
    
    // Populate the address form fields, erase the country expression
    func fillAddressForm() {
        if let index = formattedAddress.characters.index(of: " ") {
            let startIndex = formattedAddress.index(after: index)
            let pos = formattedAddress.substring(from: startIndex)
            print("This is substring: \(pos)")
            addressline.text = pos
            addressline.textColor = UIColor.black
            formattedAddress = pos
        }
    }
    
    func checkHistory() {
        if history.count > 6 {
            history.removeFirst()
        }
    }
    
    /// MARK: TableView Function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 무조건 최근 5개 또는 적은 수를 보여줌
        if history.count < 6 {
            return history.count
        } else {
            return 6
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! AddressHistoryTableViewCell
        
        let placeId = history[indexPath.row]
        
        GMSPlacesClient().lookUpPlaceID(placeId) { (place, error) in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }
            
            cell.placeNameLabel.text = place.name
            cell.placeAddressLabel.text = place.formattedAddress
            cell.placeCoordinate = place.coordinate
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            tableView.beginUpdates()
            // remove the item from data model
            history.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
            UserDefaults.standard.set(history, forKey: "SavedAddressHistory")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeId = history[indexPath.row]
        
        GMSPlacesClient().lookUpPlaceID(placeId) { (place, error) in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeId)")
                return
            }
            
            self.placeName = place.name
            if let formattedAddress = place.formattedAddress {
                self.formattedAddress = formattedAddress
            }
            self.coordinate = place.coordinate
            
            // Call custom function to populate the address form.
            UIView.animate(withDuration: 0.3, animations: {
                self.addressline.fadeOut(0.3, delay: 0.0, completion: { (true) in
                    self.fillAddressForm()
                    self.addressline.fadeIn(0.3, delay: 0.1, completion: { (true) in
                        print("Done")
                    })
                })
            })
            
        }

    }
}

extension LocationControlViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place Geolocation: \(place.coordinate)")
        
        if let address = place.formattedAddress {
            placeName = place.name
            placeID = place.placeID
            formattedAddress = address
            coordinate = place.coordinate
        }
        
        // Attach the placeID into history 
        history.append(placeID)
        checkHistory()
        UserDefaults.standard.set(history, forKey: "SavedAddressHistory")
        
        // Call custom function to populate the address form.
        fillAddressForm()
        
        // Close the autocomplete widget.
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Show the network activity indicator.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    // Hide the network activity indicator.
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension UIView {
    func fadeIn(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 1.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
