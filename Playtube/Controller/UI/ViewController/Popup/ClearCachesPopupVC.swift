//
//  ClearCachesPopupVC.swift
//  Playtube
//
//  Created by iMac on 01/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit



class ClearCachesPopupVC: BaseVC {
    
    // MARK: - IBOutlets
    @IBOutlet weak var pullBar: UIView!
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 3.5
            borderView.backgroundColor = UIColor(named: "Label_Colors_Tertiary")
        }
    }
    
    // MARK: - Properties -
    var sheetHeight: CGFloat = 200
    var sheetBackgroundColor: UIColor = .white
    var sheetCornerRadius: CGFloat = 22
    private var hasSetOriginPoint = false
    private var originPoint: CGPoint?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialConfig()
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetOriginPoint {
            hasSetOriginPoint = true
            originPoint = view.frame.origin
        }
    }
    
    //MARK: - Selectors -
        /// Cancel Button Action
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    /// Delete Button Action
    @IBAction func deleteButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
        URLCache.shared.removeAllCachedResponses()
        obj_appDelegate.window?.rootViewController?.view.makeToast(NSLocalizedString("Cache Removed", comment: "Cache Removed"))
    }
    
    // MARK: - Helper Functions -
    
    // Initial Config
    func initialConfig() {
        view.frame.size.height = sheetHeight
        view.isUserInteractionEnabled = true
        view.backgroundColor = sheetBackgroundColor
        view.roundCorners(corners: [.topLeft, .topRight], radius: sheetCornerRadius)
        self.setPanGesture()
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
