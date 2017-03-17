//
//  CommentTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 17..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    // 생략하자
    @IBOutlet weak var likeButton: UIButton!
    // 편집과 삭제 버튼은 본인의 스토리에만 노출되게
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBAction func editComment(_ sender: Any) {
        
    }
    
    @IBAction func deleteComment(_ sender: Any) {
        
    }
    
    
    // 라이크버튼 눌렀을 때 - 생략하자
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        // print("Like Button Clicked: \(likeButton.tag)")
        
        // 좋아하는 스토리인지 아닌지를 구분
        // 버튼의 이미지 변경 - 클릭하면 이미지 바뀌게
        // 좋아요를 눌렀을 때
        if sender.image(for: .normal) == #imageLiteral(resourceName: "like_bw") {
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_red"), for: .normal)
            }, completion: nil)
        } else {
            // 좋아요를 취소할 때
            UIView.transition(with: sender, duration: 0.5, options: .transitionCrossDissolve, animations: {
                sender.setImage(#imageLiteral(resourceName: "like_bw"), for: .normal)
            }, completion: nil)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}