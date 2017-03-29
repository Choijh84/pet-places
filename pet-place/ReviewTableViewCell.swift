//
//  ReviewTableViewCell.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView

/// TableViewCell that displays all the reviews
class ReviewTableViewCell: UITableViewCell {

    /// Label to display the body of the review
    @IBOutlet weak var reviewTextLabel: UILabel!
    /// Label to display the date
    @IBOutlet weak var dateLabel: UILabel!
    /// View to display the rating of the review
    @IBOutlet weak var ratingView: HCSStarRatingView!
    /// ImageView that displays the image of the review if any
    @IBOutlet weak var reviewImageView: UIImageView!
    /// Width constraint for the reviewImageView so it can be adjusted according to the review's image. If there isn't any, than we hide the imageView completely, by setting the constraint to be 0
    @IBOutlet weak var reviewImageViewWidthConstraint: NSLayoutConstraint!

    /**
     Sets the review's rating to the ratingView

     - parameter rating: the rating to display
     */
    func setRating(_ rating: NSNumber) {
        ratingView.value = CGFloat(rating.floatValue)
    }

    /**
     Set the separator to be full width
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
    }

    /**
     Hides the reviewImageView if the value is true. Setting the reviewImageViewWidthConstraint to be zero

     - parameter hidden: if true, it hides the reviewImageView
     */
    func setReviewImageViewHidden(_ hidden: Bool) {
        if hidden == true {
            reviewImageViewWidthConstraint.constant = 0
            layoutIfNeeded()
        } else {
            reviewImageViewWidthConstraint.constant = 75.0
            layoutIfNeeded()
        }
    }

    /**
    Set the separator to be full width as the layout size changes
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets.zero
    }
}
