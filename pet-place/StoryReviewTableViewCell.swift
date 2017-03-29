//
//  StoryReviewTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 22..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import HCSStarRatingView
import SKPhotoBrowser

class StoryReviewTableViewCell: UITableViewCell {

    var photoList = [String]()
    var selectedReview = Review()
    
    // 이미지 표시하는 콜렉션뷰
    @IBOutlet weak var collectionView: UICollectionView!
    
    // 프로필 이미지와 닉네임
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    // 리뷰 평점 표시
    @IBOutlet weak var ratingView: HCSStarRatingView!
    
    // 스토어 이름
    @IBOutlet weak var storeName: UILabel!
    // 리뷰 입력 시간
    @IBOutlet weak var timeLabel: UILabel!
    // 리뷰 본문
    @IBOutlet weak var reviewBody: UILabel!
    
    // 좋아요와 댓글 개수
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    // 페이지 컨트롤
    @IBOutlet weak var pageControl: UIPageControl!
    // 신고 버튼
    @IBOutlet weak var moreButton: UIButton!
    // 좋아요 버튼
    @IBOutlet weak var likeButton: UIView!
    // 댓글 버튼
    @IBOutlet weak var replyButton: UIButton!
    // 공유 버튼
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Initialization
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 페이지컨트롤 한개의 사진이면 안 보이게
        pageControl.hidesForSinglePage = true
        pageControl.layer.cornerRadius = 10.0
        
        // 이미지뷰 원형 모양으로
        profileImage.layer.cornerRadius = profileImage.layer.frame.width/2
    }
}

extension StoryReviewTableViewCell : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    // MARK: Collectionview Method
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.pageControl.numberOfPages = photoList.count
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath) as! StoryReviewPhotoCollectionViewCell
        
        DispatchQueue.global().async { 
            let imageURL = self.photoList[indexPath.row]
            let url = URL(string: imageURL)
            DispatchQueue.main.async {
                cell.imageView.hnk_setImage(from: url)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.layer.frame.width
        return CGSize(width: width, height: width*0.9)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.pageControl.currentPage = indexPath.row
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileName.text = nil
        profileImage.image = #imageLiteral(resourceName: "user_profile")
        storeName.text = "가게 이름"
        timeLabel.text = "계산 필요"
        reviewBody.text = "로딩 필요"
        collectionView.isHidden = false
        pageControl.numberOfPages = 1
    }
}
