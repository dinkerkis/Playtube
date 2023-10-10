//
//  ActivityDetailsVC.swift
//  Playtube
//
//  Created by iMac on 30/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import Toast_Swift

class ActivityDetailsVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var activity: UserActivity?
    private var commentsArray: [Comment] = []
    
    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.initialConfig()
    }
    
    // MARK: - Selectors
    
    // Back Button Action
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        self.registerCell()
        self.fetchComments()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.userActivityCell), forCellReuseIdentifier: R.reuseIdentifier.userActivityCell.identifier)
        self.tableView.register(UINib(resource: R.nib.sendCommentCell), forCellReuseIdentifier: R.reuseIdentifier.sendCommentCell.identifier)
        self.tableView.register(UINib(resource: R.nib.commentCell), forCellReuseIdentifier: R.reuseIdentifier.commentCell.identifier)
    }
    
}

// MARK: - Extensions

// MARK: Api Call
extension ActivityDetailsVC {
    
    func fetchComments() {
        Async.background {
            self.commentsArray = []
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let activity_id = self.activity?.id ?? 0
            UserActivityManager.sharedInstance.fetchActivityComments(user_id: userID, session_Token: sessionID, activity_id: activity_id, completionBlock: { success, sessionError, error in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.commentsArray = success?.data ?? []
                            self.tableView.reloadData()
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
    }
    
    func sendComment(commentTextField: UITextField) {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let activity_id = self.activity?.id ?? 0
            let comment_Text = commentTextField.text ?? ""
            Async.background {
                UserActivityManager.sharedInstance.createActivityComments(user_id: userID, session_Token: sessionID, activity_id: activity_id, comment_Text: comment_Text, completionBlock: { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                commentTextField.text = ""
                                commentTextField.resignFirstResponder()
                                self.fetchComments()
                                log.verbose("success \(success?.message ?? "") ")
                            }
                        }
                    } else if sessionError != nil {
                        self.dismissProgressDialog {
                            log.verbose("sessionError = \(sessionError?.errors.error_text ?? "")")
                            self.view.makeToast(sessionError?.errors.error_text ?? "")
                        }
                    } else {
                        self.dismissProgressDialog {
                            log.verbose("error = \(error?.localizedDescription ?? "")")
                            self.view.makeToast(error?.localizedDescription ?? "")
                        }
                    }
                })
            }
        } else {
            self.view.makeToast(InterNetError)
        }
    }
    
}

// MARK: TableView Setup
extension ActivityDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.commentsArray.count + 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userActivityCell.identifier, for: indexPath) as! UserActivityCell
            guard let object = self.activity else { return cell }
            cell.sendButton.isHidden = true
            cell.bind(index: object)
            return cell
        case 1:
            if indexPath.row == self.commentsArray.count {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.sendCommentCell.identifier, for: indexPath) as! SendCommentCell
                cell.delegate = self
                return cell
            } else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.commentCell.identifier, for: indexPath) as! CommentCell
                cell.delegate = self
                let object = self.commentsArray[indexPath.row]
                cell.bind(object)
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
}

// MARK: SendCommentCellDelegate
extension ActivityDetailsVC: SendCommentCellDelegate {
    
    func handleSendButtonTap(_ sender: UIButton, commentTextField: UITextField) {
        self.sendComment(commentTextField: commentTextField)
    }
    
}

// MARK: CommentCellDelegate
extension ActivityDetailsVC: CommentCellDelegate {
    
    func handleRepliesButtonTap(_ sender: UIButton, commentData: Comment?) {        
        let newVC = R.storyboard.library.activityCommentReplyVC()
        newVC?.modalPresentationStyle = .custom
        newVC?.transitioningDelegate = self
        newVC?.sheetHeight = UIScreen.main.bounds.height - ((UIScreen.main.bounds.width * 9) / 16)
        newVC?.commentData = commentData
        obj_appDelegate.window?.rootViewController?.present(newVC!, animated: true)
    }
    
}

// MARK: UIViewControllerTransitioningDelegate Methods
extension ActivityDetailsVC: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}
