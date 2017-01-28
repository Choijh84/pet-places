//
//  ReviewManager.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Object that helps to download reviews for the selected Shop
class ReviewManager: NSObject {
    
    /// Store object that handles downloading of Reviews
    let dataStore = Backendless.sharedInstance().data.of(Review.self)
    
    func uploadNewReview(_ text: String, selectedFile: UIImage?, rating: NSNumber, store: Store, completionBlock: @escaping (_ completed: Bool, _ store: Store?, _ errorMessage: String?)->()) {
        if let selectedFile = selectedFile {
            let fileName = String(format: "%0.0f.jpeg", Date().timeIntervalSince1970)
            let filePath = "reviewImages/\(fileName)"
            let content = UIImageJPEGRepresentation(selectedFile, 1.0)
            
            Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
                let fileURL = uploadedFile?.fileURL
                self.uploadNewReview(text, fileURL: fileURL, rating: rating, store: store, completionBlock: completionBlock)
            }, error: { (fault) in
                print(fault.debugDescription)
                completionBlock(false, nil, fault?.description)
            })
        } else {
            uploadNewReview(text, fileURL: nil, rating: rating, store: store, completionBlock: completionBlock)
        }
    }
    
    /**
     Uploads a new review
     
     - parameter text:            body of the review
     - parameter rating:          rating value of the review
     - parameter store:           the Store that this review should be attached to
     - parameter completionBlock: called after the review has been uploaded
     - parameter error:           error if any
     */
    fileprivate func uploadNewReview(_ text: String, fileURL: String?, rating: NSNumber, store: Store, completionBlock: @escaping (_ completed: Bool, _ store: Store?, _ errorMessage: String?) -> ()) {
        let review = Review()
        review.rating = rating
        review.text = text
        review.fileURL = fileURL
        review.creator = UserManager.currentUser()
        
        store.reviewCount = (store.reviews.count+1) as NSNumber
        store.reviews = [review]
        
        Backendless.sharedInstance().persistenceService.save(store, response: { (storeObject) in
            completionBlock(true, store, nil)
        }) { (fault) in
            completionBlock(false, nil, fault?.description)
        }
    }
    
    /**
     Downloads reviews for the selected Store, returns the number of reviews and the average rating value
     
     - parameter storeObject:     Store Object that we need the reviews for
     - parameter completionBlock: completionBlock after it completes. Return the reviews, their count, and average value
     - parameter error:           error if any
     */
    func downloadReviewCountsAndReviewsForStore(_ storeObject: Store, completionBlock: @escaping (_ reviews: [Review]?, _ error: NSError?) -> ()) {
        let query = BackendlessDataQuery()
        
        let queryOptions = QueryOptions()
        queryOptions.sortBy = ["created desc"]
        query.queryOptions = queryOptions
        // Download only the reviews that are related to the selected Store
        query.whereClause = "Store[reviews].objectId = \'\(storeObject.objectId!)\'"
        
        dataStore?.find(query, response: { (collection) in
            completionBlock(collection?.data as? [Review], nil)
        }, error: { (fault) in
            print(fault?.description ?? "Error")
            completionBlock(nil, nil)
        })
    }
}