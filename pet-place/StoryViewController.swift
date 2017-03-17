//
//  StoryViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 15..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class StoryViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate, StoryTableViewCellProtocol {
    
    var StoryArray: [Story] = []
    
    var itemInfo: IndicatorInfo = "Story"
    
    @IBOutlet weak var tableView: LoadingTableView!
    
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
    
    override func viewDidLoad() {
        tableView.showLoadingIndicator()
        
        // height setting 
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableViewAutomaticDimension
        
        super.viewDidLoad()
        
        StoryDownloadManager().downloadStory(nil) { (array, error) in
            if error == nil {
                self.StoryArray = array!
                dump(self.StoryArray)
                self.tableView.reloadData()
                self.tableView.hideLoadingIndicator()
            } else {
                print("Server reported error on downloading Story: \(error?.description)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! StoryTableViewCell
        
        let story = StoryArray[indexPath.row]
        story.commentNumbers = story.comments.count
        cell.delegate = self
        
        // tag 설정 
        // 프로필 이름 및 이미지 - 태그 0 
        // 라이크 버튼 - 태그 1, 코멘트 버튼 - 태그 2, 공유 버튼 - 태그 3
        // 라이크 개수 - 태그 4, 코멘트 개수 - 태그 5
        // indexPath.row + 태그 숫자로 숫자를 조합 0,1,2,3,4,5 / 10,11,12,13,14,15 / 20,21,22,23,24,25 등
        
        cell.nicknameLabel.tag = (indexPath.row*10)+0
        cell.profileImageView.tag = (indexPath.row*10)+0
        
        cell.likeButton.tag = (indexPath.row*10)+01
        cell.commentButton.tag = (indexPath.row*10)+02
        cell.shareButton.tag = (indexPath.row*10)+03
        cell.likeNumberLabel.tag = (indexPath.row*10)+04
        cell.commentNumberLabel.tag = (indexPath.row*10)+05
        
        // 프로필 이미지랑 닉네임 설정
        if let user = story.writer {
            let nickname = user.getProperty("nickname") as! String
            cell.nicknameLabel.text = nickname
            
            if let profileURL = user.getProperty("profileURL") {
                if profileURL is NSNull {
                    cell.profileImageView.image = #imageLiteral(resourceName: "user_profile")
                } else {
                    let url = URL(string: profileURL as! String)
                    cell.profileImageView.hnk_setImage(from: url)
                }
            }
        }
        
        // 라이크버튼 설정
        checkLike(indexPath.row) { (success) in
            if success {
                // 어떤 스토리를 좋아했다면
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
            } else {
                // 좋아했던 스토리가 아니라면
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
            }
        }
        
        cell.bodyTextLabel.text = story.bodyText
        cell.likeNumberLabel.text = String(story.likeNumbers) + "개의 좋아요"
        cell.commentNumberLabel.text = String(story.commentNumbers) + "개의 리플"
        
        
        if let imageLink = story.imageArray {
            let imageArray = imageLink.components(separatedBy: ",").sorted()
            cell.photoList = imageArray
        }
        
        cell.timeLabel.text = dateFormatter.string(from: story.created! as Date)
        
        return cell
    }
    
    // MARK: - Interation Handling
    // 프로필 이름 및 이미지 - 태그 0
    // 라이크 버튼 - 태그 1, 코멘트 버튼 - 태그 2, 공유 버튼 - 태그 3
    // 라이크 개수 - 태그 4, 코멘트 개수 - 태그 5
    // indexPath.row + 태그 숫자로 숫자를 조합, 10으로 나눈 숫자가 indexPath.row / 나머지가 태그
    
    func actionTapped(tag: Int) {
        let row = tag/10
        let realTag = tag%10
        
        switch realTag {
            case 0:
                print("Move to Profile View")
            case 1:
                print("Like Button Clicked")
                // 라이크 변경 함수 콜 - changeLike
                changeLike(row, completionHandler: { (success) in
                    if success {
                        self.tableView.reloadData()
                    } else {
                        print("Like Change has failed")
                    }
                })
            case 2:
                print("Comment Button Clicked")
                // 공유 액션
                performSegue(withIdentifier: "showComments", sender: row)
            case 3:
                print("Share Button Clicked")
                // 공유 액션
            case 4:
                print("Show Like Users: \(row)")
                // 좋아하는 유저들 보여주기
            case 5:
                print("Show Comments: \(row)")
                performSegue(withIdentifier: "showComments", sender: row)
            default:
                print("Some other action")
        }
    }
    
    // 라이크가 체크되어있는지를 확인
    func checkLike(_ row: Int, completionHandler: @escaping (_ success: Bool) -> Void) {

        let userID = Backendless.sharedInstance().userService.currentUser.objectId
        let selectedStoryID = StoryArray[row].objectId
        var isLike = false
        
        let dataStore = Backendless.sharedInstance().data.of(Story.ofClass())
        dataStore?.findID(selectedStoryID, response: { (response) in
            let selectedStory = response as! Story
            let likeUsers = selectedStory.likeUsers
            
            for likeUser in likeUsers {
                if likeUser.objectId == userID {
                    isLike = true
                    completionHandler(isLike)
                }
            }
            completionHandler(isLike)
            
        }, error: { (Fault) in
            print("Server reported an error: \(Fault?.description)")
        })
    }
    
    /** 
       라이크를 변경, 현재 상태를 확인하고 라이크 개수 변경
     : param: row 어떤 스토리인지 확인이 가능하고 나중에 reload를 위한 parameter
     : param: completionHandler
    */

    func changeLike(_ row: Int, completionHandler: @escaping (_ success: Bool) -> Void) {
        print("Change like")
        let selectedStory = StoryArray[row]
        
        let likeNumber = selectedStory.likeNumbers
        
        // 그냥 유저 객체로 비교는 안되고 objectId로 체크를 해야 함
        let objectID = Backendless.sharedInstance().userService.currentUser.objectId
        
        let dataStore = Backendless.sharedInstance().data.of(Story.ofClass())
        
        checkLike(row) { (success) in
            if success {        // 좋아요를 이미 누른 경우 - 취소가 됨
                selectedStory.likeNumbers = likeNumber-1
                
                for (index, _) in selectedStory.likeUsers.enumerated() {
                    if selectedStory.likeUsers[index].objectId == objectID {
                        selectedStory.likeUsers.remove(at: index)
                        break
                    }
                }
                
                dataStore?.save(selectedStory, response: { (response) in
                    let story = response as! Story
                    print("Successfully like deleted: \(story.likeNumbers)")
                    completionHandler(true)
                }, error: { (Fault) in
                    print("Server reported an error on update Like: \(Fault?.description)")
                    completionHandler(false)
                })
                
            } else {            // 아직 좋아요를 누르지 않은 경우 - 좋아요가 추가가 됨
                selectedStory.likeNumbers = likeNumber+1
                selectedStory.likeUsers.append(Backendless.sharedInstance().userService.currentUser)
                
                dataStore?.save(selectedStory, response: { (response) in
                    let story = response as! Story
                    print("Successfully like added: \(story.likeNumbers)")
                    completionHandler(true)
                }, error: { (Fault) in
                    print("Server reported an error on update Like: \(Fault?.description)")
                    completionHandler(false)
                })
            }
        }
    }
    
    // MARK: - Segue 
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ) {
        if segue.identifier == "showComments" {
            let index = sender as! Int
            let destinationVC = segue.destination as! CommentViewController
            destinationVC.selectedStory = StoryArray[index]
            print("Selected Story: \(index)")
        }
    }
    
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
