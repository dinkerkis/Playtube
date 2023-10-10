//
//  ThemeOptionPopupVC.swift
//  Playtube
//
//  Created by iMac on 25/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import Foundation
import UIKit

class ThemeOptionPopupVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var pullBar: UIView!
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 3.5
            borderView.backgroundColor = UIColor(named: "Label_Colors_Tertiary")
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties -
    var sheetHeight: CGFloat = 400
    var sheetBackgroundColor: UIColor = .white
    var sheetCornerRadius: CGFloat = 22
    private var hasSetOriginPoint = false
    private var originPoint: CGPoint?
    let optionArray = [
        "Light",
        "Dark",
        "Set by Battery saver (Auto)"
    ]
    var object: VideoDetail?
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetOriginPoint {
            hasSetOriginPoint = true
            originPoint = view.frame.origin
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        view.frame.size.height = sheetHeight
        view.isUserInteractionEnabled = true
        view.backgroundColor = sheetBackgroundColor
        view.roundCorners(corners: [.topLeft, .topRight], radius: sheetCornerRadius)
        self.registerCell()
        self.setPanGesture()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.videoOptionCell), forCellReuseIdentifier: R.reuseIdentifier.videoOptionCell.identifier)
    }
    
    // Set Pan Gesture
    func setPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    // Gesture Recognizer
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        view.frame.origin = CGPoint(
            x: 0,
            y: self.originPoint!.y + translation.y
        )
        if sender.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

// MARK: - Extensions

// MARK: TableView Setup
extension ThemeOptionPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.videoOptionCell.identifier, for: indexPath) as! VideoOptionCell
        cell.titleLabel.text = optionArray[indexPath.row]
        cell.optionImageView.image = iconImage(index: indexPath.row)
        return cell
    }
    
    func iconImage(index: Int) -> UIImage? {
        if index == 0 {
            return UIImage(named: "s_light_mode")
        }else if index == 1 {
            return UIImage(named: "s_dark_mode")
        }else {
            return UIImage(named: "s_auto_mode")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keyWindow = UIApplication.shared.connectedScenes
               .filter({$0.activationState == .foregroundActive})
               .compactMap({$0 as? UIWindowScene})
               .first?.windows
               .filter({$0.isKeyWindow}).first
        if indexPath.row == 0 {
            keyWindow?.overrideUserInterfaceStyle = .light
            UserDefaults.standard.setDarkMode(value: false, ForKey: "darkMode")
            UserDefaults.standard.setSystemTheme(value: false, ForKey: "SystemTheme")
        }else if indexPath.row == 1 {
            keyWindow?.overrideUserInterfaceStyle = .dark
            UserDefaults.standard.setDarkMode(value: true, ForKey: "darkMode")
            UserDefaults.standard.setSystemTheme(value: false, ForKey: "SystemTheme")
        }else {
            keyWindow?.overrideUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
            UserDefaults.standard.setSystemTheme(value: true, ForKey: "SystemTheme")
        }
        self.dismiss(animated: true)
    }
}
