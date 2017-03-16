//
//  StoryDownloadManager.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class StoryDownloadManager: NSObject {

    /// Store object that handles downloading of Story objects
    let dataStore1 = Backendless.sharedInstance().persistenceService.of(Story.self)
    /// Store object that handles downloading of Comment objects
    let dataStore2 = Backendless.sharedInstance().persistenceService.of(Comment.self)
    
    /**
     Downloads all the Story objects
     
     */
    func downloadStory(_ user: BackendlessUser?, _ completionBlock: @escaping (_ story: [Story]?, _ errorMessage: NSString?) -> Void) {
        let query = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        
        let dataQuery = BackendlessDataQuery()
        // 이건 파라미터에 유저가 있어서 그 유저의 스토리만 불러 들일 때 - 마이스토리에 사용
        if let user = user {
            dataQuery.whereClause = "writer = \'\(user)\'"
        }
        
        // sort option = 만들어진 시간 순 - 향후 업데이트 순으로 바꿔야할 수도....
        queryOptions.sortBy = ["created desc"]
        
        dataStore1?.find(query, response: { (collection) in
            completionBlock((collection?.data as! [Story]), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
    }
    
    /**
     Downloads all the Comments Objects
     
     :param: story - which Story links with the comments
     :param: completionBlock called after the request finished, returns the comment array and an errorMessage if any
     :param: errorMessage errorMessage to return if any
     */
    
    func downloadComments(_ story: Story!, _ completionBlock: @escaping (_ categories: [Comment]?, _ errorMessage: NSString?) -> Void )  {
        let query = BackendlessDataQuery()
        let queryOptions = QueryOptions()
        
        let whereClause = "story.objectId = \'\(story.objectId)\'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        // sort option = 만들어진 시간 순 - 향후 업데이트 순으로 바꿔야할 수도....
        queryOptions.sortBy = ["created desc"]
        
        dataStore2?.find(query, response: { (collection) in
            let commentArray = collection?.data as! [Comment]
            completionBlock((commentArray), nil)
        }, error: { (Fault) in
            completionBlock(nil, Fault?.description as NSString?)
        })
    }
}
