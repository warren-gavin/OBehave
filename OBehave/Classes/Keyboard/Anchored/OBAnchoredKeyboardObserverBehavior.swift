//
//  OBAnchoredKeyboardObserverBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 12/03/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/**
 Reduce a constraint by the keyboard's height when it appears
 
 This behavior only makes sense if the constraint is a view's bottom constraint
 */
public final class OBAnchoredKeyboardObserverBehavior: OBKeyboardObserverBehavior {
    @IBOutlet public weak var anchorConstraint: NSLayoutConstraint? {
        didSet {
            originalAnchorConstant = anchorConstraint?.constant
        }
    }
    
    private var originalAnchorConstant: CGFloat?
    private var keyboardStartPosition: CGFloat?
    
    override public func onKeyboardAppear(in rect: CGRect) {
        let newKeyboardStartPosition = rect.origin.y
        
        if let keyboardStartPosition = keyboardStartPosition {
            if keyboardStartPosition == newKeyboardStartPosition {
                return
            }
            
            anchorConstraint?.constant -= newKeyboardStartPosition - keyboardStartPosition
        }
        else {
            let tabBar = owner?.tabBarController?.tabBar
            anchorConstraint?.constant += rect.height - (tabBar?.bounds.size.height ?? 0)
        }
        
        keyboardStartPosition = newKeyboardStartPosition
    }
    
    override public func onKeyboardDisappear(in rect: CGRect) {
        if let originalAnchorConstant = originalAnchorConstant {
            anchorConstraint?.constant = originalAnchorConstant
        }
        
        keyboardStartPosition = nil
    }
}
