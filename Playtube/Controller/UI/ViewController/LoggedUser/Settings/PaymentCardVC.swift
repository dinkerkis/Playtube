//
//  PaymentCardVC.swift
//  Playtube
//
//  Created by iMac on 19/06/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK

protocol PaymentCardViewDelegate {
    func cardView(_ isSuccess: Bool)
}

class PaymentCardVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var cardNumberTextField: DTTextField!
    @IBOutlet weak var cvvTextField: DTTextField!
    @IBOutlet weak var yearTextField: DTTextField!
    @IBOutlet weak var nameTextField: DTTextField!
    @IBOutlet weak var postalCodeTextField: DTTextField!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var lblCardNumber: UILabel!
    @IBOutlet weak var lblErrorCardNumber: UILabel!
    @IBOutlet weak var lblCvv: UILabel!
    @IBOutlet weak var lblErrorCvv: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblErrorYear: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - Properties
    
    var paymentType: String?
    var amount: Int = 0
    let userID = AppInstance.instance.userId ?? 0
    let sessionID = AppInstance.instance.sessionId ?? ""
    let site_settings = UserDefaults.standard.getSettings()
    var delegate: PaymentCardViewDelegate?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // Continue Button Action
    @IBAction func continueButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if paymentType == "authorize" {
            self.addAuthorizeNetPaymentGatewayAPI()
        }
        if paymentType == "creditcard" {
            //self.getStripeToken()
        }
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setData()
    }
    
    // Set Data
    func setData() {
        self.cardNumberTextField.delegate = self
        self.yearTextField.delegate = self
        self.cvvTextField.delegate = self
        self.nameTextField.delegate = self
        self.lblErrorCardNumber.text = "Your card's number is invalid."
        self.lblErrorCvv.text = "Your card's security code is invalid."
        self.lblErrorYear.text = "Your card's expiration year is invalid."
        if paymentType == "authorize" {
            self.headerLabel.text = "AuthorizeNet"
        }
        if paymentType == "creditcard" {
            self.headerLabel.text = "Credit Card"
        }
    }
    
}

// MARK: - Extensions

// MARK: Stripe Setup
//extension PaymentCardVC {
//    
//    private func getStripeToken() {
//        self.showProgressDialog(text: "Loading...")
//        let stripeCardParams = STPCardParams()
//        stripeCardParams.number = self.cardNumberTextField.text
//        let expiryParameters = yearTextField.text?.components(separatedBy: "/")
//        stripeCardParams.expMonth = UInt(expiryParameters?.first ?? "0") ?? 0
//        stripeCardParams.expYear = UInt(expiryParameters?.last ?? "0") ?? 0
//        stripeCardParams.cvc = cvvTextField.text
//        let config = STPPaymentConfiguration.shared
//        let stpApiClient = STPAPIClient(publishableKey: (self.site_settings?["stripe_id"] as? String ?? ""))
//        stpApiClient.createToken(withCard: stripeCardParams) { (token, error) in
//            if error == nil {
//                Async.main({
//                    log.verbose("Token = \(token?.tokenId ?? "")")
//                    self.navigationController?.popViewController(animated: true)
//                    self.delegate?.cardView(true)
//                })
//            } else {
//                self.dismissProgressDialog {
//                    self.view.makeToast(error?.localizedDescription ?? "")
//                    log.verbose("Error = \(error?.localizedDescription ?? "")")
//                }
//            }
//        }
//    }
//    
//}

// MARK: Authorize Net Api Call
extension PaymentCardVC {
    
