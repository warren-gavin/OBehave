//
//  OBInsetPresentationController.swift
//  OBehave
//
//  Created by Warren Gavin on 10/01/17.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

public enum OBPresentationInsets {
    case normalised(CGFloat, CGFloat)
    case scalar(CGFloat, CGFloat)
    
    public static let zero: OBPresentationInsets = .scalar(0, 0)
}

public protocol OBInsetPresentationControllerDataSource: class {
    var insets: OBPresentationInsets { get }
    var dimmingColor: UIColor { get }
}

extension OBInsetPresentationControllerDataSource {
    public var insets: OBPresentationInsets {
        return .zero
    }
    
    public var dimmingColor: UIColor {
        return .defaultDimmingColor
    }
}

public class OBInsetPresentationController: UIPresentationController {
    fileprivate lazy var dimmingView: UIView = {
        let view = UIView(frame: self.containerView?.bounds ?? .zero)
        
        view.alpha = 0.0
        view.backgroundColor = self.dataSource?.dimmingColor ?? .defaultDimmingColor
        
        return view
    }()
    
    public weak var dataSource: OBInsetPresentationControllerDataSource?
    
    override public func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView else {
            return
        }
        
        dimmingView.frame = containerView.bounds
        
        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView)
        
        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            let presentationAnimation: (UIViewControllerTransitionCoordinatorContext) -> Void = { [unowned self] _ in
                self.dimmingView.alpha = 1.0
            }
            
            transitionCoordinator.animate(alongsideTransition: presentationAnimation, completion: nil)
        }
    }
    
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
            presentedView?.removeFromSuperview()
        }
    }
    
    override public func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else {
            return
        }
        
        let dismissalAnimation: (UIViewControllerTransitionCoordinatorContext) -> Void = { [unowned self] _ in
            self.dimmingView.alpha = 0.0
        }
        
        transitionCoordinator.animate(alongsideTransition: dismissalAnimation, completion: nil)
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let frame = containerView?.bounds, let dataSource = dataSource else {
            return containerView?.bounds ?? .zero
        }
        
        switch dataSource.insets {
        case .normalised(let width, let height):
            return frame.insetBy(dx: (frame.size.width  * (1 - width))  / 2,
                                 dy: (frame.size.height * (1 - height)) / 2)
            
        case .scalar(let width, let height):
            return frame.insetBy(dx: width, dy: height)
        }
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let containerView = containerView else {
            return
        }
        
        let animation: (UIViewControllerTransitionCoordinatorContext) -> Void = { [unowned self] _ in
            self.dimmingView.frame = containerView.bounds
        }

        coordinator.animate(alongsideTransition: animation, completion: nil)
    }
}

private extension UIColor {
    static let defaultDimmingColor = UIColor.black.withAlphaComponent(0.2)
}
