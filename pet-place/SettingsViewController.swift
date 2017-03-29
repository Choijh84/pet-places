//
//  SettingsViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 29..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

// 환경설정 뷰 컨트롤러
class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var pushSetting: UISwitch!
    
    @IBOutlet weak var SMSSetting: UISwitch!
    
    @IBOutlet weak var emailSetting: UISwitch!
    
    @IBOutlet weak var autoLoginSetting: UISwitch!
    
    // 저장 변수
    var isPush = false
    var isSMS = false
    var isEmail = false
    var isAutoLogin = false
    
    // 뷰를 불러오면서 현재 설정만 체크해서 변수에 저장
    override func viewDidLoad() {
        super.viewDidLoad()

        // 유저 설정 불러오기
        let user = Backendless.sharedInstance().userService.currentUser
        
        // getproperty is now working 우아아아아 열받아 우아아아아아아
        isSMS = user?.getProperty("isSMSReceive") as! Bool
        isEmail = user?.getProperty("isEmailReceive") as! Bool
        isAutoLogin = Backendless.sharedInstance().userService.isStayLoggedIn
        print("This is SMS: \(isSMS) and Email: \(isEmail) and AutoLogin: \(isAutoLogin)")
        
        // 아래 셀 지우기
        tableView.tableFooterView = UIView(frame: .zero)
        
    }
    
    // 뷰가 없어질 때 변경사항만 확인해서 저장시키자
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let user = Backendless.sharedInstance().userService.currentUser
        print("this is user name: \(user?.name)")
    }


    /// MARK: - TableView Controller Methods
    
    // 테이블뷰 선택했을 때, 세부사항으로 이동하게 만들어주는 함수
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This is indexPath: \(indexPath)")
        
        if indexPath == [2,0] {
            // 서비스 약관 선택
            
        } else if indexPath == [4,0] {
            // 개발 정보 선택
            
        }
    }
    
    // 테이블 헤더 섹션 높이 설정 함수
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // 테이블 헤더 폰트 및 사이즈 설정 함수
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "YiSunShin Dotum M", size: 15.0)
        header.textLabel?.textColor = UIColor.lightGray
    }

}
