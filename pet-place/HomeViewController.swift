//
//  HomeViewController.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 1..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PET CITY HOME"
        
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
            cell.photoList = [#imageLiteral(resourceName: "Restaurant with Pet"), #imageLiteral(resourceName: "pethotel08"), #imageLiteral(resourceName: "pethotel1"), #imageLiteral(resourceName: "pethotel2"), #imageLiteral(resourceName: "pethotel09")]
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderRow", for: indexPath) as! HeaderRow
            cell.title.text = "Recommended Places"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceRow", for: indexPath) as! PlaceRow
            cell.storeList = [#imageLiteral(resourceName: "pethotel5"), #imageLiteral(resourceName: "pethotel6"), #imageLiteral(resourceName: "pethotel1"), #imageLiteral(resourceName: "pethotel2"), #imageLiteral(resourceName: "pethotel09")]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 180
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
