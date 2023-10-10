//
//  ActivityCommentReplyVC.swift
//  Playtube
//
//  Created by iMac on 31/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import Toast_Swift

class ActivityCommentReplyVC: BaseVC {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var pullBar: UIView!
    @IBOutlet weak var borderView: UIView! {
        didSet {
            borderView.layer.cornerRadius = 3.5
            borderView.backgroundColor = UIColor(named: "Label_Colors_Tertiary")
        }
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    
    // MARK: - Properties
    
    var sheetHeight: CGFloat = 400
    var sheetBackgroundColor: UIColor = .white
    var sheetCornerRadius: CGFloat = 22
    private var hasSetOriginPoint = false
    private var originPoint: CGPoint?
    var commentData: Comment?
    var replyArray: [ReplyComment] = []
    
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
    
    // MARK: - Selectors
    
    // Send Button Action
    @IBAction func sendButtonAction(_ sender: UIButton) {
        self.sendComment()
    }
    
    // MARK: - Helper Functions
    
    // Initial Config
    func initialConfig() {
        view.frame.size.height = sheetHeight
        view.isUserInteractionEnabled = true
        view.backgroundColor = sheetBackgroundColor
        view.roundCorners(corners: [.topLeft, .topRight], radius: sheetCornerRadius)
        self.setPanGesture()
        self.registerCell()
        self.fetchActivityReplyComments()
    }
    
    // Register Cell
    func registerCell() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(resource: R.nib.commentCell), forCellReuseIdentifier: R.reuseIdentifier.commentCell.identifier)
        self.tableView.register(UINib(resource: R.nib.replyCommentCell), forCellReuseIdentifier: R.reuseIdentifier.replyCommentCell.identifier)
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

// MARK: - Extension

// MARK: Api Call
extension ActivityCommentReplyVC {
    
    private func fetchActivityReplyComments() {
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        var commentID = commentData?.id ?? 0
        Async.background {
            UserActivityManager.sharedInstance.fetchActivityReplyComments(user_id: userID, session_Token: sessionID, comment_Id: commentID, completionBlock: { success, sessionError, error in
                if success != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            self.replyArray = []
                            self.replyArray = success?.data ?? []
                            self.tableView.reloadData()
                        }
                    }
                } else if sessionError != nil {
                    Async.main {
                        self.dismissProgressDialog {
                            log.error("SessionError = \(sessionError?.errors!.error_text ?? "")")
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
    
    func sendComment() {
        if Connectivity.isConnectedToNetwork() {
            self.showProgressDialog(text: NSLocalizedString("Loading...", comment: "Loading..."))
            let userID = AppInstance.instance.userId ?? 0
            let sessionID = AppInstance.instance.sessionId ?? ""
            let activity_id = commentData?.activityID ?? 0
            let comment_Id = commentData?.id ?? 0
            let comment_Text = self.commentTextField.text ?? ""
            Async.background {
                UserActivityManager.sharedInstance.activityReplyComments(user_id: userID, session_Token: sessionID, activity_id: activity_id, comment_Id: comment_Id, comment_Text: comment_Text, completionBlock: { success, sessionError, error in
                    if success != nil {
                        Async.main {
                            self.dismissProgressDialog {
                                self.commentTextField.text = ""
                                self.commentTextField.resignFirstResponder()
                                self.fetchActivityReplyComments()
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
extension ActivityCommentReplyVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return self.replyArray.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.commentCell.identifier, for: indexPath) as! CommentCell
            guard let object = self.commentData else { return cell }
            cell.bind(object)
            return cell
        case 1:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.replyCommentCell.identifier, for: indexPath) as! ReplyCommentCell
            let object = self.replyArray[indexPath.row]
            cell.bind(object)
            return cell
        default:
            return UITableViewCell()
        }
    }
        
}

