//
//  CreatePopupVC.swift
//  Playtube
//
//  Created by iMac on 30/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol CreatePopupDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}

class CreatePopupVC: BaseVC {
    
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
    var sheetHeight: CGFloat = 350
    var sheetBackgroundColor: UIColor = .white
    var sheetCornerRadius: CGFloat = 22
    private var hasSetOriginPoint = false
    private var originPoint: CGPoint?
    let optionArray = [
        "Import a video",
        "Upload a video",
        "Create a short",
        "Go Live"
    ]
    var object: VideoDetail?
    var delegate: CreatePopupDelegate?
    
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
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Functions -
    
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
        self.tableView.register(UINib(resource: R.nib.createPopupCell), forCellReuseIdentifier: R.reuseIdentifier.createPopupCell.identifier)
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
extension CreatePopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.createPopupCell.identifier, for: indexPath) as! CreatePopupCell
        cell.lblTitle.text = optionArray[indexPath.row]
        cell.iconImage.image = iconImage(index: indexPath.row)
        cell.iconImage.tintColor = UIColor(named: "Primary_UI_Primary")
        return cell
    }
    
    func iconImage(index: Int) -> UIImage? {
        if index == 0 {
            return UIImage(named: "import_video")
        }else if index == 1 {
            return UIImage(named: "cloud")
        }else if index == 2 {
            return UIImage(named: "create_short")?.withTintColor(UIColor(named: "Primary_UI_Primary")!, renderingMode: .alwaysTemplate)
        }else {
            return UIImage(named: "stream")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
}

