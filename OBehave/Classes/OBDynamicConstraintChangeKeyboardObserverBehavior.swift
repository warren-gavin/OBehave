//
//  OBDynamicConstraintChangeKeyboardObserverBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 04/02/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/// Reduce a constraint by a factor when a keyboard appears
public class OBDynamicConstraintChangeKeyboardObserverBehavior: OBKeyboardObserverBehavior {
    @IBOutlet public var constraints: [NSLayoutConstraint]?
    @IBInspectable public var resizeFactor: CGFloat = 0.5
    
    override public func onKeyboardAppear(in rect: CGRect) {
        super.onKeyboardAppear(in: rect)
        constraints?.forEach { $0.constant *= resizeFactor }
        locked = true
    }
    
    override public func onKeyboardDisappear(in rect: CGRect) {
        super.onKeyboardDisappear(in: rect)
        constraints?.forEach { $0.constant /= resizeFactor }
    }
}
