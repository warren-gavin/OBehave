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
class OBBlurredBackgroundTransitionDelegateBehavior: OBInsetViewControllerBehavior {
    @IBInspectable public var blurStyle: Int = .defaultBlurStyle {
        didSet {
            if nil == UIBlurEffectStyle(rawValue: blurStyle) {
                blurStyle = .defaultBlurStyle
            }
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func presentationControllerForPresentedViewController(_ presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                          sourceViewController source: UIViewController) -> UIPresentationController? {
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

fileprivate extension Int {
    static let defaultBlurStyle = UIBlurEffectStyle.dark.rawValue
}
