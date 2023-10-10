//
//  MoviesVC.swift
//  Playtube
//
//  Created by Abdul Moid on 18/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import FittedSheets

class MoviesVC: BaseVC {
    
    @IBOutlet weak var noMovieLabel: UILabel!
    @IBOutlet weak var noMovieImageView: UIImageView!
    var MoviesArray:[VideoDetail] = []

    var controller : SheetViewController?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(resource: R.nib.moviesCell), forCellWithReuseIdentifier: R.reuseIdentifier.moviesCell.identifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.showProgressDialog(text: "Loading...")
        self.fetchMovies()
    }
    
    func setupCollectionView() {
        self.view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        self.navigationItem.title = "Movies"
    }
    
    func fetchMovies() {
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        MovieManager.instance.getMovies(User_id: "\(userID)", Session_Token: sessionID) { (success, SesstionError, err) in
            if success != nil {
                //                self.dismissProgressDialog {
                guard let chanels = success?.channels else { return }
                self.MoviesArray = chanels
                self.checkarray()
                self.dismissProgressDialog {
                    self.collectionView.reloadData()

                }
                //                }
            }else if SesstionError != nil{
                self.view.makeToast("Error")
            }else{
                self.view.makeToast("Error")
            }
        }
    }
    
    @IBAction func filterClicked(_ sender: Any) {
        
        var bottomPadding = 0
        if #available(iOS 11.0, *) {
            bottomPadding = Int(self.view.safeAreaInsets.top)
        } else {
            // Fallback on earlier versions
        }
        
        if bottomPadding == 44 {
            self.controller = SheetViewController(controller: R.storyboard.loggedUser.moviesFilterVC()!, sizes: [.fixed(484)])
        } else {
            self.controller = SheetViewController(controller: R.storyboard.loggedUser.moviesFilterVC()!, sizes: [.fixed(450)])
        }
        self.controller?.dismissOnOverlayTap = true
        self.present(self.controller!, animated: false, completion: nil)
    }
    
    func checkarray() {
        if (self.MoviesArray.isEmpty || self.MoviesArray.count == 0) {
            self.noMovieImageView.isHidden = false
            self.noMovieLabel.isHidden = false
        }else{
            self.noMovieImageView.isHidden = true
            self.noMovieLabel.isHidden = true
        }
    }
}

extension MoviesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return MoviesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.moviesCell.identifier, for: indexPath) as! MoviesCell
//        guard let object = self.MoviesArray?[indexPath.row] else {return UICollectionViewCell()}
//        guard let thumbnail = object["thumbnail"] as? String else {return UICollectionViewCell()}
//        guard let url = URL(string: thumbnail) else {return UICollectionViewCell()}
//        guard let title = object["title"] as? String else {return UICollectionViewCell()}
//        guard let year = object["movie_release"] as? String else {return UICollectionViewCell()}
//        guard let country = object["country"] as? String else {return UICollectionViewCell()}
//        cell.movieImageView.sd_setImage(with: url, placeholderImage: nil, options: [], progress: nil, completed: nil)
//        cell.titleLabel.text = title
//        cell.yearLabel.text = year
//        cell.countryLabel.text = country
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: (view.frame.width / 2) - 2.5, height: view.frame.height / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoObject = self.MoviesArray[indexPath.row]
        AppInstance.instance.addCount = AppInstance.instance.addCount! + 1
        // let videoObject = self.recentlyWatchedArray[indexPath.row]
        let newVC = self.tabBarController as! TabbarController
        // newVC.statusBarHiddenDelegate = self
        //newVC.handleOpenVideoPlayer(for: videoObject)
    }
}

extension MoviesVC {
    
}
