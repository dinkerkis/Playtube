//
//  PaymentOptionPopupVC.swift
//  Playtube
//
//  Created by iMac on 16/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit

protocol PaymentOptionPopupVCDelegate {
    func handlePaymentOptionTapped(paymentOption: String)
}

class PaymentOptionPopupVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var paymentOptionArray = [
        "Paypal",
        "Credit Card",
        "Bank Transfer",
        "RazorPay",
        "Paystack",
        // "Cashfree",
        // "Paysera",
        "AuthorizeNet",
        // "IyziPay",
        // "FlutterWave"
    ]
    var delegate: PaymentOptionPopupVCDelegate?
        
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Close Button Action
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.view.backgroundColor = .black.withAlphaComponent(0.4)
        self.registerCell()
        self.setTableViewDataAndHeight()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.paymentOptionCell), forCellReuseIdentifier: R.reuseIdentifier.paymentOptionCell.identifier)
    }
    
    // Set TableView Data And Height
    func setTableViewDataAndHeight() {
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if self.tableView.contentSize.height > (self.view.frame.height * 0.7) {
                self.tableViewHeight.constant = (self.view.frame.height * 0.7)
            } else {                
                self.tableViewHeight.constant = self.tableView.contentSize.height
            }
        }
    }

}

// MARK: - Extensions

// MARK: TableView Setup
extension PaymentOptionPopupVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.paymentOptionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.paymentOptionCell.identifier, for: indexPath) as! PaymentOptionCell
        cell.titleLabel.text = self.paymentOptionArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            self.delegate?.handlePaymentOptionTapped(paymentOption: self.paymentOptionArray[indexPath.row])            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
}
