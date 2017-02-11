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
    var recommendStore: Store!
}

class HomeViewController: UITableViewController {
    
    @IBOutlet var tableInsideHome: LoadingTableView!
    
    var promotions = [FrontPromotion]()
    var recommend = [Recommendations]()
    
    @IBOutlet weak var promotionCollection: UICollectionView!
    @IBOutlet weak var placeCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PET CITY HOME"
        
        downloadFrontPromotions()
//        downloadRecommendations()
        
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
        download.downloadRecommendStores { (recommend, errorMessage) in
            DispatchQueue.main.async(execute: { 
                if let errorMessage = errorMessage {
                    let alertView = UIAlertController(title: "Error", message: errorMessage as String, preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alertView.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (alertAction) in
                        self.downloadRecommendations()
                    }))
                    self.present(alertView, animated: true, completion: nil)
                } else {
                    if let recommend = recommend {
                        print("recommend download done: \(recommend)")
                        self.recommend = recommend
                    }
                    self.tableInsideHome.reloadData()
                    self.tableInsideHome.hideLoadingIndicator()
                    
                }
            })
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceRow", for: indexPath) as! PlaceRow
            cell.storeList = recommend
            cell.placeCollection.reloadData()
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 250
        } else if (indexPath.row == 1) {
            return 40
        } else if (indexPath.row == 2) {
            let number = 5
            if number%2==0 {
                return CGFloat(180*(number/2))
            } else {
                let multi = Double(number/2) + 1
                return CGFloat(180*multi)
            }
        } else {
            return 300
        }
    }
}
