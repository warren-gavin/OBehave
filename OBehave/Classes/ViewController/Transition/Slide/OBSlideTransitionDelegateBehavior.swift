//
//  OBSlideTransitionDelegateBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 10/01/17.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

public protocol OBSlideTransitionBehaviorDataSource: OBTransitionDelegateBehaviorDataSource {
    var slideInAngle:  CGFloat { get }
    var slideOutAngle: CGFloat { get }
}

public class OBSlideTransitionDelegateBehavior: OBTransitionDelegateBehavior {
    override public func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) -> (() -> Void)? {
        guard let presentedControllerView = transitionContext.view(forKey: .to),
            let presentedController = transitionContext.viewController(forKey: .to) else {
            return nil
        }
        
        var finalFrame = transitionContext.finalFrame(for: presentedController)
        finalFrame.origin = CGPoint(x: finalFrame.origin.x, y: finalFrame.origin.y + finalFrame.size.height)
        
        presentedControllerView.frame = finalFrame
        
        return {
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
        }
    }
    
    override public func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) -> (() -> Void)? {
        guard let presentingView = transitionContext.view(forKey: .from) else {
            return nil
        }
        
        return {
            var frame = presentingView.frame

            frame.origin = CGPoint(x: frame.origin.x, y: frame.origin.y + frame.size.height)
            presentingView.frame = frame
        }
    }
}
