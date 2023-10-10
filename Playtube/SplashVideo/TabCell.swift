//
//  TabCell.swift
//  TabsExample
//
//  Created by John Codeos on 5/22/20.
//  Copyright © 2020 John Codeos. All rights reserved.
//

import UIKit

class TabCell: UICollectionViewCell {
    private var tabSV: UIStackView!
    
    var tabTitle: UILabel!
        
    var indicatorView: UIView!
    
    var indicatorColor: UIColor = .black
    
    override var isSelected: Bool {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3) {
                    self.indicatorView.backgroundColor = self.isSelected ? self.indicatorColor : UIColor.clear
                    self.tabTitle.textColor = self.isSelected ? self.indicatorColor : UIColor(named: "Label_Colors_Secondary")
                    self.layoutIfNeeded()
                }
            }
        }
    }
    
    var tabViewModel: Tab? {
        didSet {
            tabTitle.text = tabViewModel?.title
            self.tabTitle.textColor = self.isSelected ? self.indicatorColor : UIColor(named: "Label_Colors_Secondary")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tabSV = UIStackView()
        tabSV.axis = .horizontal
        tabSV.distribution = .equalCentering
        tabSV.alignment = .center
        tabSV.spacing = 0.0
        addSubview(tabSV)
     
        // Tab Title
        tabTitle = UILabel()
        tabTitle.textAlignment = .center
        self.tabSV.addArrangedSubview(tabTitle)
        
        // TabSv Constraints
        tabSV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabSV.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tabSV.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        setupIndicatorView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tabTitle.text = ""
    }
    
    func setupIndicatorView() {
        indicatorView = UIView()
        addSubview(indicatorView)
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.cornerRadiusV = 1.5
        NSLayoutConstraint.activate([
            indicatorView.heightAnchor.constraint(equalToConstant: 3),
            indicatorView.widthAnchor.constraint(equalToConstant: self.bounds.width),
//            indicatorView.centerXAnchor.constraint(equalTo: self.tabTitle.centerXAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
