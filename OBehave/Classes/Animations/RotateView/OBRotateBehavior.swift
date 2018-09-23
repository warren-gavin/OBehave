//
//  OBRotateBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 30/10/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

public final class OBRotateBehavior: OBAnimatingViewBehavior {
    @IBInspectable public var angle: CGFloat = .rotationAngle
    
    // MARK: OBAnimatingViewBehaviorDelegate
    override public func executeAnimation(_ behavior: OBAnimatingViewBehavior) {
        guard let animatingViews = animatingViews else {
            return
        }
        
        for view in animatingViews {
            animateRotation(view)
        }
    }
}

private extension OBRotateBehavior {
    func angleInRadians(_ reverse: Bool = false) -> CGFloat {
        let pi = (reverse ? CGFloat(Double.pi) : CGFloat(-Double.pi))
        return angle * pi / CGFloat(180.0)
    }
    
    func animateRotation(_ view: UIView) {
        if fadeIn {
            view.alpha = 0.0
        }
        
        let applyRotation = { [unowned self] in
            view.alpha = 1.0
            view.transform = view.transform.rotated(by: self.angleInRadians())
        }
        
        let undoRotation =  { [unowned self] (finished: Bool) -> Void in
            if finished && self.autoReverse {
                view.transform = view.transform.rotated(by: self.angleInRadians(true))
            }
        }
        
        let options = (autoReverse ? UIView.AnimationOptions.autoreverse : UIView.AnimationOptions())
        
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: velocity,
                       options: options,
                       animations: applyRotation,
                       completion: undoRotation)
    }
}

private extension CGFloat {
    static let rotationAngle: CGFloat = 90.0
}
