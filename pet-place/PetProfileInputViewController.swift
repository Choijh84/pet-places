//
//  PetProfileInputViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 24..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Eureka
import SCLAlertView

class PetProfileInputViewController: FormViewController {

    var petSpecies = "Dog"
    
    var receiver = [NSArray]()
    /// Array of Dog Breed List
    var dogBreed = [String]()
    /// Array of Cat Breed List
    var catBreed = [String]()
    
    /// value of all rows in the form
    var valueDictionary = [String: AnyObject]()
    
    /// Navigation Bar Control
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    /// To save the pet profile object
    @IBAction func saveObject(_ sender: Any) {
        
        // form에서 value 형성
        valueDictionary = form.values(includeHidden: false) as [String : AnyObject]
        dump(valueDictionary)
        /// 데이터 입력 여부 체크
        /// 필수 입력: 이름, 성별, 종, 품종 등
        if valueDictionary["species"] is NSNull || valueDictionary["name"] is NSNull || valueDictionary["breed"] is NSNull || valueDictionary["gender"] is NSNull {
            SCLAlertView().showError("입력 에러", subTitle: "필수 값을 입력해주세요")
        } else {
            /// To ask user to save or not
            /// close 버튼 숨기기
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Yes") {
                /// setup pet profile
                self.setupPetProfile { (success) in
                    if success {
                        /// show alarm and dismiss
                        SCLAlertView().showSuccess("프로필 저장 완료", subTitle: "저장되었습니다")
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        /// show error
                        SCLAlertView().showError("에러 발생", subTitle: "다시 시도해주세요")
                    }
                }
            }
            alertView.addButton("No") {
                print("User says no")
                SCLAlertView().showInfo("취소", subTitle: "저장이 취소되었습니다")
            }
            alertView.showInfo("펫 프로필 저장", subTitle: "저장이 완료되면 알려드립니다")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    /// Initial View setup
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = "펫 프로필 추가"
        readPetBreedList()
        
        form =
        
            Section("필수 정보")
//            {
//                $0.header = HeaderFooterView<HeaderImageView>(.class)
//            }
            
            <<< TextRow("name") {
                $0.title = "Pet name"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            
            <<< SwitchRow("gender") {
                $0.title = "Choose Gender"; $0.value = false
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onChange({ row in
                    if row.value == true {
                        row.cell.textLabel?.text = "Female"
                    }
                    else {
                        row.cell.textLabel?.text = "Male"
                    }
                })
            
            <<< ActionSheetRow<String>("species") {
                $0.title = "Species"
                $0.selectorTitle = "Your Pet? "
                $0.options = ["강아지", "고양이", "기타"]
                $0.value = "Dog"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.onChange({ (row) in
                self.petSpecies = row.value!
                print("This is pet species: \(self.petSpecies)")
            })
            
            <<< PushRow<String>("breed") {
                $0.title = "Breed"
                $0.options = dogBreed
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }.onCellSelection({ (cell, row) in
                if self.petSpecies == "강아지" {
                    row.options = self.dogBreed
                } else if self.petSpecies == "고양이" {
                    row.options = self.catBreed
                } else {
                    row.options = self.dogBreed
                }
            })
            
            
        +++ Section("추가 정보 1")
    
            <<< DecimalRow("weight") {
                $0.title = "Weight"
                $0.value = 3
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
                $0.value = false
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            <<< ImageRow("imagePic"){
                $0.title = "Pet Photo"
            }
            
            <<< AccountRow("registration") {
                $0.title = "Registation"
                $0.placeholder = "Registration"
            }
            
            <<< DateRow("birthday"){
                $0.title = "Birthday"
                $0.value = Date()
                let formatter = DateFormatter()
                formatter.locale = .current
                formatter.dateStyle = .long
                $0.dateFormatter = formatter
            }
            
        +++ Section("추가 정보 2")
        
            <<< TextAreaRow("vaccination") {
                $0.placeholder = "예시: 2016년 12월 31일 1차 접종 완료"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
            }
            
            <<< TextAreaRow("sickHistory") {
                $0.placeholder = "예시: 2017년 1월 8일 병원 진료"
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
        
        var temps = datasourceDictionary["Dog"] as! [NSArray]

        for temp in temps {
            dogBreed.append(temp[0] as! String)
        }
        
        dogBreed = dogBreed.sorted()
        
        temps = datasourceDictionary["Cat"] as! [NSArray]
        
        for temp in temps {
            catBreed.append(temp[0] as! String)
        }
        catBreed = catBreed.sorted()
        
    }

    
    /**
     Upload photo, compressImage를 활용해서 압축해서 저장할 예정임
     :param: image
     :param: name, 파일네임이 name+time 형태로 저장될 예정, 저장 루트: petProfileImages/
     */
    func uploadPhoto(image: UIImage!, name: String!, completionHandler: @escaping (_ success: Bool, _ url: String) -> ())   {
        
        let compressed = image.compressImage(image)
        
        let fileName = String(format: "\(name!)%0.0f.jpeg", Date().timeIntervalSince1970)
        let filePath = "petProfileImages/\(fileName)"
        print("This is filePath:\(filePath)")
        let content = UIImageJPEGRepresentation(compressed, 1.0)
        
        Backendless.sharedInstance().fileService.saveFile(filePath, content: content, response: { (uploadedFile) in
            let fileURL = uploadedFile?.fileURL
            print("This is fileURL:\(fileURL!)")
            completionHandler(true, fileURL!)
        }, error: { (fault) in
            print(fault?.description ?? "There is an error in uploading pet profile photo")
            completionHandler(false, (fault?.description)!)
        })
    }
    
    func setupPetProfile(completionHandler: @escaping (_ success: Bool) -> ()) {
        
        let tempPet = PetProfile()
        var name: String?
        
        if let species = valueDictionary["species"] as? String {
            tempPet.species = species
        }
        if let tempname = valueDictionary["name"] as? String {
            tempPet.name = tempname
            name = tempname
        }
        if let breed = valueDictionary["breed"] as? String {
            tempPet.breed = breed
        }
        if let vaccination = valueDictionary["vaccination"] as? String {
            tempPet.vaccination = vaccination
        }
        if let sickHistory = valueDictionary["sickHistory"] as? String {
            tempPet.sickHistory = sickHistory
        }
        if let neutralized = valueDictionary["neutralized"] as? Bool {
            print("This is neutralized: \(neutralized)")
            tempPet.neutralized = neutralized
        }
        if let gender = valueDictionary["gender"] as? Bool {
            if gender == true {
                tempPet.gender = "Male"
            } else {
                tempPet.gender = "Female"
            }
        }
        if let weight = valueDictionary["weight"] as? Double {
            tempPet.weight = weight
        }
        if let birthday = valueDictionary["birthday"] as? Date {
            tempPet.birthday = birthday
        }
        if let registration = valueDictionary["registration"] as? String {
            tempPet.registration = registration
        }
        if let image = valueDictionary["imagePic"] as? UIImage {
            uploadPhoto(image: image, name: name, completionHandler: { (success, fileUrl) in
                if success == true {
                    print("This is pet profile url: \(fileUrl)")
                    tempPet.imagePic = fileUrl
                    dump(tempPet)
                    self.uploadPetProfile(profile: tempPet, completionHandler: { (success) in
                        if success {
                            completionHandler(true)
                        } else {
                            completionHandler(false)
                        }
                    })
                } else {
                    print("Failure in upload")
                }
            })
        } else {
            self.uploadPetProfile(profile: tempPet, completionHandler: { (success) in
                if success {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            })
        }
    }
    
    func uploadPetProfile(profile: PetProfile, completionHandler: @escaping (_ success: Bool) -> ()) {

        let user = Backendless.sharedInstance().userService.currentUser
        
        if user != nil {
            var petProfiles = user?.getProperty("petProfiles") as! [PetProfile]
            _ = petProfiles.append(profile)
            user?.setProperty("petProfiles", object: petProfiles)
            Backendless.sharedInstance().userService.update(user, response: { (user) in
                SCLAlertView().showSuccess("Save Pet Profile", subTitle: "OK")
                _ = self.navigationController?.popViewController(animated: true)
            }, error: { (Fault) in
                print("Server reported an error on saving pet profile: \(Fault?.description)")
            })
        } else {
            print("There is no user u can save")
        }
    }

}

class HeaderImageView: UIView {
    
    var imageView = UIImageView(image: #imageLiteral(resourceName: "imageplaceholder"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 130)
        imageView.autoresizingMask = .flexibleWidth
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 130)
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
