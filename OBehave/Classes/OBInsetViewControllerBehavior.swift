//
//  OBInsetViewControllerBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 13/01/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/**
 Present a small view controller modally
 */
public class OBInsetViewControllerBehavior: OBKeyboardObserverBehavior, UIViewControllerTransitioningDelegate {
    ///  Normalised width of the presented view
    @IBInspectable public var viewWidth: CGFloat = 0.7
    
    ///  Normalised height of the presented view
    @IBInspectable public var viewHeight: CGFloat = 0.7
    
    /// Should the presented view resize if a keyboard is displayed?
    @IBInspectable public var resizeForKeyboard: Bool = true
    
    var originalContainerViewFrame: CGRect?
    var originalPresentationViewFrame: CGRect?
    
    var keyboardStartPosition: CGFloat?
    
    override public func setup() {
        super.setup()

        owner?.modalPresentationStyle = .custom
        owner?.transitioningDelegate  = self
    }

    // MARK: OBKeyboardObserverBehavior
    override public func onKeyboardAppear(in rect: CGRect) {
        guard let containerView = owner?.presentationController?.containerView,
            let presentationView = owner?.presentationController?.presentedView, 0 < rect.size.height else {
            return
        }

        let newKeyboardStartPosition = rect.origin.y
        if let keyboardStartPosition = keyboardStartPosition {
            if keyboardStartPosition == newKeyboardStartPosition {
                return
            }
            
            let heightOffset = keyboardStartPosition - newKeyboardStartPosition
            containerView.frame.size.height -= heightOffset
            presentationView.frame.size.height -= heightOffset
            
            self.keyboardStartPosition = newKeyboardStartPosition
            
            return
        }
        
        keyboardStartPosition = newKeyboardStartPosition
        
        if let tapGesture = tapGesture {
            containerView.addGestureRecognizer(tapGesture)
        }
        
        let frameWidthRatio  = presentationView.frame.width  / containerView.frame.width
        let frameHeightRatio = presentationView.frame.height / containerView.frame.height
        
        originalContainerViewFrame = containerView.frame
        originalPresentationViewFrame = presentationView.frame
        
        if resizeForKeyboard {
            containerView.frame = CGRect(
                origin: containerView.frame.origin,
                size: CGSize(width: containerView.frame.width, height: containerView.frame.height - rect.size.height)
            )
            
            presentationView.frame = containerView.frame.insetBy(dx: containerView.frame.width * (1.0 - frameWidthRatio) * 0.5,
                dy: containerView.frame.height * (1.0 - frameHeightRatio) * 0.5
            )
            
            owner?.presentationController?.presentedView?.frame = presentationView.frame
            owner?.presentationController?.containerViewWillLayoutSubviews()
        }
    }
    
    override public func onKeyboardDisappear(in rect: CGRect) {
        keyboardStartPosition = nil
        
        if let tapGesture = tapGesture  {
            owner?.presentationController?.containerView?.removeGestureRecognizer(tapGesture)
        }
        
        if let originalContainerViewFrame = originalContainerViewFrame {
            owner?.presentationController?.containerView?.frame = originalContainerViewFrame
        }
        
        if let originalPresentationViewFrame = originalPresentationViewFrame {
            owner?.presentationController?.presentedView?.frame = originalPresentationViewFrame
        }
    }
}


extension OBInsetViewControllerBehavior: OBInsetPresentationControllerDataSource {
    public var insets: OBPresentationInsets {
        return .normalised(viewWidth, viewHeight)
    }
}
