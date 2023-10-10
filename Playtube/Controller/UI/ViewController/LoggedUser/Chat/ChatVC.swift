//
//  ChatVC.swift
//  Playtube
//
//  Created by Muhammad Haris Butt on 1/11/20.
//  Copyright © 2020 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK

class ChatVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var noDataStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var chatArray = [ChatModel.Datum]()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.setupUI()
//        self.noDataLabel.text = NSLocalizedString("There is no chat available. start chatting with friends.", comment: "There is no chat available. start chatting with friends.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        self.fetchChats()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - Selectors -
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    private func setupUI() {
        self.navigationItem.title = "Chats"
        self.tableView.separatorStyle = .none
        tableView.register(UINib(resource: R.nib.chatTableItem), forCellReuseIdentifier: R.reuseIdentifier.chatTableItem.identifier)
    }
    
    private func fetchChats() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            Async.background {
                ChatManager.instance.getChats(User_id: userID, Session_Token: sessionID, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        self.dismissProgressDialog {
                            Async.main {
                                log.debug("Success")
                                self.chatArray = (success?.data)!
                                if self.chatArray.isEmpty {
                                    self.tableView.isHidden = true
                                    self.noDataStackView.isHidden = false
                                    self.tableView.reloadData()
                                } else {
                                    self.tableView.isHidden = false
                                    self.noDataStackView.isHidden = true
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    } else if sessionError != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("sessionError = \(sessionError?.errors!.error_text ?? "")")
                                self.view.makeToast(sessionError?.errors!.error_text)
                            }
                        }
                    } else {
                        Async.main {
                            self.dismissProgressDialog {
                                log.error("error = \(error?.localizedDescription ?? "")")
                                self.view.makeToast(error?.localizedDescription)
                            }
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: - Extensions

// MARK: Table View Setup
extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chatTableItem.identifier) as? ChatTableItem
        let object = self.chatArray[indexPath.row]
        cell?.bind(object)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.chatArray[indexPath.row]
        let vc = R.storyboard.chat.chatScreenVC()
        vc?.UserData = object.user
        vc?.recipentID = object.user?.id ?? 0
        if (object.user!.firstName?.isEmpty)! && (object.user!.lastName?.isEmpty)! {
            vc?.username = object.user!.username ?? ""
        } else {
            vc?.username = object.user!.firstName ?? "" + object.user!.lastName!
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
}
