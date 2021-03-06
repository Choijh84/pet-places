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
    
    var backendless = Backendless.sharedInstance()
    
    /// Store object that handles downloading of Reviews
    let dataStore = Backendless.sharedInstance().data.of(Review.self)
    
    /**
     Uploads a new review, 단수의 이미지를 업로드하는 함수
     */
    func uploadNewReview(_ text: String, selectedFile: UIImage?, rating: NSNumber, store: Store, completionBlock: @escaping (_ completed: Bool, _ store: Store?, _ errorMessage: String?)->()) {
        if let selectedFile = selectedFile {
            let fileName = String(format: "%0.0f.jpeg", Date().timeIntervalSince1970)
            let filePath = "reviewImages/\(fileName)"
            let content = UIImageJPEGRepresentation(selectedFile.compressImage(selectedFile), 1.0)
            
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
    리뷰의 사진을 업로드하는 함수, completionBlock을 통해 fileURL 문자열을 return 함
     */
    func uploadPhotos(selectedImages: [UIImage]?, completionBlock: @escaping (_ completion: Bool, _ fileURL: String, _ errorMessage: String?) -> ()) {
        var totalFileURL = ""
        let myGroup = DispatchGroup()
        
        if let images = selectedImages {
            for var i in 0..<images.count {
                myGroup.enter()
                let fileName = String(format: "%0.0f\(i).jpeg", Date().timeIntervalSince1970)
                let filePath = "reviewImages/\(fileName)"
                let content = UIImageJPEGRepresentation(images[i], 1.0)
                
                Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
                    let fileURL = uploadedFile?.fileURL
                    totalFileURL.append(fileURL!+",")
                    i = i+1
                    myGroup.leave()
                }, error: { (fault) in
                    completionBlock(false, "", fault?.description)
                })
            }
            myGroup.notify(queue: DispatchQueue.main, execute: { 
                let finalURL = String(totalFileURL.characters.dropLast())
                completionBlock(true, finalURL, nil)
            })
        }
    }
    
    /**
     Uploads a new review, 파일 url(단수 또는 복수일 수도 있음)
     
     - parameter text:            리뷰 본문
     - parameter fileURL:         ','로 구분되는 url를 업로드하는 파라미터
     - parameter rating:          리뷰 평점
     - parameter store:           리뷰의 대상이 되는 store object
     - parameter completionBlock: called after the review has been uploaded
     - parameter error:           error if any
     */
    func uploadNewReview(_ text: String, fileURL: String?, rating: NSNumber, store: Store, completionBlock: @escaping (_ completed: Bool, _ store: Store?, _ errorMessage: String?) -> ()) {
        let review = Review()
        review.rating = rating
        review.text = text
        review.fileURL = fileURL
        review.creator = UserManager.currentUser()
        
        store.reviewCount = (store.reviews.count+1)
        store.reviews.append(review)
        
        var error: Fault?
        let result = Backendless.sharedInstance().data.save(store, error: &error) as? Store
        if error == nil {
            print("Review havs been updated: \(result)")
            completionBlock(true, result, nil)
        } else {
            print("Server reported an error: \(error)")
            completionBlock(false, nil, error?.description)
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
    
    func downloadReviewCountAndReviewByPage(skippingNumberOfObject skip: NSNumber, limit: NSNumber, storeObject: Store, completionBlock: @escaping (_ reviews: [Review]?, _ error: String?) -> ()) {
        let dataQuery = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        
        queryOptions.sortBy = ["created desc"]
        queryOptions.pageSize = limit
        queryOptions.offset = skip
        dataQuery.queryOptions = queryOptions
        
        dataQuery.whereClause = "Store[reviews].objectId = \'\(storeObject.objectId!)\'"
        
        dataStore?.find(dataQuery, response: { (collection) in
            completionBlock(collection?.data as? [Review], nil)
        }, error: { (Fault) in
            print(Fault?.description ?? "Error")
            completionBlock(nil, Fault?.description)
        })
        
    }
    
    /**
     리뷰를 지역별로 다운로드 받을 수 있게 하는 함수
     */
    func downloadReview(_ location: String?, _ completionBlock: @escaping (_ review: [Review]?, _ errorMessage: NSString?) -> Void) {
        let query = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        
        // 이건 파라미터에 위치가 정해져서 
        if let location = location {
            query.whereClause = "Review[location] = \'\(location)\'"
        }
        
        // sort option = 만들어진 시간 순 - 향후 업데이트 순으로 바꿔야할 수도....
        queryOptions.sortBy = ["created desc"]
        query.queryOptions = queryOptions
        
        dataStore?.find(query, response: { (collection) in
            completionBlock((collection?.data as? [Review]), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
    }
    
    /**
     지역 리뷰를 페이지로 나눠서 받을 수 있게 해주는 함수
     : param: skippingNumberOfObjects, skip 스킵할 객체의 숫자, 이미 다운로드 받은 수
     : param: location, 향후 위치가 정해지면 쿼리에 반영
     : param: limit: 다운로드 받을 객체의 수 
     : param: completionBlock
    */
    func downloadReviewPage(skippingNumberOfObects skip: NSNumber, location: String?, limit: NSNumber, _ completionBlock: @escaping (_ review: [Review]?, _ errorMessage: String?) -> Void) {
        let dataQuery = BackendlessDataQuery()
        let queryOption = QueryOptions()
        
        // 향후 위치가 정해지는 쿼리를 하는 경우
        if let location = location {
            dataQuery.whereClause = "Review[location] = \'\(location)\'"
        }
        
        queryOption.sortBy = ["created desc"]
        queryOption.pageSize = limit
        queryOption.offset = skip
        dataQuery.queryOptions = queryOption
        
        dataStore?.find(dataQuery, response: { (collection) in
            completionBlock(collection?.data as? [Review], nil)
        }, error: { (Fault) in
            print(Fault ?? "There is an error dowloading review list")
            completionBlock(nil, Fault?.description)
        })
    }
}
