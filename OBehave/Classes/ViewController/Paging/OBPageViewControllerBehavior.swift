//
//  OBPageViewControllerBehavior.swift
//  OBehave
//
//  Created by WarrenGavin on 17/07/2017.
//  Copyright © 2017 Apokrupto. All rights reserved.
//

import UIKit

public protocol OBPageViewControllerBehaviorDataSource: OBBehaviorDataSource {
    var controllers: [UIViewController] { get }
    var pageIndicatorTintColor: UIColor? { get }
    var currentPageIndicatorTintColor: UIColor? { get }
}

public final class OBPageViewControllerBehavior: OBBehavior {
    private lazy var viewControllers: [UIViewController] = {
        guard let dataSource: OBPageViewControllerBehaviorDataSource = self.getDataSource() else {
            return []
        }
        
        return dataSource.controllers
    }()
    
    private var pendingSelectedIndex = 0
    private var selectedIndex = 0 {
        didSet {
            pageControl?.currentPage = selectedIndex
            
            if !showPageControlOnLast {
                UIView.animate(withDuration: 0.3) {
                    self.pageControl?.alpha = (self.selectedIndex == self.viewControllers.count - 1 ? 0.0 : 1.0)
                }
            }
        }
    }
    
    private var pageControl: UIPageControl?
    
    func createPageControl() -> UIPageControl {
        let pageControl = UIPageControl(frame: .zero)
        let dataSource: OBPageViewControllerBehaviorDataSource? = getDataSource()
        
        pageControl.pageIndicatorTintColor = dataSource?.pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = dataSource?.currentPageIndicatorTintColor
        pageControl.numberOfPages = dataSource?.controllers.count ?? 0
        
        pageViewController.view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.centerXAnchor.constraint(equalTo: pageViewController.view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: pageViewController.view.bottomAnchor, constant: -24).isActive = true
        pageControl.widthAnchor.constraint(equalTo: pageViewController.view.widthAnchor).isActive = true
        
        return pageControl
    }
    
    @IBInspectable public var showPageControl: Bool = false {
        didSet {
            if showPageControl && pageControl == nil && pageViewController != nil {
                pageControl = createPageControl()
            }
            else if !showPageControl {
                pageControl?.removeFromSuperview()
                pageControl = nil
            }
        }
    }
    
    @IBInspectable public var showPageControlOnLast = false
    
    @IBOutlet public var pageViewController: UIPageViewController! {
        didSet {
            pageViewController.dataSource = self
            pageViewController.delegate   = self
            
            if showPageControl {
                pageControl = createPageControl()
            }
            
            if let firstViewController = viewControllers.first {
                pageViewController.setViewControllers([firstViewController],
                                                      direction: .forward,
                                                      animated: false,
                                                      completion: nil)
            }
        }
    }
    
    public override func setup() {
        super.setup()
        
        if let controller = owner as? UIPageViewController, pageViewController == nil {
            pageViewController = controller
        }
    }
}

extension OBPageViewControllerBehavior: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.index(of: viewController), canMoveBack(from: index) else {
            return nil
        }
        
        return viewControllers[index - 1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.index(of: viewController), canMoveForward(from: index) else {
            return nil
        }

        return viewControllers[index + 1]
    }
}

extension OBPageViewControllerBehavior: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pendingViewController = pendingViewControllers.first, let index = viewControllers.index(of: pendingViewController) else {
            return
        }
        
        pendingSelectedIndex = index
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        if completed {
            selectedIndex = pendingSelectedIndex
        }
    }
}

private extension OBPageViewControllerBehavior {
    func canMoveForward(from index: Int) -> Bool {
        guard !viewControllers.isEmpty else {
            return false
        }

        return 0 ..< viewControllers.count - 1 ~= index
    }
    
    func canMoveBack(from index: Int) -> Bool {
        guard !viewControllers.isEmpty else {
            return false
        }

        return 1 ..< viewControllers.count ~= index
    }
}
