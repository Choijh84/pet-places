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

class LocationControlViewController: UIViewController {

    @IBOutlet weak var addressline: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    // Declare variables to hold address form values.
    var formattedAddress: String = ""
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

        // Do any additional setup after loading the view.
        print(UserDefaults.standard.dictionaryRepresentation())
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
            formattedAddress = pos
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
            formattedAddress = address
            coordinate = place.coordinate
        }
        
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
