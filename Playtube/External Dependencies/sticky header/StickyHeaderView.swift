//
//  StickyHeaderView.swift
//  TableStickyViewExample
//
//  Created by Yusuf Demirci on 26.11.2017.
//  Copyright © 2017 demirciy. All rights reserved.
//

import UIKit

internal class StickyHeaderView: UIView {
    weak var parent: StickyHeader?
    
    internal static var KVOContext = 0
    
    override func willMove(toSuperview view: UIView?) {
        if let view = self.superview, view.isKind(of:UIScrollView.self), let parent = self.parent {
            view.removeObserver(parent, forKeyPath: "contentOffset", context: &StickyHeaderView.KVOContext)
        }
    }
    
    override func didMoveToSuperview() {
        if let view = self.superview, view.isKind(of:UIScrollView.self), let parent = parent {
            view.addObserver(parent, forKeyPath: "contentOffset", options: .new, context: &StickyHeaderView.KVOContext)
        }
    }
}

private var xoStickyHeaderKey: UInt8 = 0

extension UIScrollView {
    
    public var stickyHeader: StickyHeader! {
        get {
            var header = objc_getAssociatedObject(self, &xoStickyHeaderKey) as? StickyHeader
            
            if header == nil {
                header = StickyHeader()
                header!.scrollView = self
                objc_setAssociatedObject(self, &xoStickyHeaderKey, header, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return header!
        }
    }
}
