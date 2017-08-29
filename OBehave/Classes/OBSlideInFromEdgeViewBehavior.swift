//
//  OBSlideInFromEdgeViewBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 25/10/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

public final class OBSlideInFromEdgeViewBehavior: OBAnimatingViewBehavior {
    @IBOutlet public var slideIntoViewFromConstraints: [NSLayoutConstraint]?
    
    // MARK: OBAnimatingViewBehaviorDelegate
    override public func prepareForAnimation(_ behavior: OBAnimatingViewBehavior) {
        makeViewsHidden(true, animated: false)
    }
    
    override public func executeAnimation(_ behavior: OBAnimatingViewBehavior) {
        makeViewsHidden(false, animated: true)
    }
    
    override public func reverseAnimation(_ behavior: OBAnimatingViewBehavior) {
        makeViewsHidden(true, animated: true)
    }
}

private extension OBSlideInFromEdgeViewBehavior {
    func setView(_ view: UIView?, constraints: [NSLayoutConstraint]?, hidden: Bool, animated: Bool) {
        if let view = view, let constraints = constraints {
            let setLayoutConstraints = { [unowned self] in
                if self.fadeIn {
                    view.alpha = (hidden ? 0.0 : 1.0)
                }
                
                for constraint in constraints {
                    constraint.constant = -constraint.constant
                }
                
                self.owner?.view.layoutIfNeeded()
            }
            
            if animated {
                UIView.animate(withDuration: duration,
                               delay: delay,
                               options: UIViewAnimationOptions.allowUserInteraction,
                               animations: setLayoutConstraints,
                               completion: nil)
            }
            else {
                setLayoutConstraints()
            }
        }
    }
    
    func constraintsFromView(_ view: UIView) -> [NSLayoutConstraint]? {
        guard let constraints = slideIntoViewFromConstraints else {
            return nil
        }
        
        let viewConstraintsOnly = { (constraint: NSLayoutConstraint) -> Bool in
            constraint.firstItem as! NSObject == view || constraint.secondItem as! NSObject == view
        }
        
        return constraints.filter(viewConstraintsOnly)
    }
    
    func makeViewsHidden(_ hidden: Bool, animated: Bool) {
        guard let animatingViews = animatingViews else {
            return
        }
        
        for view in animatingViews {
            setView(view, constraints: constraintsFromView(view), hidden: hidden, animated: animated)
        }
    }
}
