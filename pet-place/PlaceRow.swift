//
//  PlaceCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 6..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PlaceRow: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var storeList = [Recommendations]()
    
    @IBOutlet weak var placeCollection: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return storeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as! StoreCollectionViewCell
        
        let store = storeList[indexPath.row].recommendStore
        let imageURL = store?.imageURL!
        print("this is imageURL: \(imageURL!)")
        let url = URL(string: imageURL!)
        cell.storeImage.hnk_setImage(from: url!, placeholder: UIImage(named: "placeholder"))
        
        cell.storeTitle.text = store?.name!
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width/2)-10
        return CGSize(width: width, height: 172)
        
    }
}

