//
//  LocationsDownloadManager.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 3..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Class is intended to be used to download Store Objects

class LocationsDownloadManager : NSObject {
    
    /// User's location coordinate object 
    var userCoordinate: CLLocationCoordinate2D!
    
    /// selected Store category 
    var selectedStoreCategory: StoreCategory?
    
    /// selected sorting option
    var selectedSortedOption: SortingOption = SortingOption(name: "distance", sortingKey: SortingKey.distance)
    
    /// Store object that handles downloading of Store objects
    let dataStore = Backendless.sharedInstance().persistenceService.of(Store.self)
    
    /**
    Download Store objects
    - parameter skip:   items to skip, that were loaded before
    - parameter limit:  max amount of Store objects to load
    - parameter completionBlock: called after the request is completed, returns the Store object
    */
    
    func downloadStores(skippingNumberOfObjects skip: NSNumber, limit: NSNumber, completionBlock: @escaping (_ storeObjects: [Store]?, _ error: String?) -> ()) {
        let query = BackendlessDataQuery()
        
        let queryOptions = QueryOptions()
        
        if selectedSortedOption.sortingKey != SortingKey.distance {
            queryOptions.sortBy = ["\(selectedSortedOption.sortingKey!.rawValue).desc"]
        }
        
        queryOptions.related = ["parentCategory", "location"]
        queryOptions.pageSize = limit
        queryOptions.offset = skip
        query.queryOptions = queryOptions
        
        // 반경 2000km로 쿼리
        query.whereClause = "distance(\(userCoordinate.latitude), \(userCoordinate.longitude), location.latitude, location.longitude ) < km(2000)"
        
        if let selectedStoreCategory = selectedStoreCategory {
            query.whereClause = "AND parentCategory.objectId = \'\(selectedStoreCategory.objectId!)\'"
        }
        
        print("Clause: \(query.whereClause)")
        print("Sorted by: \(queryOptions.sortBy)")
        
        dataStore?.find(query, response: { (collection) in
            let sortedObjects = self.sortObjectsManuallyByDistance(collection?.data as! [Store])
            completionBlock(sortedObjects, nil)
        }, error: { (fault) in
            print(fault)
            completionBlock(nil, fault?.description)
        })
    }
    
    /**
     Sorts the stores objects manually by distance from the user's location. Only temporary fix until the backendless SDK is fixed to support proper distance based sorting
     
     - parameter storeObjects: objects to sort
     
     - returns: sorted objects
     */
    private func sortObjectsManuallyByDistance(_ storeObjects: [Store]) -> [Store] {
        var storeObjects = storeObjects
        if selectedSortedOption.sortingKey == SortingKey.distance {
            storeObjects.sort { (store1, store2) -> Bool in
                let location1 = locationForStore(store1)
                let location2 = locationForStore(store2)
                
                let userLocation = CLLocation(latitude: Double(userCoordinate.latitude), longitude: Double(userCoordinate.longitude))
                let distance1 = location1.distance(from: userLocation)
                let distance2 = location2.distance(from: userLocation)
                
                return distance1 < distance2
            }
        }
        
        return storeObjects
    }
    
    /**
     Creates a location
     
     - parameter store: store
     
     - returns: Location
     */
    
    fileprivate func locationForStore(_ store: Store) -> CLLocation {
        return CLLocation(latitude: Double(store.location!.latitude), longitude: Double(store.location!.longitude))
    }
    
    
}
