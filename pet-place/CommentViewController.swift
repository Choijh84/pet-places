//
//  CommentViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 17..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import SCLAlertView

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CommentTableViewCellProtocol {

    var selectedStory = Story()
    
    var commentArray = [Comment]()
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var tableView: LoadingTableView!
    
    /// 코멘트 저장
    @IBAction func saveComment(_ sender: Any) {
        print("Let us save the comment")
        if let text = commentTextField.text {
            StoryDownloadManager().uploadNewComment(text, selectedStory, completionBlock: { (success, error) in
                if success {
                    self.commentTextField.resignFirstResponder()
                    self.commentTextField.text = ""
                    self.setUpCommentArray()
                } else {
                    SCLAlertView().showWarning("에러 발생", subTitle: "확인해주세요")
                }
            })
        } else {
            SCLAlertView().showWarning("입력 필요", subTitle: "코멘트를 입력해주세요")
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "코멘트"
        
        // height setting
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // tableView 아래 빈 셀들 separator 줄 안 보이게
        customizeViews()
        
        setUpCommentArray()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommentViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func setUpCommentArray() {
        tableView.showLoadingIndicator()

        commentArray = selectedStory.comments
        // 생성 시간으로 정렬
        commentArray = commentArray.sorted { (left, right) -> Bool in
            return left.created > right.created
        }
        
        tableView.reloadData()
        tableView.hideLoadingIndicator()
    }
    
    /**
     Customize the tableview's look and feel
     */
    func customizeViews() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = .separatorLineColor()
    }
    
    /// MARK: CommentTableViewCellProtocol
    func actionTapped(row: Int) {
        commentArray.remove(at: row)
        print("댓글이 삭제되어야 합니다")
        tableView.reloadData()
        
        // 데이터베이스에서도 삭제
    }
    
    /// Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /// MARK: - TableView Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentTableViewCell
        
        // 프로토콜 delegate 설정
        cell.delegate = self
        
        let comment = commentArray[indexPath.row]
        // Profile image
        if let profile = comment.writer.getProperty("profileURL") as? String {
            let url = URL(string: profile)
            DispatchQueue.main.async(execute: { 
                cell.profileImage.hnk_setImage(from: url)
            })
        } else {
            cell.profileImage.image = #imageLiteral(resourceName: "user_profile")
        }
        // name
        cell.nameLabel.text = comment.writer.name as String?
        // comment 
        cell.commentLabel.text = comment.bodyText
        // 시간은 그냥 작성된 시간 기준으로 - 편집 기능은 없앨 수도.... 
        let time = comment.created
        print("This is created time: \(time)")
        let timedifference = timeDifferenceShow(date: time!)
        cell.timeLabel.text = timedifference

        // 편집, 삭제 버튼에 tag 부여하기
        cell.editButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        
        // 편집 및 삭제 버튼, 아이디가 일치하면 보여주기
        if comment.writer.objectId != Backendless.sharedInstance().userService.currentUser.objectId {
            cell.editButton.isHidden = true
            cell.deleteButton.isHidden = true
        }
        
        // editButton - 생략, 아직 구현 안함
        cell.editButton.isHidden = true
        
        // likeButton - 생략, 아직 구현 안함
        cell.likeButton.isHidden = true
        
        return cell
    }
    
    // 테이블 각 row의 높이 자동 조절을 위한 함수 2개
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // 타임 포맷 함수
    func timeDifferenceShow(date: Date) -> String {
        
        // 현재 시각
        let date1:Date = Date()
        // 결과 전달을 위한 문자열 생성
        var returnString:String = ""
        
        // 디바이스에 있는 캘린더를 도입
        let calender:Calendar = Calendar.current
        // 시간 차이 계산 to-from
        let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: date1)
        
        print(components)
        print(components.second ?? "There is no value")
        
        if components.year! >= 1 {
            returnString = String(describing: components.year!)+" 년 전"
        } else if components.month! >= 1 {
            returnString = String(describing: components.month!)+" 달 전"
        } else if components.day! >= 1 {
            returnString = String(describing: components.day!) + " 일 전"
        } else if components.hour! >= 1 {
            returnString = String(describing: components.hour!) + " 시간 전"
        } else if components.minute! >= 1 {
            returnString = String(describing: components.minute!) + " 분 전"
        } else {
            returnString = "방금 올림"
        }
        return returnString
    }
}
