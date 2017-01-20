//
//  SortingOption.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation

enum SortingKey: String {
    case name = "name"
    case distance = "distance"
    case rating = "reviewAverage"
}

/// Sorting option object
class SortingOption: NSObject {
    
    /// Name of the sorting option
    var name: String?
    /// Key for the sorting
    var sortingKey: SortingKey?
    
    /**
     Initialises a new SortingOption with name and sortingKey
     
     - parameter name: name of the sorting
     - parameter sortingKey: key of the sorting
     
     - returns: SortingObject
     */
    init(name: String, sortingKey: SortingKey) {
        self.name = name
        self.sortingKey = sortingKey
        super.init()
    }
    
}
