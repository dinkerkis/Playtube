//
//  MoviesVC.swift
//  Playtube
//
//  Created by Abdul Moid on 18/03/2021.
//  Copyright © 2021 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import UIView_Shimmer
import FittedSheets

class moviesNewCell : UICollectionViewCell, ShimmeringViewProtocol
{
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var opacityImg: UIImageView!
    
    var shimmeringAnimatedItems: [UIView] {
        [
            movieImageView,
            titleLabel,
            yearLabel,
            opacityImg
        ]
    }
    
    override class func awakeFromNib() {
        
    }
}

class MoviesNewVC: BaseVC {
    
    @IBOutlet weak var noMovieLabel: UILabel!
    @IBOutlet weak var noMovieImageView: UIImageView!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    
    var moviesArray:[VideoDetail] = []
    var controller : SheetViewController?
    var isLoading = true {
        didSet {
            self.movieCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.movieCollectionView.delegate = self
        self.movieCollectionView.dataSource = self
        
        self.isLoading = true
        
        self.fetchMovies()
    }
    
    func fetchMovies() {
        let userID = AppInstance.instance.userId ?? 0
        let sessionID = AppInstance.instance.sessionId ?? ""
        MovieManager.instance.getMovies(User_id: "\(userID)", Session_Token: sessionID) { (success, SesstionError, err) in
            if success != nil {
                guard let chanels = success?.channels else { return }
                self.moviesArray = chanels
                self.checkarray()
                self.isLoading = false
            }else if SesstionError != nil{
                self.view.makeToast("Error")
            }else{
                self.view.makeToast("Error")
            }
        }
    }
    
    @IBAction func filterClicked(_ sender: Any) {
//        vc.delegate = self
        /*let vc = R.storyboard.loggedUser.moviesFilterVC()
        //vc?.vc = self
        vc?.modalPresentationStyle = .overFullScreen
        vc?.modalTransitionStyle = .crossDissolve
        self.present(vc!, animated: true, completion: nil)*/
        
        let vc = R.storyboard.loggedUser.moviesFilterVC()
        vc?.vc = self
        
        var bottomPadding = 0
        if #available(iOS 11.0, *) {
            bottomPadding = Int(self.view.safeAreaInsets.top)
        } else {
            // Fallback on earlier versions
        }
        
        if bottomPadding == 44
        {
            self.controller = SheetViewController(controller: vc!, sizes: [.fixed(499)])
        }
        else{
            self.controller = SheetViewController(controller: vc!, sizes: [.fixed(465)])
        }
        self.controller?.dismissOnOverlayTap = true
        self.present(self.controller!, animated: false, completion: nil)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkarray(){
        if (self.moviesArray.isEmpty || self.moviesArray.count == 0) {
            self.noMovieImageView.isHidden = false
            self.noMovieLabel.isHidden = false
        }else{
            self.noMovieImageView.isHidden = true
            self.noMovieLabel.isHidden = true
        }
    }
}

extension MoviesNewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isLoading {
            return 10
        } else {
            return moviesArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.isLoading {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moviesNewCell", for: indexPath) as! moviesNewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moviesNewCell", for: indexPath) as! moviesNewCell
            let object = self.moviesArray[indexPath.row]
            guard let thumbnail = object.thumbnail else {return UICollectionViewCell()}
            guard let url = URL(string: thumbnail) else {return UICollectionViewCell()}
                if let country_name = object.owner?.country_name
                {
                    cell.yearLabel.text = "\(country_name)\n\(object.movie_release ?? "")"
                }
            cell.movieImageView.sd_setImage(with: url, placeholderImage: nil, options: [], progress: nil, completed: nil)
            cell.titleLabel.text = object.title
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: (self.movieCollectionView.frame.width / 2) - 7.5, height: 270)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let videoObject = self.moviesArray[indexPath.row]
        let newVC = self.tabBarController as! TabbarController
        newVC.handleOpenVideoPlayer(for: videoObject)
    }
}

extension MoviesVC {
    
}
