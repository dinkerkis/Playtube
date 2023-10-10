

import UIKit
import Async
class EditChannelVC: BaseVC {
    
    @IBOutlet weak var faceTextField: UITextField!
    //@IBOutlet weak var googleTextField: RoundTextField!
    @IBOutlet weak var twitterTextField: UITextField!
    
    //@IBOutlet weak var aboutTV: RoundTextView!
    //@IBOutlet weak var lastNameTF: RoundTextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var favCategory: UITextField!
    @IBOutlet weak var genderField: UITextField!
    
//    @IBOutlet weak var avatarLabel: UILabel!
//    @IBOutlet weak var changeImageLabel: UILabel!
//    @IBOutlet weak var changeavatarLabel: UILabel!
//    @IBOutlet weak var socialLinkLabel: UILabel!
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var imgCover: UIImageView!
    
    private var genderString:String? = ""
    private let imagePickerController = UIImagePickerController()
    private var imageStatus:Bool? = false
    private var avatarImage:UIImage? = nil
    private var coverImageVar:UIImage? = nil
    private var cate_ids = [String]()
    var is_Setting = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        /*let yourBackImage = UIImage(named: "left-arrows")
           self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
           self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
           self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
           let Save = UIBarButtonItem(title: NSLocalizedString("Save", comment: "Save"), style: .done, target: self, action: #selector(self.Save))
           self.navigationItem.rightBarButtonItem = Save*/
    }
    
    
    private func showSheet(controller: UIViewController){
        let alert = UIAlertController(title: "", message: "Gender", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Male", comment: "Male"), style: .default, handler: { (_) in
                print("User click Approve button")
                self.genderString = "male"
                self.genderField.text = self.genderString
            }))

            alert.addAction(UIAlertAction(title: NSLocalizedString("Female", comment: "Female"), style: .default, handler: { (_) in
                print("User click Edit button")
                self.genderString = "female"
                self.genderField.text = self.genderString
            }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: "Close"), style: .cancel, handler: { (_) in
                print("User click Dismiss button")
            }))

            self.present(alert, animated: true, completion: {
                print("completion block")
            })
    }
    
    
    @IBAction func SelectGender(_ sender: UIButton) {
        self.genderField.inputView = UIView()
        self.genderField.resignFirstResponder()
        self.showSheet(controller: self)
    }

    @IBAction func ChangeAvatar(_ sender: Any) {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Select Source", comment: "Select Source"), preferredStyle: .alert)
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { (action) in
            self.imageStatus = false
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: NSLocalizedString("Gallery", comment: "Gallery"), style: .default) { (action) in
            self.imageStatus = false
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func ChangeCover(_ sender: Any) {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Select Source", comment: "Select Source"), preferredStyle: .alert)
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { (action) in
            self.imageStatus = true
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: NSLocalizedString("Gallery", comment: "Gallery"), style: .default) { (action) in
            self.imageStatus = true
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func Category(_ sender: UIButton) {
        self.favCategory.resignFirstResponder()
        self.favCategory.inputView = UIView()
        let Storyboards  = UIStoryboard(name: "Settings", bundle: nil)
        let vc = Storyboards.instantiateViewController(withIdentifier: "FavouriteCateVC") as! FavouriteCategoryController
        vc.delegete = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
    }
    
    
//
//    @IBAction func genderBtnPressed(_ sender: UIButton) {
//        if sender.tag == 0{
//            self.maleBtn.setImage(UIImage(named: "radio_button_on"), for: .normal)
//            self.femaleBtn.setImage(UIImage(named: "radio_button_off"), for: .normal)
//            self.genderString = "male"
//        }else{
//            self.femaleBtn.setImage(UIImage(named: "radio_button_on"), for: .normal)
//            self.maleBtn.setImage(UIImage(named: "radio_button_off"), for: .normal)
//            self.genderString = "female"
//        }
//    }
    private func setupUI(){
        //self.title = NSLocalizedString("Edit My Channel", comment: "Edit My Channel")
        self.firstNameTF.placeholder = NSLocalizedString("First Name", comment: "First Name")
        //self.lastNameTF.placeholder = NSLocalizedString("Last Name", comment: "Last Name")
        self.usernameTF.placeholder = NSLocalizedString("User Name", comment: "User Name")
        self.emailTF.placeholder = NSLocalizedString("Email", comment: "Email")
        self.favCategory.placeholder = NSLocalizedString("Favourite category", comment: "Favourite category")
        self.genderField.placeholder = NSLocalizedString("Gender", comment: "Gender")
        /*self.avatarLabel.text = NSLocalizedString("Avatar ve Kapak", comment: "Avatar ve Kapak")
        self.changeImageLabel.text = NSLocalizedString("Change image avatar", comment: "Change image avatar")
        self.changeavatarLabel.text = NSLocalizedString("Change image cover", comment: "Change image cover")
        self.socialLinkLabel.text = NSLocalizedString("Social Links", comment: "Social Links")*/
        self.firstNameTF.text = "\(AppInstance.instance.userProfile?.data?.first_name ?? "") \(AppInstance.instance.userProfile?.data?.last_name ?? "")"
        if AppInstance.instance.userProfile?.data?.first_name == ""
        {
            self.firstNameTF.text = AppInstance.instance.userProfile?.data?.last_name ?? ""
        }
        //self.lastNameTF.text = AppInstance.instance.userProfile?.data?.lastName ?? ""
        self.usernameTF.text = AppInstance.instance.userProfile?.data?.username ?? ""
        self.emailTF.text = AppInstance.instance.userProfile?.data?.email ?? ""
        //self.aboutTV.text = AppInstance.instance.userProfile?.data?.about ?? ""
        self.faceTextField.text = AppInstance.instance.userProfile?.data?.facebook ?? ""
        self.twitterTextField.text = AppInstance.instance.userProfile?.data?.twitter ?? ""
        //self.googleTextField.text = AppInstance.instance.userProfile?.data?.google ?? ""
        self.genderField.text = AppInstance.instance.userProfile?.data?.gender_text ?? ""
        self.imgProfile.sd_setImage(with: URL(string: AppInstance.instance.userProfile?.data?.avatar ?? ""))
        self.imgCover.sd_setImage(with: URL(string: AppInstance.instance.userProfile?.data?.cover ?? ""))
        log.verbose("Gender = \(AppInstance.instance.userProfile?.data?.gender_text ?? "")")
    }
    /*@objc func Save(){
        log.verbose("savePressed!!")
        self.updateMyChannel()
    }*/
    
    @IBAction func btnSave(_ sender: Any) {
        log.verbose("savePressed!!")
        self.updateMyChannel()
    }
    
    @objc func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imageStatus = false
                self.imagePickerController.delegate = self
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }else {
                self.view.makeToast("Camera not available for this Device.")
            }
        }
        let gallery = UIAlertAction(title: NSLocalizedString("Gallery", comment: "Gallery"), style: .default) { (action) in
            self.imageStatus = false
            self.imagePickerController.delegate = self
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    @objc func coverImageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Select Source", comment: "Select Source"), preferredStyle: .alert)
        let camera = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imageStatus = true
                self.imagePickerController.delegate = self
                
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }else {
                self.view.makeToast("Camera not available for this Device.")
            }
        }
        let gallery = UIAlertAction(title: NSLocalizedString("Gallery", comment: "Gallery"), style: .default) { (action) in
            self.imageStatus = true
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    private func updateMyChannel(){
        self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
//        let sessionToken = AppInstance.instance.sessionId ?? ""
        let firstname = self.firstNameTF.text ?? ""
        let lastname = ""
        let gender = self.genderString  ?? ""
        let username = self.usernameTF.text ?? ""
        let email = self.emailTF.text ?? ""
        let about = ""//self.aboutTV.text ?? ""
        let facebook = self.faceTextField.text ?? ""
        let google = ""//self.googleTextField.text ?? ""
        let twitter = self.twitterTextField.text ?? ""
        let userId = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        
        Async.background({
            if self.avatarImage == nil && self.coverImageVar == nil{
                
                MyChannelManager.instance.editMyChannel(User_id: userId, Session_Token: sessionID, Username: username, FirstName: firstname, LastName: lastname, Email: email, About: about, Gender: gender, facebook: facebook, twitter: twitter, Google: google, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.debug("success = \(success?.message ?? "")")
                                self.view.makeToast(success?.message ?? "")
                                AppInstance.instance.fetchUserProfile { (success) in
                                    if (success){
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    else{
                                        print("Profile Error")
                                    }
                                }
                            }

                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors?.error_text)")
                                self.view.makeToast(sessionError?.errors?.error_text ?? "")
                            }
                            
                        })
                        
                        
                    }else {
                        Async.main({
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription)")
                                self.view.makeToast(error?.localizedDescription ?? "")
                            }
                            
                        })
                        
                    }
                })
            }else{
                
                if self.avatarImage != nil && self.coverImageVar == nil{
                    let avatarData = self.avatarImage?.jpegData(compressionQuality: 0.2)
                    MyChannelManager.instance.updateUserDataWithCandA(User_id: userId, Session_Token: sessionID, Username: username, FirstName: firstname, LastName: lastname, Email: email, About: about, Gender: gender, facebook: facebook, twitter: twitter, Google: google, type: "avatar", avatar_data: avatarData, cover_data: nil, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.message ?? "")")
                                    self.view.makeToast(success?.message ?? "")
                                    AppInstance.instance.fetchUserProfile { (success) in
                                        if (success){
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        else{
                                            print("Profile Error")
                                        }
                                    }
                                }
                                
                            })
                        }else if sessionError != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.errors?.error_text)")
                                    self.view.makeToast(sessionError?.errors?.error_text ?? "")
                                }
                                
                            })
                            
                            
                        }else {
                            Async.main({
                                self.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription)")
                                    self.view.makeToast(error?.localizedDescription ?? "")
                                }
                                
                            })
                            
                        }
                    })
                }else if self.avatarImage == nil && self.coverImageVar != nil{
                    let coverImageData = self.coverImageVar?.jpegData(compressionQuality: 0.2)
                    MyChannelManager.instance.updateUserDataWithCandA(User_id: userId, Session_Token: sessionID, Username: username, FirstName: firstname, LastName: lastname, Email: email, About: about, Gender: gender, facebook: facebook, twitter: twitter, Google: google, type: "cover", avatar_data: nil, cover_data: coverImageData, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.debug("success = \(success?.message ?? "")")
                                    self.view.makeToast(success?.message ?? "")
                                    AppInstance.instance.fetchUserProfile { (success) in
                                        if (success){
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                        else{
                                            print("Profile Error")
                                        }
                                    }

                                }
                                
                            })
                        }else if sessionError != nil{
                            Async.main({
                                self.dismissProgressDialog {
                                    log.error("sessionError = \(sessionError?.errors?.error_text)")
                                    self.view.makeToast(sessionError?.errors?.error_text ?? "")
                                }
                                
                            })
                            
                            
                        }else {
                            Async.main({
                                self.dismissProgressDialog {
                                    log.error("error = \(error?.localizedDescription)")
                                    self.view.makeToast(error?.localizedDescription ?? "")
                                }
                                
                            })
                            
                        }
                    })
                    
                    
                }else{
                    let avatarData = self.avatarImage?.jpegData(compressionQuality: 0.2)
                    let coverData = self.coverImageVar?.jpegData(compressionQuality: 0.2)
                    
                    MyChannelManager.instance.updateUserDataWithCandA(User_id: userId, Session_Token: sessionID, Username: username, FirstName: firstname, LastName: lastname, Email: email, About: about, Gender: gender, facebook: facebook
                        , twitter: twitter, Google: google, type: "all", avatar_data: avatarData, cover_data: coverData, completionBlock: { (success, sessionError, error) in
                            if success != nil{
                                Async.main({
                                    self.dismissProgressDialog {
                                        log.debug("success = \(success?.message ?? "")")
                                        self.view.makeToast(success?.message ?? "")
                                        AppInstance.instance.fetchUserProfile { (success) in
                                            if (success){
                                                self.navigationController?.popViewController(animated: true)
                                            }
                                            else{
                                                print("Profile Error")
                                            }
                                        }
                                    }
                                    
                                })
                            }else if sessionError != nil{
                                Async.main({
                                    self.dismissProgressDialog {
                                        log.error("sessionError = \(sessionError?.errors?.error_text)")
                                        self.view.makeToast(sessionError?.errors?.error_text ?? "")
                                    }
                                    
                                })
                                
                                
                            }else {
                                Async.main({
                                    self.dismissProgressDialog {
                                        log.error("error = \(error?.localizedDescription)")
                                        self.view.makeToast(error?.localizedDescription ?? "")
                                    }
                                    
                                })
                            }
                    })
                }
            }
        })
    }
}
extension  EditChannelVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate,FavCategoryDelegate{
    
    func fav_cat(id: [String], name: [String]) {
        self.favCategory.resignFirstResponder()
        var cat_names = ""
        for i in name{
            cat_names.append("\(i),")
//            self.favCategory.text = "\(i),"
        }
        self.favCategory.text = cat_names
        self.cate_ids = id
        print("IDS",id)
        print("Names",name)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if imageStatus!{
            self.coverImageVar = image ?? nil
            self.imgCover.image = image
            
        }else{
            self.avatarImage  = image ?? nil
            self.imgProfile.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
}
