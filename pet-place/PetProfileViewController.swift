//
//  PetProfileViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 5..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Eureka
import SCLAlertView

/// A viewcontroller that displays the pet profile information

class PetProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var isVaccinationShow: Bool = false
    
    var isHistoryShow: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var petArray = [PetProfile]()
    
    /// Lazy getter for the dateformatter that formats the date property of each pet profile to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "My Pet"
        setupPetArray()
    }
    
    func setupPetArray() {
        let user = UserManager.currentUser()
        
        if (user != nil) {
            let petProfiles = user?.getProperty("petProfiles") as! [PetProfile]
            
            for petProfile in petProfiles {
                petArray.append(petProfile)
                dump(petProfile)
            }
        }
    }
    
    func showVac() {
        isVaccinationShow = !isVaccinationShow
        collectionView.reloadData()
    }
    
    func showHistory() {
        isHistoryShow = !isHistoryShow
        collectionView.reloadData()
    }
    
    func editPetProfile(sender: MyButton) {
        performSegue(withIdentifier: "PetProfileEdit", sender: sender)
    }
    
    /**
     Called when the segue is about to be performed. Get the current PetProfile object that is connected with the cell, and assign it to the destination viewController.
     
     :param: segue  The segue object containing information about the view controllers involved in the segue.
     :param: sender The object that initiated the segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PetProfileEdit" {
            let destinatoinVC = segue.destination as! PetProfileEditViewController
            destinatoinVC.selectedPetProfile = petArray[(sender as! MyButton).row!]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetProfileCell", for: indexPath) as! PetProfileCollectionViewCell
        
        /// 백신 기록 보여주기/숨기기
        cell.vaccinationShowHideButton.addTarget(self, action: #selector(PetProfileViewController.showVac), for: .touchUpInside)
        /// 기타 병력 기록 보여주기/숨기기
        cell.historyShowHideButton.addTarget(self, action: #selector(PetProfileViewController.showHistory), for: .touchUpInside)
        /// 편집 버튼
        cell.editButton.addTarget(self, action: #selector(PetProfileViewController.editPetProfile(sender:)), for: .touchUpInside)
        /// 편집 버튼에 row 저장
        cell.editButton.row = indexPath.row
        
        /// petArray의 petProfile에서 사진이 있는 경우
        if petArray[indexPath.row].imagePic != nil {
            let url = URL(string: petArray[indexPath.row].imagePic)
            DispatchQueue.main.async(execute: { 
                cell.petProfileImageView.hnk_setImage(from: url)
            })
        } else {
            /// 사진이 없는 경우
        }
        
        cell.nameLabel.text = petArray[indexPath.row].name
        cell.breedLabel.text = petArray[indexPath.row].breed
        cell.genderLabel.text = petArray[indexPath.row].gender
        cell.speciesLabel.text = petArray[indexPath.row].species
        
        cell.birthdayLabel.text = dateFormatter.string(from: petArray[indexPath.row].birthday as Date)
//        reviewCell.dateLabel.text = dateFormatter.string(from: reviewObject.created as Date)
        cell.registrationLabel.text = petArray[indexPath.row].registration
        if petArray[indexPath.row].neutralized == true {
            cell.neutralizedLabel.text = "YES"
        } else if petArray[indexPath.row].neutralized == false {
            cell.neutralizedLabel.text = "NO"
        } else {
            cell.neutralizedLabel.text = "NIL"
        }
        
        cell.pageNumber.text = "\(indexPath.row+1) of \(petArray.count)"
        
        if isVaccinationShow == false {
            cell.vaccinationStackView.isHidden = true
            cell.vaccinationShowHideButton.setTitle("Show", for: .normal)
        } else {
            cell.vaccinationShowHideButton.setTitle("Hide", for: .normal)
            UIView.animate(withDuration: 0.3, animations: {
                cell.vaccinationStackView.isHidden = false
            })
        }
        
        if isHistoryShow == false {
            cell.historyStackView.isHidden = true
            cell.historyShowHideButton.setTitle("Show", for: .normal)
        } else {
            cell.historyShowHideButton.setTitle("Hide", for: .normal)
            UIView.animate(withDuration: 0.3, animations: {
                cell.historyStackView.isHidden = false
            })
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.size.width
        return CGSize(width: width, height: width*1.2)
    }
    
}

class MyButton: UIButton {
    var row: Int?
}


