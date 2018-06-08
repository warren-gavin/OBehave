//
//  OBTransitionDelegateBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 13/01/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/// Transition animation settings
public protocol OBTransitionDelegateBehaviorDataSource: OBBehaviorDataSource {
    var duration: TimeInterval           { get }
    var delay: TimeInterval              { get }
    var damping: CGFloat                 { get }
    var velocity: CGFloat                { get }
    var options: UIView.AnimationOptions { get }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController
}

extension OBTransitionDelegateBehaviorDataSource {
    public var duration: TimeInterval {
        return .defaultDuration
    }
    
    public var delay: TimeInterval {
        return .defaultDelay
    }

    public var damping: CGFloat {
        return .defaultDamping
    }
    
    public var velocity: CGFloat {
        return .defaultVelocity
    }
    
    public var options: UIView.AnimationOptions {
        return .defaultOptions
    }
    
    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController {
        return VanillaPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

/// Present a view controller modally with a custom transition
///
/// Specific types of transitions should extend this class and override
/// the animatePresentation(using:completion:) and animateDismissal(using:completion:)
/// methods to implement the exact type of transition needed
open class OBTransitionDelegateBehavior: OBBehavior, UIViewControllerTransitioningDelegate {
    private var isPresenting = true
    
    override open func setup() {
        super.setup()
        
        owner?.modalPresentationStyle = .custom
        owner?.transitioningDelegate  = self
    }

    /// Override this method to implement a specific type of transition as the view controller
    /// appears onscreen.
    ///
    /// - Parameters:
    ///   - transitionContext: Contains the presented and presenting views, controllers etc
    ///   - completion: completion handler on success or failure
    public func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) -> (() -> Void)? {
        return nil
    }
    
    /// Override this method to clean up after a specific type of transition as the view
    /// controller appears onscreen. This will be called in the presentation animation's
    /// completion handler
    ///
    /// - Returns: The cleanup code
    public func cleanupPresentation() -> ((Bool) -> Void)? {
        return nil
    }
    
    /// Override this method to implement a specific type of transition as the view controller
    /// is dismissed from the view hierarchy
    ///
    /// - Parameters:
    ///   - transitionContext: Contains the presented and presenting views, controllers etc
    ///   - completion: completion handler on success or failure
    public func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) -> (() -> Void)? {
        return nil
    }
    
    /// Override this method to clean up after a specific type of transition as the view
    /// controller is dismissed from the view hierarchy. This will be called in the dismissal
    /// animation's completion handler
    ///
    /// - Returns: The cleanup code
    public func cleanupDismissal() -> ((Bool) -> Void)? {
        return nil
    }
}

// MARK: - Transition animation properties
extension OBTransitionDelegateBehavior {
    public var duration: TimeInterval {
        let dataSource: OBTransitionDelegateBehaviorDataSource? = getDataSource()
        return dataSource?.duration ?? .defaultDuration
    }
    
    public var delay: TimeInterval {
        let dataSource: OBTransitionDelegateBehaviorDataSource? = getDataSource()
        return dataSource?.delay ?? .defaultDelay
    }
    
    public var damping: CGFloat {
        let dataSource: OBTransitionDelegateBehaviorDataSource? = getDataSource()
        return dataSource?.damping ?? .defaultDamping
    }
    
    public var velocity: CGFloat {
        let dataSource: OBTransitionDelegateBehaviorDataSource? = getDataSource()
        return dataSource?.velocity ?? .defaultVelocity
    }
    
    public var options: UIView.AnimationOptions {
        let dataSource: OBTransitionDelegateBehaviorDataSource? = getDataSource()
        return dataSource?.options ?? .defaultOptions
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension OBTransitionDelegateBehavior {
    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        let dataSource: OBTransitionDelegateBehaviorDataSource? = getDataSource()
        return dataSource?.presentationController(forPresented: presented, presenting: presenting, source: source) ??
               VanillaPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension OBTransitionDelegateBehavior: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let transition = (isPresenting ? animatePresentation   : animateDismissal)
        let completion = (isPresenting ? cleanupPresentation() : cleanupDismissal())
        
        guard let animation = transition(transitionContext) else {
            transitionContext.completeTransition(false)
            return
        }
    
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity,
                       options: options,
                       animations: animation) { finished in
            completion?(finished)
            transitionContext.completeTransition(finished)
        }
    }
}

// MARK: - Defaults
private extension TimeInterval {
    static let defaultDuration: TimeInterval = 0.67
    static let defaultDelay:    TimeInterval = 0.0
}

private extension CGFloat {
    static let defaultDamping:  CGFloat = 1.0
    static let defaultVelocity: CGFloat = 0.0
}

private extension UIView.AnimationOptions {
    static let defaultOptions: UIView.AnimationOptions = [.allowUserInteraction, .curveEaseInOut]
}

/// From the UIViewControllerTransitioningDelegate documentation:
/// "The default presentation controller does not add any views or content
/// to the view hierarchy."
///
/// How useless. Any transition must define a presentation controller that,
/// at the very least, adds the presented view to the container view, which
/// is what this boring class does.
private class VanillaPresentationController: UIPresentationController {
    override func presentationTransitionWillBegin() {
        if let presentedView = presentedView {
            containerView?.addSubview(presentedView)
        }
    }
}