    func addAuthorizeNetPaymentGatewayAPI() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let cardNumber = self.cleanCreditCardNo(self.cardNumberTextField.text ?? "")
            let cardMonth = "\((self.yearTextField.text ?? "").prefix(2))"
            let cardYear = "\((self.yearTextField.text ?? "").suffix(4))"
            let cardCvv = (self.cvvTextField.text ?? "")
            print(cardMonth, cardYear)
            Async.background { [self] in
                AuthorizeNetPaymentManager.instance.addWalletApi(user_id: userID, session_token: sessionID, amount: self.amount, card_number: cardNumber, card_month: cardMonth, card_year: cardYear, card_cvc: cardCvv) { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.verbose("success \(success?.message ?? "") ")
                                self.navigationController?.popViewController(animated: true)
                                self.delegate?.cardView(true)
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors?.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                        }
                    } else {
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                }
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: UITextFieldDelegate Methods
extension PaymentCardVC: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if cardNumberTextField == textField {
            self.cardNumberTextField.text = textField.text?.formattedCreditCard
            if self.cardNumberTextField.text == "" {
                self.lblCardNumber.text = "**** **** **** ****"
            }else {
                self.lblCardNumber.text = self.cardNumberTextField.text?.formattedCreditCard
            }
            self.lblErrorCardNumber.isHidden = self.isCardNumberValid(self.cardNumberTextField.text?.formattedCreditCard)
            let cardType = self.cardType(from: self.cardNumberTextField.text?.formattedCreditCard ?? "").textFieldIcon
            self.cardImageView.image = UIImage(named: cardType)
        }
        if yearTextField == textField {
            if self.yearTextField.text == "" {
                self.lblYear.text = "MM/YYYY"
            }else {
                self.lblYear.text = textField.text?.formattedExpiredDate
            }
            self.lblErrorYear.isHidden = self.isExpDateValid(self.yearTextField.text?.formattedExpiredDate ?? "")
        }
        
        if cvvTextField == textField {
            cvvTextField.text = textField.text?.formattedCvv
            if self.cvvTextField.text == "" {
                self.lblCvv.text = "123"
            }else{
                self.lblCvv.text = self.cvvTextField.text?.formattedCvv
            }
            self.lblErrorCvv.isHidden = self.isCvvValid(self.cvvTextField.text?.formattedCvv)
        }
        
        if nameTextField == textField {
            self.nameTextField.text = textField.text
            if self.nameTextField.text == "" {
                self.lblName.text = "Your Name"
            }else{
                self.lblName.text = self.nameTextField.text
            }
            self.lblErrorCvv.isHidden = self.isCvvValid(self.cvvTextField.text?.formattedCvv)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text ?? "").count + string.count - range.length
        if(textField == cardNumberTextField) {
            return newLength <= 19
        }
        if yearTextField == textField {
            guard let oldText = textField.text, let r = Range(range, in: oldText) else {
                return true
            }
            let updatedText = oldText.replacingCharacters(in: r, with: string)
            
            if string == "" {
                if updatedText.count == 2 {
                    textField.text = "\(updatedText.prefix(1))"
                    return false
                }
            } else if updatedText.count == 1 {
                if updatedText > "1" {
                    return false
                }
            } else if updatedText.count == 2 {
                if updatedText <= "12" { //Prevent user to not enter month more than 12
                    textField.text = "\(updatedText)/" //This will add "/" when user enters 2nd digit of month
                }
                return false
            } else if updatedText.count == 7 {
                //                    return true
            } else if updatedText.count > 7 {
                return false
            }
        }
        return true
    }
    
}

extension PaymentCardVC {
    
    public func cardType(from cardNumber: String) -> CardBankType {
        let cleanCardNumber = self.cleanCreditCardNo(cardNumber)
        guard cleanCardNumber.count > 0 else {
            return .nonIdentified
        }
        
        let first = String(cleanCardNumber.first!)
        
        guard first != "4" else {
            
            return .visa
        }
        
        guard first != "6" else {
            return .maestro
        }
        
        guard cleanCardNumber.count >= 2 else {
            return .nonIdentified
        }
        
        let indexTwo = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 2)
        let firstTwo = String(cleanCardNumber[..<indexTwo])
        let firstTwoNum = Int(firstTwo) ?? 0
        
        if firstTwoNum == 35 {
            return .nonIdentified
        } else if firstTwoNum == 34 || firstTwoNum == 37 {
            return .nonIdentified
        } else if firstTwoNum == 50 || (firstTwoNum >= 56 && firstTwoNum <= 69) {
            return .maestro
        } else if (firstTwoNum >= 51 && firstTwoNum <= 55) {
            return .mastercard
        }
        
        guard cleanCardNumber.count >= 4 else {
            return .nonIdentified
        }
        
