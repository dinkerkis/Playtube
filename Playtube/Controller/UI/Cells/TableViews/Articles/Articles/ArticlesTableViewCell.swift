//
//  ArticlesTableViewCell.swift
//  Playtube
//
//  Created by iMac on 31/05/23.
//  Copyright © 2023 ScriptSun. All rights reserved.
//

import UIKit
import UIView_Shimmer

class ArticlesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var articlesArray: [Article] = []
    var isLoading = true {
        didSet {
            collectionView.reloadData()
        }
    }
    var parentVC: BaseVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
        self.registerCollectionCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func registerCollectionCell() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(resource: R.nib.articlesCollectionViewCell), forCellWithReuseIdentifier: R.nib.articlesCollectionViewCell.identifier)
    }
    
}

// MARK: - Collection View Setup

extension ArticlesTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else {
            return self.articlesArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isLoading {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.articlesCollectionViewCell.identifier, for: indexPath) as! ArticlesCollectionViewCell
            return cell
        } else {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.articlesCollectionViewCell.identifier, for: indexPath) as! ArticlesCollectionViewCell
            let object = self.articlesArray[indexPath.row]
            cell.vc = parentVC
            cell.bind(object)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.setTemplateWithSubviews(isLoading, animate: true, viewBackgroundColor: .systemBackground)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 329.0, height: 329.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isLoading {
            let vc = R.storyboard.loggedUser.detailsArticlesVC()
            vc?.articlesData = self.articlesArray[indexPath.row]
            self.parentVC?.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
}
