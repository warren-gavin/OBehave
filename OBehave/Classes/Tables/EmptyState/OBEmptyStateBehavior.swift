//
//  OBEmptyStateBehavior.swift
//  OBehave
//
//  Created by Warren on 18/02/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

// MARK: - OBEmptyStateBehaviorDataSource
public protocol OBEmptyStateBehaviorDataSource {
    func viewToDisplayOnEmpty(for behavior: OBEmptyStateBehavior?) -> UIView?
}

// MARK: - Views that can have empty states
enum DataSetView {
    case table(UITableView)
    case collection(UICollectionView)
}

// MARK: - Behavior
public class OBEmptyStateBehavior: OBBehavior {
    @IBOutlet public var scrollView: UIScrollView! {
        didSet {
            switch scrollView {
            case let view as UITableView:
                view.tableFooterView = UIView()
                dataSetView = .table(view)
                
            case let view as UICollectionView:
                dataSetView = .collection(view)
                
            default:
                dataSetView = nil
            }
        }
    }
    
    private var dataSetView: DataSetView? {
        didSet {
            guard let displayingView = dataSetView?.view as? DataDisplaying else {
                return
            }
            
            interceptDataLoading()

            displayingView.emptyStateDataSource = getDataSource()
        }
    }
}

private extension OBEmptyStateBehavior {
    func interceptDataLoading() {
        guard
            let viewClass = dataSetView?.class,
            let viewClassType = viewClass as? DataDisplaying.Type,
            !viewClassType.isSwizzled
        else {
            return
        }
        
        zip(viewClassType.swizzledMethods, viewClassType.originalMethods).forEach {
            guard
                let swizzledMethod = class_getInstanceMethod(viewClass, $0),
                let originalMethod = class_getInstanceMethod(viewClass, $1)
            else {
                return
            }
            
            method_exchangeImplementations(swizzledMethod, originalMethod)
        }
        
        viewClassType.isSwizzled = true
    }
}

// MARK: - DataSetView extension
extension DataSetView {
    var view: UIView? {
        switch self {
        case .table(let view):
            return view
            
        case .collection(let view):
            return view
        }
    }
    
    var `class`: AnyClass? {
        switch self {
        case .table(_):
            return UITableView.self
            
        case .collection(_):
            return UICollectionView.self
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .table(let table):
            return table.isEmpty
            
        case .collection(let collection):
            return collection.isEmpty
        }
    }
}

// MARK: - DataDisplaying protocol
protocol DataDisplaying: class {
    var numberOfSections: Int { get }
    var sectionCount: (Int) -> Int { get }
    
    static var originalMethods: [Selector] { get }
    static var swizzledMethods: [Selector] { get }
}

extension DataDisplaying where Self: UIView {
    var showEmptyState: Bool {
        get {
            return isEmpty
        }
        
        set {
            guard let emptyStateView = emptyStateView else {
                return
            }

            if newValue {
                addSubview(emptyStateView)
                
                emptyStateView.translatesAutoresizingMaskIntoConstraints = false
                emptyStateView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                emptyStateView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
                
                emptyStateView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor).isActive = true
                emptyStateView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
                emptyStateView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor).isActive = true
                emptyStateView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
                
                layoutIfNeeded()
            }
            else {
                emptyStateView.removeFromSuperview()
                self.emptyStateView = nil
            }

            emptyStateView.alpha = (newValue ? 1.0 : 0.0)
        }
    }
}

private struct Constants {
    static var isSwizzledKey = "com.apokrupto.OBEmptyStateBehavior.isSwizzled"
    static var emptyStateViewKey = "com.apokrupto.OBEmptyDateSetBehavior.emptyStateView"
    static var emptyStateDataSourceKey = "com.apokrupto.OBEmptyDateSetBehavior.emptyStateDataSource"
}

extension DataDisplaying {
    var isEmpty: Bool {
        return 0 == (0 ..< numberOfSections).reduce(0) { (result, section) in
            result + sectionCount(section)
        }
    }
    
    var emptyStateView: UIView? {
        get {
            if let emptyStateView = objc_getAssociatedObject(self, &Constants.emptyStateViewKey) as? UIView {
                return emptyStateView
            }

            let emptyStateView = emptyStateDataSource?.viewToDisplayOnEmpty(for: nil)
            objc_setAssociatedObject(self, &Constants.emptyStateViewKey, emptyStateView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return emptyStateView
        }
        
        set {
            objc_setAssociatedObject(self, &Constants.emptyStateViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var emptyStateDataSource: OBEmptyStateBehaviorDataSource? {
        get {
            return objc_getAssociatedObject(self, &Constants.emptyStateDataSourceKey) as? OBEmptyStateBehaviorDataSource
        }
        
        set {
            objc_setAssociatedObject(self, &Constants.emptyStateDataSourceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    static var isSwizzled: Bool {
        get {
            return objc_getAssociatedObject(self, &Constants.isSwizzledKey) as? Bool ?? false
        }
        
        set {
            objc_setAssociatedObject(self, &Constants.isSwizzledKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - Extending table and collection views to conform to DataDisplaying
extension UITableView: DataDisplaying {
    var sectionCount: (Int) -> Int {
        return numberOfRows
    }
    
    @objc func ob_reloadData() {
        showEmptyState = isEmpty
        return ob_reloadData()
    }
    
    @objc func ob_endUpdates() {
        showEmptyState = isEmpty
        return ob_endUpdates()
    }
    
    static let originalMethods = [
        #selector(UITableView.reloadData),
        #selector(UITableView.endUpdates)
    ]

    static let swizzledMethods = [
        #selector(UITableView.ob_reloadData),
        #selector(UITableView.ob_endUpdates)
    ]
}

extension UICollectionView: DataDisplaying {
    var sectionCount: (Int) -> Int {
        return numberOfItems
    }
    
    @objc func ob_reloadData() {
        defer {
            showEmptyState = isEmpty
        }
        
        return ob_reloadData()
    }
    
    @objc func ob_performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        return ob_performBatchUpdates(updates) { ok in
            completion?(ok)
            self.showEmptyState = self.isEmpty
        }
    }
    
    static let originalMethods = [
        #selector(UICollectionView.reloadData),
        #selector(UICollectionView.performBatchUpdates(_:completion:))
    ]
    
    static let swizzledMethods = [
        #selector(UICollectionView.ob_reloadData),
        #selector(UICollectionView.ob_performBatchUpdates(_:completion:))
    ]
}
