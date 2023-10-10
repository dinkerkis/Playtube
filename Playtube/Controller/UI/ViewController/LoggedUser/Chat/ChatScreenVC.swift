//
//  ChatScreenVC.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 1/11/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import DropDown

class ChatScreenVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClear: UIButton!
    
    // MARK: - Properties
    
    let dropdown = DropDown()
    var recipentID: Int? = 0
    var username: String?  = ""
    var UserData: ChatModel.User?
    var userImg : String? = ""
    private var messageArray = [UserChatModel.Message]()
    private var scrollStatus: Bool? = true
    private var messageCount: Int? = 0
    private var timer: Timer? = nil
    var isFirstTime = false
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.timer?.invalidate()
    }
    
    // MARK: - Selectors
    
    @IBAction func sendPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.sendMessage()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClear(_ sender: Any) {
        self.dropdown.show()
    }
    
    @objc func update() {
        self.fetchUserChats()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.setupUI()
        self.customizeDropDownFunc()
        self.fetchUserChats()
    }
    
    private func setupUI() {
        self.lblTitle.text = self.username
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.chatLeftTableItem), forCellReuseIdentifier: R.reuseIdentifier.chatLeftTableItem.identifier)
        tableView.register(UINib(resource: R.nib.chatRightTableItem), forCellReuseIdentifier: R.reuseIdentifier.chatRightTableItem.identifier)
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    private  func customizeDropDownFunc() {
        dropdown.dataSource = ["Clear chat"]
        dropdown.anchorView = self.btnClear
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0 {
                self.cleartChat()
            }
            log.verbose("Selected item: \(item) at index: \(index)")
        }
        dropdown.direction = .any
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension ChatScreenVC {
    
    private func fetchUserChats() {
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        let receipentID = self.recipentID ?? 0
        Async.background {
            ChatManager.instance.getUserChats(User_id: userID, Session_Token: sessionID, First_id: 0, Last_id: 0, Recipient_id:receipentID , Limit: 0, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.debug("userList = \(success?.data?.messages ?? [])")
                            let oldMsgArrCount = self.messageArray.count
                            print("oldMsgArrCount :=> ",oldMsgArrCount)
                            self.messageArray = [UserChatModel.Message]()
                            success?.data?.messages?.forEach({ (it) in
                                self.messageArray.append(it)
                            })
                            print("oldMsgArrCount :=>After ",self.messageArray.count)
                            if oldMsgArrCount == self.messageArray.count {
                                return
                            } else {
                                if !self.isFirstTime {
                                    self.isFirstTime = true
                                    self.tableView.reloadData()
                                } else {
                                    self.tableView.beginUpdates()
                                    self.tableView.insertRows(at: [IndexPath(row: self.messageArray.count - 1, section: 0)], with: .automatic)
                                    self.tableView.endUpdates()
                                }
                            }
                            if self.scrollStatus! {
                                if self.messageArray.count == 0 {
                                    log.verbose("Will not scroll more")
                                } else {
                                    self.scrollStatus = false
                                    self.messageCount = self.messageArray.count
                                    let indexPath = NSIndexPath(item: ((self.messageArray.count) - 1), section: 0)
                                    self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                }
                            } else {
                                if self.messageArray.count > self.messageCount! {
                                    self.messageCount = self.messageArray.count
                                    let indexPath = NSIndexPath(item: ((self.messageArray.count) - 1), section: 0)
                                    self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                } else {
                                    log.verbose("Will not scroll more")
                                }
                                log.verbose("Will not scroll more")
                            }
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.error_text)
                            log.error("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            })
        }
    }
    
    private func sendMessage() {
        let hashID = Int(arc4random_uniform(UInt32(100000)))
        let messageText = self.messageTextField.text ?? ""
        let recipientId = self.recipentID ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        let userID = AppInstance.instance.userId ?? 0
        self.tableView.beginUpdates()
        let model = UserChatModel.Message(id: 0 ,fromID: userID ,toID: recipientId, text: messageText, seen: 0, time: 0, fromDeleted: 0, toDeleted: 0, textTime: "", position: "right")
        self.tableView.insertRows(at: [IndexPath(row: self.messageArray.count, section: 0)], with: .automatic)
        self.messageArray.append(model)
        self.tableView.endUpdates()
        let indexPath = NSIndexPath(item: ((self.messageArray.count) - 1), section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        Async.background {
            ChatManager.instance.sendUserMessage(User_id: userID, Session_Token: sessionID, Recipient_id: recipientId, Hash_id: hashID, Text: messageText, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.messageTextField.text = ""
                            if self.messageArray.count == 0 {
                                log.verbose("Will not scroll more")
                                self.view.resignFirstResponder()
                            } else {
                                self.view.resignFirstResponder()
                                log.debug("userList = \(success?.data!)")
                            }
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors.error_text ?? "")
                            log.error("sessionError = \(sessionError?.errors.error_text ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            })
        }
    }
    
    private func cleartChat() {
        let recipientId = self.recipentID ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        let userID = AppInstance.instance.userId ?? 0
        Async.background {
            ChatManager.instance.removeUserChats(User_id: userID, Session_Token: sessionID, Recipient_id: recipientId, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.navigationController?.popViewController(animated: true)
                            self.timer?.invalidate()
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast(sessionError?.errors?.error_text ?? "")
                            log.error("sessionError = \(sessionError?.errors?.error_text ?? "")")
                        }
                    }
                } else {
                    Async.main {
                        self.dismissProgressDialog {
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription ?? "")")
                        }
                    }
                }
            })
        }
    }
    
}

// MARK: TableView Setup
extension ChatScreenVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messageArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatRightTableItem.identifier) as! ChatRightTableItem
            return cell
        }
        let object = self.messageArray[indexPath.row]
        if object.position == "right" {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatRightTableItem.identifier) as! ChatRightTableItem
            cell.bind(object)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatLeftTableItem.identifier) as! ChatLeftTableItem
            cell.userData = self.UserData
            cell.userImg = self.userImg
            cell.bind(object)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
