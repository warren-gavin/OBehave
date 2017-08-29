//
//  OBStretchyTableHeaderBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 02/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

class OBStretchyTableHeaderBehavior: OBBehavior {
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var tableView: UITableView? {
        didSet {
            guard let tableView = tableView, let tableHeaderView = tableView.tableHeaderView else {
                return
            }
            
            headerHeight = tableHeaderView.bounds.size.height
            addObserver(self, forKeyPath: "tableView.bounds", options: .new, context: nil)
            addObserver(self, forKeyPath: "tableView.frame",  options: .new, context: nil)
            headerView = tableView.tableHeaderView
        }
    }
    
    fileprivate var headerHeight: CGFloat = 0 {
        didSet {
            tableView?.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0)
            tableView?.contentOffset = CGPoint(x: 0, y: -headerHeight)
        }
    }
    
    fileprivate var headerView: UIView? {
        didSet {
            guard let headerView = headerView else {
                return
            }
            
            tableView?.tableHeaderView = nil
            updateHeaderViewInView()
            
            headerView.clipsToBounds = true
            tableView?.insertSubview(headerView, at: 0)
        }
    }
    
    fileprivate lazy var headerImage: UIImage? = self.imageView?.image?.copy() as? UIImage
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "tableView.frame" {
            removeObserver(self, forKeyPath: "tableView.frame")
        }
        
        updateHeaderViewInView()
    }
    
    deinit {
        removeObserver(self, forKeyPath: "tableView.frame")
        removeObserver(self, forKeyPath: "tableView.bounds")
    }
}

private extension OBStretchyTableHeaderBehavior {
    func updateHeaderViewInView() {
        guard let tableView = tableView else {
            return
        }
        
        let headerRect = CGRect(x: 0,
                                y: tableView.contentOffset.y,
                                width: tableView.bounds.size.width,
                                height: -tableView.contentOffset.y)
        
        let percentage: CGFloat = max(0.0, min(1.0, (tableView.contentOffset.y + headerHeight) / .maxEffectDistance))
        if let effectedImage = effect?.performEffectOnObject?(headerImage, percentage: percentage) as? UIImage {
            imageView?.image = effectedImage
        }
        
        headerView?.frame = headerRect
    }
}

private extension CGFloat {
    static let maxEffectDistance: CGFloat = -150.0
}
