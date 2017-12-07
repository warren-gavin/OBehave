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

public final class OBStretchyTableHeaderBehavior: OBBehavior {
    private var observeImageView: NSKeyValueObservation?
    private var observeTableView: NSKeyValueObservation?
    
    // MARK: Outlets
    @IBOutlet public var imageView: UIImageView? {
        didSet {
            headerImage = imageView?.image
            setImageObserver()
        }
    }

    @IBOutlet public var tableView: UITableView? {
        didSet {
            guard let tableView = tableView, let tableHeaderView = tableView.tableHeaderView else {
                return
            }

            observeTableView = tableView.observe(\.bounds, options: .new) { [unowned self] (_, _) in
                self.updateHeaderViewInView()
            }
            
            headerHeight = tableHeaderView.bounds.size.height
            headerView   = tableView.tableHeaderView
        }
    }
    
    // MARK: Private properties
    private var headerHeight: CGFloat = 0 {
        didSet {
            tableView?.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0)
            tableView?.contentOffset = CGPoint(x: 0, y: -headerHeight)
        }
    }
    
    private var headerView: UIView? {
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
    
    private var headerImage: UIImage?
}

// MARK: - Private methods
private extension OBStretchyTableHeaderBehavior {
    private func setImageObserver() {
        guard let imageView = imageView else {
            return
        }
        
        observeImageView?.invalidate()
        
        observeImageView = imageView.observe(\.image, options: .new) { [unowned self] (imageView, _) in
            self.headerImage = imageView.image
        }
    }
    
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
        
        if let effectedImage = effect?.performEffect(on: headerImage, percentage: percentage) as? UIImage {
            observeImageView?.invalidate()
            imageView?.image = effectedImage
            setImageObserver()
        }
        
        headerView?.frame = headerRect
    }
}

private extension String {
    static let tableViewBounds = "tableView.bounds"
    static let imageViewImage  = "imageView.image"
}

private extension CGFloat {
    static let maxEffectDistance: CGFloat = -150.0
    static let minHeaderHeight: CGFloat = 88
}
