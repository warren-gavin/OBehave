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
    fileprivate lazy var backgroundView: UIView? = {
        return self.backgroundViewForPresentation()
    }()
    
    func backgroundViewForPresentation() -> UIView? {
        guard let containerView = containerView else {
            return nil
        }
        
        let backroundView = UIView(frame: containerView.bounds)
        
        backroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backroundView.backgroundColor = UIColor.clear
        
        return backroundView
    }
    
    public weak var dataSource: OBInsetPresentationControllerDataSource?
    
    // MARK: UIPresentationController
    
    /**
     Animates the appearance of the blurred background
     */
    override public func presentationTransitionWillBegin() {
        guard let containerView = containerView, let backgroundView = backgroundView, let presentedView = presentedView else {
            return
        }
        
        backgroundView.alpha = 0.0
        
        containerView.addSubview(backgroundView)
        containerView.addSubview(presentedView)
        
        let showBackgroundView = { (_: UIViewControllerTransitionCoordinatorContext) -> Void in
            backgroundView.alpha = 1.0
        }
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: showBackgroundView, completion: nil)
    }
    
    /**
     Handles the end of the presentation animation
     
     - parameter completed: Flag for animation completion
     */
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backgroundView?.removeFromSuperview()
        }
    }
    
    /**
     Animated the removal of the blurred background from the screen
     */
    override public func dismissalTransitionWillBegin() {
        guard let backgroundView = backgroundView else {
            return
        }
        
        let hideBackgroundView = { (_: UIViewControllerTransitionCoordinatorContext) -> Void in
            backgroundView.alpha = 0.0
        }
        
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: hideBackgroundView, completion: nil)
    }
    
    /**
     Handles the end of the dismissal animation
     
     - parameter completed: Flag for animation completion
     */
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView?.removeFromSuperview()
        }
    }
    
    /**
     The frame for the presented view, set to the size defined by the normalised width and height values
     
     - returns: Frame inset by the defined width and height values
     */
    override public var frameOfPresentedViewInContainerView : CGRect {
        guard let frame = containerView?.bounds, let dataSource = dataSource else {
            return super.frameOfPresentedViewInContainerView
        }
        
        switch dataSource.insets {
        case .normalised(let width, let height):
            return frame.insetBy(dx: (frame.size.width  * (1 - width))  / 2,
                                 dy: (frame.size.height * (1 - height)) / 2)
            
        case .scalar(let width, let height):
            return frame.insetBy(dx: width, dy: height)
        }

    }
    
    /**
     Handles rotation or size class changes
     
     - parameter size:        New frame size
     - parameter coordinator: Animation coordinator
     */
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let containerView = containerView, let backgroundView = backgroundView else {
            return
        }
        
        let resetBackgroundViewFrame = { (_: UIViewControllerTransitionCoordinatorContext) -> Void in
            backgroundView.frame = containerView.bounds
        }
        
        coordinator.animate(alongsideTransition: resetBackgroundViewFrame, completion: nil)
    }
}


private extension UIColor {
    static let defaultDimmingColor = UIColor.black.withAlphaComponent(0.2)
}
