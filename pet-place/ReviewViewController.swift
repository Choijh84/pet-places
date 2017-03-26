//
//  ReviewViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SCLAlertView

/// 스토리리뷰에서 리뷰 파트를 보여주는 뷰컨트롤러
class ReviewViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate  {
    
    // 지역 선택하는 뷰
    @IBOutlet weak var locationView: UIView!
    // 지역 선택하는 버튼과 라벨
    @IBOutlet weak var locationSelectButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    // 지역 보여주는 뷰
    @IBOutlet weak var locationShowView: UIView!
    @IBOutlet weak var locationCollectionView: UICollectionView!
    var isShowing: Bool = false
    
    // 지역 선택할 수 있게 하는 배열
    let locations = ["모두 보기", "서울 강북", "서울 강남", "인천", "대구", "부산", "제주", "대전", "광주", "울산", "세종", "강원도", "경상도", "전라도", "충청도"]
    
    // 선택된 지역 
    var selectedLocation: String?
    
    // 리뷰 보여주는 테이블뷰
    @IBOutlet weak var tableView: LoadingTableView!
    
    // 리뷰 저장하는 배열
    var ReviewArray: [Review] = []
    // 리뷰에 해당되는 장소들을 불러와서 이 배열에 저장할 생각인데...
    var StoreArray: [Store] = []
    
    /// 리뷰를 다운로드하고 있으면 true
    var isLoadingItems: Bool = false
    
    /// Refreshcontrol to show a loading indicator and a pull to refresh view, when the view is loading content
    var refreshControl: UIRefreshControl!
    
    var itemInfo: IndicatorInfo = "지역 리뷰"
    
    /// Lazy getter for the dateformatter that formats the date property of each review to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }()
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    // 지역 선택하는 버튼
    @IBAction func locationSelection(_ sender: Any) {
        if isShowing == false {
            UIView.animate(withDuration: 0.5) {
                self.locationShowView.alpha = 1.0
                self.tableView.alpha = 0.1
            }
            isShowing = true
            self.tableView.isUserInteractionEnabled = false
            print("선택된 장소: \(selectedLocation)")
        } else {
            UIView.animate(withDuration: 0.5) {
                self.locationShowView.alpha = 0.0
                self.tableView.alpha = 1.0
            }
            isShowing = false
            self.tableView.isUserInteractionEnabled = true
            print("선택된 장소: \(selectedLocation)")
        }
    }
    
    override func viewDidLoad() {
        tableView.showLoadingIndicator()
        
        // height setting
        tableView.estimatedRowHeight = 550
        tableView.rowHeight = UITableViewAutomaticDimension
        
        customizeViews()
        
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.downloadReviews()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    /**
     초기에 리뷰를 다운로드 하는 함수, 아직 로케이션 처리는 안됨
     - 처음 다운로드 하므로 데이터 배열을 초기화하고 시작, 추가 다운로드는 downloadMoreReviews에서 처리
    */
    func downloadReviews() {
        isLoadingItems = true
        refreshControl.beginRefreshing()
        tableView.showLoadingIndicator()

        // 배열 초기화
        ReviewArray.removeAll()
        
        // 향후에 파라미터로 로케이션이 들어가면 쿼리가 되어야 함
        
        ReviewManager().downloadReviewPage(skippingNumberOfObects: 0, location: nil, limit: 10) { (reviews, error) in
            self.isLoadingItems = false
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
            } else {
                if let reviews = reviews {
                    self.ReviewArray.append(contentsOf: reviews)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        self.refreshControl.endRefreshing()
        self.tableView.hideLoadingIndicator()
    }
    
    func downloadMoreReviews() {
        isLoadingItems = true
        self.refreshControl.beginRefreshing()
        self.tableView.showLoadingIndicator()
        
        // 이미 다운로드 받은 리뷰의 숫자
        let temp = ReviewArray.count as NSNumber
        
        ReviewManager().downloadReviewPage(skippingNumberOfObects: temp, location: nil, limit: 10) { (reviews, error) in
            if let error = error {
                self.showAlertViewWithRedownloadOption(error)
            } else {
                if let reviews = reviews {
                    self.ReviewArray.append(contentsOf: reviews)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        self.refreshControl.endRefreshing()
        self.tableView.hideLoadingIndicator()
    }
    
    /**
    사용자가 스크롤을 70% 이상 내리면 추가로 리뷰를 다운로드 - loadMoreReviews
    */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.height
        if endScrolling >= (scrollView.contentSize.height*0.7) && !isLoadingItems && ReviewArray.count >= 10 {
            self.downloadMoreReviews()
        }
    }
    
    /**
     다운로드에 문제가 있다는 것을 알려주는 함수
     */
    func showAlertViewWithRedownloadOption(_ error: String) {
        let alert = SCLAlertView()
        alert.addButton("확인") {
            print("확인 완료")
        }
        alert.addButton("다시 시도") {
            self.downloadReviews()
        }
        alert.showError("에러 발생", subTitle: "다운로드에 문제가 있습니다")
    }
    
    /**
     Customize the tableview's look and feel
     */
    func customizeViews() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = .separatorLineColor()
        
        locationShowView.alpha = 0.0
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .globalTintColor()
        refreshControl.addTarget(self, action: #selector(ReviewViewController.downloadReviews), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    // MARK: - Tableview DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReviewArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StoryReviewTableViewCell
        
        let review = ReviewArray[indexPath.row]
        
        // 프로필 이미지랑 닉네임 설정
        if let user = review.creator {
            let nickname = user.getProperty("nickname") as! String
            cell.profileName.text = nickname
            
            if let profileURL = user.getProperty("profileURL") {
                if profileURL is NSNull {
                    cell.profileImage.image = #imageLiteral(resourceName: "user_profile")
                } else {
                    let url = URL(string: profileURL as! String)
                    cell.profileImage.hnk_setImage(from: url)
                }
            }
        } else {
            //  삭제된 유저의 경우
            cell.profileName.text = "탈퇴 유저"
            cell.profileImage.image = #imageLiteral(resourceName: "user_profile")
        }
        
        // 스토어 이름을 쿼리를 해와야되는거 같다... 따로 StoreArray를 만들어야 하나?
        cell.storeName.text = "가게 이름"
        // 리뷰 평점 배당
        cell.ratingView.value = review.rating as CGFloat
        
        // 리뷰 바디
        cell.reviewBody.text = review.text
        
        // cell.likeNumberLabel.text = String(story.likeNumbers) + "개의 좋아요"
        // cell.commentNumberLabel.text = String(story.commentNumbers) + "개의 리플"
        
        if let string = review.fileURL {
            cell.photoList = string.components(separatedBy: ",").sorted()
            cell.collectionView.reloadData()
        } else {
            cell.collectionView.isHidden = true
            cell.pageControl.isHidden = true
        }
        
        cell.timeLabel.text = dateFormatter.string(from: review.created! as Date)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

extension ReviewViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK - CollectionView Method
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationCell", for: indexPath) as! ReviewLocationCollectionViewCell
        
        cell.locationLabel.text = locations[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            self.locationShowView.alpha = 0.0
            self.tableView.alpha = 1.0
        }
        isShowing = false
        self.tableView.isUserInteractionEnabled = true
        selectedLocation = locations[indexPath.row]
        locationLabel.text = selectedLocation
    }
}

