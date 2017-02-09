//
//  PhotoCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 6..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class PhotoRow: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var photoList = [UIImage]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
//        photoList = cell.setupView()
        
        let image = photoList[indexPath.row]
        cell.imageView.image = image
        
        return cell
        
    }
    
    // In order to keep the collectionview's paging as center by photo
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
