//
//  HomeViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class FrontPromotion: NSObject {
    
    /// ID
    var objectId: String?
    /// description
    var descriptionText: String?
    /// imageURL
    var imageURL: String!
    /// linked URL 
    var url: String?
}

class Recommendations: NSObject {
    
    /// ID
    var objectId: String?
    /// Reference
    var store: Store!
}

class HomeViewController: UITableViewController {
    
    @IBOutlet var tableInsideHome: LoadingTableView!
    
    var promotions = [FrontPromotion]()
    var recommendStores = [Recommendations]()
    
    var isShowBusinessInfo = false
    var reloadIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PET CITY HOME"
        
        downloadFrontPromotions()
        downloadRecommendations()
        
    }
    
    /**
     Downloads all the FrontPromotion objects
     */
    func downloadFrontPromotions() {
        self.tableInsideHome.showLoadingIndicator()
        let download = HomeDownloadManager()
        download.downloadFrontPromotions { (promotions, errorMessage) in
            DispatchQueue.main.async(execute: { 
                if let errorMessage = errorMessage {
                    let alertView = UIAlertController(title: "Error", message: errorMessage as String, preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) in
                        self.downloadFrontPromotions()
                    }))
                    self.present(alertView, animated: true, completion: nil)
                } else {
                    if let promotions = promotions {
                        print("promotion download done: \(promotions)")
                        self.promotions = promotions
                    }
                    self.tableInsideHome.reloadData()
                    self.tableInsideHome.hideLoadingIndicator()
                }
            })
        }
    }

    /**
     Downloads all the Recommendations objects
     */
    func downloadRecommendations() {
        self.tableInsideHome.showLoadingIndicator()
        let download = HomeDownloadManager()
        download.downloadRecommendStores { (recommends, errorMessage) in
            DispatchQueue.main.async(execute: { 
                if let errorMessage = errorMessage {
                    let alertView = UIAlertController(title: "Error", message: errorMessage as String, preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) in
                        self.downloadRecommendations()
                    }))
                    self.present(alertView, animated: true, completion: nil)
                } else {
                    if let recommends = recommends {
                        self.recommendStores = recommends
                    }
                    self.tableInsideHome.reloadData()
                    self.tableInsideHome.hideLoadingIndicator()
                    
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /// Recommendation Places Tap Segue
        if segue.identifier == "showDetailStoreSegue" {
            if let collectionCell: StoreCollectionViewCell = sender as? StoreCollectionViewCell {
                let indexPath = collectionCell.tag
                    if let destination = segue.destination as? StoreDetailViewController {
                        destination.storeToDisplay = recommendStores[indexPath].store
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoRow", for: indexPath) as! PhotoRow
            cell.photoList = promotions
            cell.promotionCollection.reloadData()
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderRow", for: indexPath) as! HeaderRow
            cell.title.text = "추천 장소"
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceRow", for: indexPath) as! PlaceRow
            
            cell.storeList = recommendStores
            cell.placeCollection.reloadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessInfoRow", for: indexPath) as! BusinessInfoRow
            
            reloadIndexPath = indexPath
            
            /// detail business info 보여주기/숨기기
            cell.businessInfoShowButton.addTarget(self, action: #selector(HomeViewController.showBusinessInfo), for: .touchUpInside)
            
            if isShowBusinessInfo == false {
                cell.businessInfoStack.isHidden = true
                cell.businessInfoShowButton.setTitle("사업자 정보 보기", for: .normal)
            } else {
                cell.businessInfoShowButton.setTitle("사업자 정보 숨기기", for: .normal)
                UIView.animate(withDuration: 0.3, animations: { 
                    cell.businessInfoStack.isHidden = false
                })
            }

            return cell
        }
    }
    
    func showBusinessInfo() {
        isShowBusinessInfo = !isShowBusinessInfo
         self.tableView.reloadRows(at: [reloadIndexPath!], with: .automatic)
    }
    
    /**
        Tableview Height setting function
        - parameter: tableView
        - parameter: indexPath
        row 0: 프로모션 이미지 place, row 1: 헤더, row 2: 추천 장소 콜렉션뷰 높이 계산
     */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 250
        } else if (indexPath.row == 1) {
            return 40
        } else if (indexPath.row == 2) {
            let number = ceil(Double(recommendStores.count/2))+1
            print("This is collectionView Height: \(200*number)")
            return CGFloat(200*number)
        } else {
            if isShowBusinessInfo == false {
                return 150
            } else {
                return 200
            }
        }
    }
    
    /**
     Set the navigation bar visible
     
     - parameter animated: animated
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    /**
     Which statusbar style to display, white in this case.
     
     - returns: White statusbar.
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
