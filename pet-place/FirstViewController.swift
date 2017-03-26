//
//  FirstViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 20..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// 처음에 앱 실행할 때 애니메이션 보여주는 
class FirstViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyLabel.alpha = 0.0
        titleLabel.alpha = 0.5
//        let centerPoint = titleLabel.center
//        
//        UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseInOut, animations: { 
//            self.titleLabel.alpha = 0
//        }) { (true) in
//            self.newText()
//        }
//        
        UIView.animate(withDuration: 3.0, delay: 0.5, options: .curveEaseIn, animations: {
//            self.imageView.center = CGPoint(x: centerPoint.x+200, y: centerPoint.y)
            self.titleLabel.alpha = 1.0
            self.bodyLabel.alpha = 1.0
        }) { (true) in
            self.goNext()
        }
        
    }
    
    func goNext() {
        UIView.animateKeyframes(withDuration: 0, delay: 1, options: .calculationModeCubicPaced, animations: { 
            self.performSegue(withIdentifier: "goToMain", sender: nil)
        }, completion: nil)
    }
    
    func newText() {
        UIView.animate(withDuration: 1.5) { 
            self.bodyLabel.alpha = 1.0
        }
    }

}
