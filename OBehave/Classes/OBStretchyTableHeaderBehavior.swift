//
//  OBStretchyTableHeaderBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 02/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

public protocol OBStretchyTableHeaderBehaviorDataSource: OBBehaviorDataSource {
    var maxEffectDistance: CGFloat { get }
    var minHeaderHeight: CGFloat { get }
}

public class OBStretchyTableHeaderBehavior: OBBehavior {
    // MARK: Outlets
    @IBOutlet public var imageView: UIImageView? {
        didSet {
            guard let _ = imageView else {
                return
            }
            
            self.addObserver(self, forKeyPath: "imageView.image", options: .new, context: nil)
        }
    }

    @IBOutlet public var tableView: UITableView? {
        didSet {
            guard let tableView = self.tableView, let tableHeaderView = tableView.tableHeaderView else {
                return
            }

            self.headerHeight = tableHeaderView.bounds.size.height
            self.addObserver(self, forKeyPath: "tableView.bounds", options: .new, context: nil)
            self.addObserver(self, forKeyPath: "tableView.frame",  options: .new, context: nil)
            self.headerView = tableView.tableHeaderView
        }
    }
    
    // MARK: Private properties
    fileprivate var headerHeight: CGFloat = 0 {
        didSet {
            self.tableView?.contentInset = UIEdgeInsetsMake(self.headerHeight, 0, 0, 0)
            self.tableView?.contentOffset = CGPoint(x: 0, y: -self.headerHeight)
        }
    }
    
    fileprivate var headerView: UIView? {
        didSet {
            guard let headerView = headerView, let tableView = tableView else {
                return
            }
            
            tableView.tableHeaderView = nil
            updateHeaderViewInView()

            headerView.clipsToBounds = true
            tableView.insertSubview(headerView, at: 0)
            tableView.bringSubview(toFront: headerView)
        }
    }
    
    fileprivate var headerImage: UIImage?
    
    // MARK: Public methods
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else {
            return
        }
        
        switch keyPath {
        case "tableView.frame":
            self.removeObserver(self, forKeyPath: "tableView.frame")
            self.updateHeaderViewInView()

        case "tableView.bounds":
            self.updateHeaderViewInView()

        case "imageView.image":
            headerImage = imageView?.image
            
        default:
            break
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "tableView.frame")
        self.removeObserver(self, forKeyPath: "tableView.bounds")
        self.removeObserver(self, forKeyPath: "imageView.image")
    }
}

// MARK: - Private methods
private extension OBStretchyTableHeaderBehavior {
    func updateHeaderViewInView() {
        guard let tableView = self.tableView else {
            return
        }
        
        let dataSource: OBStretchyTableHeaderBehaviorDataSource? = getDataSource()
        let minHeaderHeight = dataSource?.minHeaderHeight ?? .minHeaderHeight
        let maxEffectDistance = dataSource?.maxEffectDistance ?? .maxEffectDistance
        
        let headerRect = CGRect(x: 0,
                                y: tableView.contentOffset.y,
                                width: tableView.bounds.size.width,
                                height: max(minHeaderHeight, -tableView.contentOffset.y))
        
        let percentage = max(0.0, min(1.0, (tableView.contentOffset.y + self.headerHeight) / maxEffectDistance))
        if let effectedImage = self.effect?.performEffect?(on: self.headerImage, percentage: percentage) as? UIImage {
            self.removeObserver(self, forKeyPath: "imageView.image")
            self.imageView?.image = effectedImage
            self.addObserver(self, forKeyPath: "imageView.image", options: .new, context: nil)
        }
        
        self.headerView?.frame = headerRect
    }
}

private extension CGFloat {
    static let maxEffectDistance: CGFloat = -150.0
    static let minHeaderHeight: CGFloat = 88
}
