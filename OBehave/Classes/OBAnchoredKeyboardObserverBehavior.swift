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
public class OBAnchoredKeyboardObserverBehavior: OBKeyboardObserverBehavior {
    @IBOutlet public weak var anchorConstraint: NSLayoutConstraint? {
        didSet {
            self.originalAnchorConstant = self.anchorConstraint?.constant
        }
    }
    
    private var originalAnchorConstant: CGFloat?
    private var keyboardStartPosition: CGFloat?
    
    override public func onKeyboardAppear(in rect: CGRect) {
        let newKeyboardStartPosition = rect.origin.y
        
        if let keyboardStartPosition = self.keyboardStartPosition {
            if keyboardStartPosition == newKeyboardStartPosition {
                return
            }
            
            self.anchorConstraint?.constant -= newKeyboardStartPosition - keyboardStartPosition
            self.keyboardStartPosition = newKeyboardStartPosition
            
            return
        }
        
        self.keyboardStartPosition = newKeyboardStartPosition
        self.anchorConstraint?.constant += rect.height
    }
    
    override public func onKeyboardDisappear(in rect: CGRect) {
        if let originalAnchorConstant = self.originalAnchorConstant {
            self.anchorConstraint?.constant = originalAnchorConstant
        }
        
        self.keyboardStartPosition = nil
    }
}
