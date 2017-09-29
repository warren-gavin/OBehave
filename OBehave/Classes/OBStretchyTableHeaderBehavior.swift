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
            
            addObserver(self, forKeyPath: .imageViewImage, options: .new, context: nil)
        }
    }

    @IBOutlet public var tableView: UITableView? {
        didSet {
            guard let tableView = tableView, let tableHeaderView = tableView.tableHeaderView else {
                return
            }

            headerHeight = tableHeaderView.bounds.size.height
            addObserver(self, forKeyPath: .tableViewBounds, options: .new, context: nil)
            addObserver(self, forKeyPath: .tableViewFrame,  options: .new, context: nil)
            headerView = tableView.tableHeaderView
        }
    }
    
    // MARK: Private properties
    fileprivate var headerHeight: CGFloat = 0 {
        didSet {
            tableView?.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0)
            tableView?.contentOffset = CGPoint(x: 0, y: -headerHeight)
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
        case String.tableViewFrame:
            removeObserver(self, forKeyPath: .tableViewFrame)
            updateHeaderViewInView()

        case String.tableViewBounds:
            updateHeaderViewInView()

        case String.imageViewImage:
            headerImage = imageView?.image
            
        default:
            break
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: .tableViewBounds)
        removeObserver(self, forKeyPath: .imageViewImage)
    }
}

// MARK: - Private methods
private extension OBStretchyTableHeaderBehavior {
    func updateHeaderViewInView() {
        guard let tableView = tableView else {
            return
        }
        
        let dataSource: OBStretchyTableHeaderBehaviorDataSource? = getDataSource()
        let minHeaderHeight = dataSource?.minHeaderHeight ?? .minHeaderHeight
        let maxEffectDistance = dataSource?.maxEffectDistance ?? .maxEffectDistance
        
        let headerRect = CGRect(x: 0,
                                y: tableView.contentOffset.y,
                                width: tableView.bounds.size.width,
                                height: max(minHeaderHeight, -tableView.contentOffset.y))
        
        let percentage = max(0.0, min(1.0, (tableView.contentOffset.y + headerHeight) / maxEffectDistance))
        
        if let effectedImage = effect?.performEffect?(on: headerImage, percentage: percentage) as? UIImage {
            removeObserver(self, forKeyPath: .imageViewImage)
            imageView?.image = effectedImage
            addObserver(self, forKeyPath: .imageViewImage, options: .new, context: nil)
        }
        
        headerView?.frame = headerRect
    }
}

private extension String {
    static let tableViewFrame  = "tableView.frame"
    static let tableViewBounds = "tableView.bounds"
    static let imageViewImage  = "imageView.image"
}

private extension CGFloat {
    static let maxEffectDistance: CGFloat = -150.0
    static let minHeaderHeight: CGFloat = 88
}
