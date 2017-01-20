//
//  Review.swift
//  Pet-Hotels
//
//  Created by Owner on 2016. 12. 25..
//  Copyright © 2016년 TwistWorld. All rights reserved.
//

import UIKit

 /// Review object that contains all the properties of a Store's review
class Review: NSObject {

    var objectId: String?
    /// body of the review
    var text: String!
    /// rating of the review (1-5)
    var rating: NSNumber!
    /// when the review was created
    var created: Date!
    /// Creator of the review
    var creator: BackendlessUser?
    /// Image url of the review
    var fileURL: String?
}
