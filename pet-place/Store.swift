//
//  StoreObject.swift
//  Pet-Hotels
//
//  Created by Owner on 2016. 12. 25..
//  Copyright © 2016년 TwistWorld. All rights reserved.
//

import UIKit
import CoreLocation

/// An object to store all the details of the Store that we want to display.
class Store: NSObject {

    var objectId: String?
    /// Name of the store
    var name: String?
    /// Address of the store
    var address: String?
    /// PhoneNumber of the Store
    var phoneNumber: String?
    /// Short description of the Store
    var storeDescription: String?
    /// Subtitle of the Store
    var storeSubtitle: String?
    /// Website of the Store
    var website: String?
    /// Distance between current and store's location
    var distance: Double?
    /// GeoPoint from backendless.com
    var location: GeoPoint?
    /// Email address of the store.
    var emailAddress: String?
    /// mainImage of the store
    var imageURL: String?
    /// images of the store
    var imageArray: String?
    
    /// 서비스 카테고리 
    var serviceCategory: String? 
    /// opeartion Time 
    var operationTime: String?
    /// serviceable Pet 
    var serviceablePet: String?
    /// available size of Pet 
    var petSize: String?
    /// information about the price
    var priceInfo: String?
    /// note for the precautions
    var note: String?
    /// array for Favorite List of users
    var favoriteList: [BackendlessUser] = []
    /// the number of user looked at the store
    var hits: Int = 0
    
    
    /// Boolean for favorite or not
//    var isFavorited: Bool = false
    /// Category of the Store object (pension, cafe, etc.)
//    var parentCategory: StoreCategory?
    /// Categories of the Store objects - moved to the StoreCategory
//    var parentCategories: [StoreCategory] = []
    
    /// Array of Review objects that connected with the Store
    var reviews: [Review] = [] {
        didSet {
            var average: Double = 0
            for review in reviews {
                average += review.rating.doubleValue
            }
            self.reviewAverage = Double(NSNumber(value: average / Double(reviews.count)))
            self.reviewCount = Int((reviews.count as NSNumber?)!)
        }
    }
    /// Number of reviews
    var reviewCount: Int = 0
    /// Average rating of reviews
    var reviewAverage: Double = 0.0

    /**
     Creates a coordinate of the Store from the location object, if no location object is found, creates a 0,0 coordinate

     - returns: coordinate of the Store
     */
    func coordinate() -> CLLocationCoordinate2D {
        if location != nil {
            return CLLocationCoordinate2DMake(location!.latitude.doubleValue, location!.longitude.doubleValue)
        }
        return CLLocationCoordinate2DMake(0, 0)
    }

    /**
     Calculates the distance between the current location and the location of the store

     :param: currentLocation the user's current location
     */
    func calculateDistanceBetweenCurrentLocation(_ currentLocation: CLLocation?) {
        if (currentLocation != nil) {
            let coordinate = self.coordinate()
            distance = currentLocation!.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) as Double
            print("Distance: \(distance!)")
        }
    }
    
    func calculationDistanceBetweenCoordinates(_ pickedCoordinate: CLLocationCoordinate2D?) {
        let currentLocation = CLLocation(latitude: (pickedCoordinate?.latitude)!, longitude: (pickedCoordinate?.longitude)!)
        let coordinate = self.coordinate()
        distance = currentLocation.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) as Double
        print("Distance: \(distance!)")
    }

    /**
     Returns a formatted distance string, e.g.: 1,4 km away

     :return: NSString - formatted distance string
     */
    func distanceString() -> String! {
        if let distance = distance {
            if distance == 0 { // when distance is zero, return an empty string
                return ""
            }
            else {
                let temp = NSString.distanceStringWithValue(distance)
                return temp as String!
            }
        }
        return ""
    }
}
