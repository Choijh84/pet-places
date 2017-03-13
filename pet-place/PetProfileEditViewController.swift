//
//  PetProfileEditViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 27..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Eureka
import SCLAlertView
import AlamofireImage

class PetProfileEditViewController: FormViewController {
    
    var selectedPetProfile: PetProfile!
    
    /// Initial Value of the species
    var petSpecies = "Dog"
    /// Array of Dog Breed List
    var dogBreed = [String]()
    /// Array of Cat Breed List
    var catBreed = [String]()
    
    /// value of all rows in the form
    var valueDictionary = [String: AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is Pet Profile Edit Page: \(selectedPetProfile)")
        readPetBreedList()
        petSpecies = selectedPetProfile.species
        
        form =
            
            Section("General Info")
            //            {
            //                $0.header = HeaderFooterView<HeaderImageView>(.class)
            //            }
            
            <<< TextRow("name") {
                $0.title = "Pet name"
                $0.add(rule: RuleRequired())
                $0.placeholder = selectedPetProfile.name
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            <<< ImageRow("imagePic"){ row in
                row.title = "Pet Photo"
                
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                imageView.contentMode = .scaleAspectFill
                if !selectedPetProfile.imagePic.isEmpty {
                    let url = URL(string: selectedPetProfile.imagePic)
                    imageView.hnk_setImage(from: url, placeholder: #imageLiteral(resourceName: "imageplaceholder"), success: { (image) in
                        imageView.clipsToBounds = true
                        row.imageURL = url
                        row.clearAction = .no
                        row.cell.accessoryView = imageView
                        row.reload()
                    }, failure: { (Fault) in
                        print("Error reported on ImageRow")
                    })
                } else {
                    
                }
                
            }
            
            <<< SwitchRow("gender") {
                
                if selectedPetProfile.gender == "Male" {
                    $0.value = true
                    $0.title = "Male"
                } else {
                    $0.value = false
                    $0.title = "Female"
                }
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onChange({ row in
                    if row.value == true {
                        row.cell.textLabel?.text = "Male"
                    }
                    else {
                        row.cell.textLabel?.text = "Female"
                    }
                })
            
            <<< ActionSheetRow<String>("species") {
                $0.title = "Species"
                $0.selectorTitle = "Your Pet? "
                $0.options = ["Dog", "Cat", "Reptiles", "Birds", "Fish"]
                $0.value = petSpecies
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onChange({ (row) in
                    self.petSpecies = row.value!
                    print("This is pet species: \(self.petSpecies)")
                })
            
            <<< PushRow<String>("breed") {
                $0.title = "Breed"
                if petSpecies == "Dog" {
                    $0.options = dogBreed
                } else if petSpecies == " Cat" {
                    $0.options = catBreed
                } else {
                    $0.options = dogBreed
                }
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.onCellSelection({ (cell, row) in
                    if self.petSpecies == "Dog" {
                        row.options = self.dogBreed
                    } else if self.petSpecies == "Cat" {
                        row.options = self.catBreed
                    } else {
                        row.options = self.dogBreed
                    }
                })
            
            
            +++ Section("ExtraInfo 1")
            
            <<< DecimalRow("weight") {
                $0.title = "Weight"
                $0.value = selectedPetProfile.weight
                $0.formatter = DecimalFormatter()
                $0.useFormatterDuringInput = true
                //$0.useFormatterOnDidBeginEditing = true
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }.cellSetup { cell, _  in
                    cell.textField.keyboardType = .numberPad
            }
            
            <<< CheckRow("neutralized") {
                $0.title = "Neutralized"
                $0.value = selectedPetProfile.neutralized
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< AccountRow("registration") {
                $0.title = "Registation"
                $0.placeholder = selectedPetProfile.registration
            }
            
            <<< DateRow("birthday"){
                $0.title = "Birthday"
                $0.value = selectedPetProfile.birthday
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
            }
            
            +++ Section("ExtraInfo 2")
            
            <<< TextAreaRow() {
                if selectedPetProfile.vaccination == "EMPTY" {
                    $0.placeholder = "Vaccination"
                } else {
                    $0.value = selectedPetProfile.vaccination
                }
                
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
            
            <<< TextAreaRow("sickHistory") {
                if selectedPetProfile.sickHistory == "EMPTY" {
                    $0.placeholder = "Sick History"
                } else {
                    $0.value = selectedPetProfile.sickHistory
                }
                
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
    }
    
    /**
     Pet List Read - from the property list: PetBreedList.plist
     - current: dogBreed(강아지 종류 - alphabetically sort), catBreed(고양이 종류)
     */
    func readPetBreedList() {
        let pathList = Bundle.main.path(forResource: "PetBreedList", ofType: "plist")
        let data: NSData? = NSData(contentsOfFile: pathList!)
        let datasourceDictionary = try! PropertyListSerialization.propertyList(from: data as! Data, options: [], format: nil) as! [String:Any]
        let temp = datasourceDictionary["Dog"] as! [String]
        dogBreed = temp.sorted()
        catBreed = datasourceDictionary["Cat"] as! [String]
    }
    

}


