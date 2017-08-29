//
//  OBTapToDismissKeyboardBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 27/03/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/// Behaviour that dismisses a keyboard if it's present when the user taps on the screen away from the keyboard
class OBTapToDismissKeyboardBehavior: OBBehavior {
    override func setup() {
        super.setup()

        // setup() is called before our view controller has a view. We set an observer to
        // pick up on when the view is created so we can then add the gesture recogniser
        addObserver(self, forKeyPath: "owner.view", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                                         of object: Any?,
                                         change: [NSKeyValueChangeKey : Any]?,
                                         context: UnsafeMutableRawPointer?) {
        owner?.view.addGestureRecognizer(tapGesture)
        removeObserver(self, forKeyPath: "owner.view")
    }
    
    /// Gesture recogniser for the tap to dismiss the keyboard
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: .dismiss)
        gesture.cancelsTouchesInView = false
        
        return gesture
    }()
    
    func dismissKeyboard(_: UITapGestureRecognizer) {
        owner?.view.endEditing(true)
    }
}

private extension Selector {
    static let dismiss = #selector(OBTapToDismissKeyboardBehavior.dismissKeyboard(_:))
}