        let indexFour = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 4)
        let firstFour = String(cleanCardNumber[..<indexFour])
        let firstFourNum = Int(firstFour) ?? 0
        
        if firstFourNum >= 2200 && firstFourNum <= 2204 {
            return .mir
        }
        
        if firstFourNum >= 2221 && firstFourNum <= 2720 {
            return .mastercard
        }
        
        guard cleanCardNumber.count >= 6 else {
            return .nonIdentified
        }
        
        let indexSix = cleanCardNumber.index(cleanCardNumber.startIndex, offsetBy: 6)
        let firstSix = String(cleanCardNumber[..<indexSix])
        let firstSixNum = Int(firstSix) ?? 0
        
        if firstSixNum >= 979200 && firstSixNum <= 979289 {
            return .nonIdentified
        }
        
        return .nonIdentified
    }
    
    public  func cleanCreditCardNo(_ creditCardNo: String) -> String {
        return creditCardNo.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
    }
    
    public  func isCardNumberValid(_ cardNumber: String?) -> Bool {
        guard let cardNumber = cardNumber else {
            return false
        }
        let number = cardNumber.onlyNumbers()
        guard number.count >= 14 && number.count <= 19 else {
            return false
        }
        
        var digits = number.map { Int(String($0))! }
        stride(from: digits.count - 2, through: 0, by: -2).forEach { i in
            var value = digits[i] * 2
            if value > 9 {
                value = value % 10 + 1
            }
            digits[i] = value
        }
        
        let sum = digits.reduce(0, +)
        return sum % 10 == 0
    }
    
    public func isExpDateValid(_ dateStr: String) -> Bool {
        
        let currentYear = Calendar.current.component(.year, from: Date())   // This will give you current year (i.e. if 2019 then it will be 19)
        let currentMonth = Calendar.current.component(.month, from: Date()) // This will give you current month (i.e if June then it will be 6)
        
        let enteredYear = Int(dateStr.suffix(4)) ?? 0 // get last two digit from entered string as year
        let enteredMonth = Int(dateStr.prefix(2)) ?? 0 // get first two digit from entered string as month
        print(dateStr) // This is MM/YY Entered by user
        
        if enteredYear > currentYear {
            if (1 ... 12).contains(enteredMonth) {
                return true
            } else {
                return false
            }
        } else if currentYear == enteredYear {
            if enteredMonth >= currentMonth {
                if (1 ... 12).contains(enteredMonth) {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    public  func isCvvValid(_ cvv: String?) -> Bool {
        guard let cvv = cvv else {
            return false
        }
        if (cvv.count == 3) {
            return true
        }
        return false
    }
}


extension String {
    
    func onlyNumbers() -> String {
        return components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
    
    var formattedCreditCard: String {
        return format(with: CardTextField.cardNumber, phone: self)
    }
    
    var formattedExpiredDate: String {
        return format(with: CardTextField.dateExpiration, phone: self)
    }
    
    var formattedCvv: String {
        return format(with: CardTextField.cvv, phone: self)
    }
    
    func format(with maskType: CardTextField, phone: String) -> String {
        let mask = maskType.mask
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
                
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

public enum CardBankType {
    case visa
    case mastercard
    case maestro
    case mir
    case nonIdentified
    
    public var textFieldIcon: String {
        switch self {
        case .visa:
            return "visa.icon.colorized"
        case .mastercard:
            return "mastercard.icon.colorized"
        case .maestro:
            return "mastercard.icon.colorized"
        case .mir:
            return "mir.icon.colorized"
        case .nonIdentified:
            return "globe.icon"
        }
    }
    
    var regex: String {
        switch self {
        case .visa:
            return "^4[0-9]{6,}$"
        case .mastercard:
            return "^5[1-5][0-9]{5,}$"
        case .maestro:
            return "^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390)\\d+$"
        case .mir:
            return "^220[0-4]\\d+$"
        case .nonIdentified:
            return ""
        }
    }
}

public enum CardTextField {
    case cardNumber
    case cvv
    case cardHolder
    case dateExpiration
    
    var mask: String {
        switch self {
        case .cardNumber:
            return "XXXX XXXX XXXX XXXX"
        case .cvv:
            return "XXX"
        case .cardHolder:
            return ""
        case .dateExpiration:
            return "XX/XXXX"
        }
    }
}
