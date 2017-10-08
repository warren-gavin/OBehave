//
//  OBResizeViewBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 08/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

public final class OBResizeViewBehavior: OBAnimatingViewBehavior {
    @IBOutlet public var sizeConstraints: [NSLayoutConstraint]?
    @IBInspectable public var sizeFactor: CGFloat = 1.0
    
    // MARK: OBAnimatingViewBehaviorDelegate
    override public func executeAnimation(_ behavior: OBAnimatingViewBehavior) {
        changeToFrameSize(sizeFactor, animate: true) { [unowned self] finished in
            if finished && self.autoReverse {
                self.changeToFrameSize(1/self.sizeFactor, animate: true)
            }
        }
    }
}

private extension OBResizeViewBehavior {
    func changeToFrameSize(_ size: CGFloat, animate: Bool, completion: ((Bool) -> Void)? = nil) {
        let resize = { [unowned self] in
            guard let animatingViews = self.animatingViews, let constraints = self.sizeConstraints else {
                return
            }
            
            for constraint in constraints {
                constraint.constant *= size
            }
            
            self.owner?.view.layoutIfNeeded()
            
            for view in animatingViews {
                view.setNeedsDisplay()
            }
        }
        
        if animate {
            UIView.animate(withDuration: duration,
                           delay: delay,
                           options: .allowUserInteraction,
                           animations: resize,
                           completion: completion)
        }
        else {
            resize()
        }
    }
}
