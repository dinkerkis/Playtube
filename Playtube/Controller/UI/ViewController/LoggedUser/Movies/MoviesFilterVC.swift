//
//  MoviesFilterVC.swift
//  Playtube
//
//  Created by Abdul Moid on 25/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class MoviesFilterVC: UIViewController {

    var vc:MoviesNewVC?
    @IBOutlet weak var applyButton: RoundButton!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var releaseTextField: UITextField!
    @IBOutlet weak var ratingTextField: UITextField!
    @IBOutlet weak var searchTermTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        releaseTextField.addTarget(self, action: #selector(releaseTextFieldTap), for: .touchDown)
        countryTextField.addTarget(self, action: #selector(countryTextFieldTap), for: .touchDown)
        categoryTextField.addTarget(self, action: #selector(categoryTextFieldTap), for: .touchDown)
    }
    
    @objc func releaseTextFieldTap(textField: UITextField) {
        let vc = R.storyboard.popups.countryPopUpVC()
        vc?.modalPresentationStyle = .overFullScreen
        vc?.modalTransitionStyle = .crossDissolve
        vc?.vc = self
        vc?.clickStr = "release"
        self.present(vc!, animated: true, completion: nil)
    }
    
    @objc func countryTextFieldTap(textField: UITextField) {
        let vc = R.storyboard.popups.countryPopUpVC()
        vc?.modalPresentationStyle = .overFullScreen
        vc?.modalTransitionStyle = .crossDissolve
        vc?.vc = self
        vc?.clickStr = "country"
        self.present(vc!, animated: true, completion: nil)
    }
    
    @objc func categoryTextFieldTap(textField: UITextField) {
        let vc = R.storyboard.popups.categoryPopupVC()
        vc?.modalPresentationStyle = .overFullScreen
        vc?.modalTransitionStyle = .crossDissolve
        vc?.vc = self
        self.present(vc!, animated: true, completion: nil)
    }
    
    @IBAction func applyClicked(_ sender: Any) {
        self.vc?.isLoading = true
        self.filterData()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        searchTermTextField.text = ""
        countryTextField.text = ""
        categoryTextField.text = ""
        ratingTextField.text = ""
        releaseTextField.text = ""
        self.vc?.isLoading = true
        self.filterData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func filterData(){
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        MovieManager.instance.filterMovies(User_id: "\(userID)", pageID: "1", keyword: searchTermTextField.text ?? "", country: countryTextField.text ?? "", category: categoryTextField.text ?? "", rating: ratingTextField.text ?? "", release: releaseTextField.text ?? "", Session_Token: sessionID) { (success, sessionErr, Err) in
            if success != nil {
                self.vc?.moviesArray.removeAll()
                guard let chanels = success?.channels else { return }
                self.vc?.moviesArray = chanels
                print("COUNT :=> ",self.vc?.moviesArray.count)
            }else if sessionErr != nil {
                self.vc?.view.makeToast("Error filtering movies")
            }else{
                self.vc?.view.makeToast("Error filtering movies")
            }
            self.dismiss(animated: true) {
                self.vc?.checkarray()
                self.vc?.isLoading = false
            }
        }
    }
}
