//
//  OBBlurredBackgroundTransitionDelegateBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 04/02/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/**
 Present a small view modally, with a blurred background chrome.
 */
public final class OBBlurredBackgroundTransitionDelegateBehavior: OBInsetViewControllerBehavior {
    @IBInspectable public var blurStyle: Int = .defaultBlurStyle {
        didSet {
            if nil == UIBlurEffectStyle(rawValue: blurStyle) {
                blurStyle = .defaultBlurStyle
            }
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        guard let owner = owner, owner == presented else {
            return nil
        }
        
        let presentationController = OBBlurredBackgroundPresentationController(presentedViewController: presented,
                                                                               presenting: presenting)
        
        presentationController.dataSource = self
        presentationController.blurStyle  = UIBlurEffectStyle(rawValue: blurStyle)!
        
        return presentationController
    }
}

private extension Int {
    static let defaultBlurStyle = UIBlurEffectStyle.dark.rawValue
}
