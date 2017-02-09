//
//  PlaceCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 6..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PlaceRow: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var storeList = [UIImage]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return storeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaceCell", for: indexPath) as! StoreCollectionViewCell
        
//        storeList = cell.setupView()
        let image = storeList[indexPath.row]
        cell.storeImage.image = image
        cell.storeTitle.text = "store"
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width/2)-10
        return CGSize(width: width, height: 172)
        
    }
}

