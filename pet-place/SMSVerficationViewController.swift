//
//  SMSVerficationViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 10..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class SMSVerficationViewController: UIViewController {

    // 핸드폰 번호 입력 라벨
    @IBOutlet weak var phoneNumberField: UITextField!
    // 인증번호 입력 하벨
    @IBOutlet weak var verificationField: UIStackView!
    // 남은 시간 라벨
    @IBOutlet weak var remainingTimeLabel: UILabel!
    // 시간 표시 라벨
    @IBOutlet weak var remainingTime: UILabel!
    // 휴대폰 번호 중복 경고 라벨
    @IBOutlet weak var overlapMessageLabel: UILabel!
    
    // 번호 전송 요청
    @IBAction func verificationRequest(_ sender: Any) {
        // 랜덤번호 6자리 생성
        // 랜덤번호 중복 여부 체크
        // 서버에 핸드폰 번호 중복 여부 체크 - 중복이면 중복 메세지 보여주기
        // 중복이 아니면 발송
        // 발송 여부 알람창 표시
    }
    
    // 인증 요청
    @IBAction func verificationTry(_ sender: Any) {
        // 번호 매칭 & 시간 여부 확인
        // 매칭 되면 핸드폰 번호 인증 
        // 서버 사용자 정보에 업데이트
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 아래 메세지 라벨들은 우선 숨김
        remainingTimeLabel.isHidden = true
        remainingTime.isHidden = true
        overlapMessageLabel.isHidden = true
    }


}
