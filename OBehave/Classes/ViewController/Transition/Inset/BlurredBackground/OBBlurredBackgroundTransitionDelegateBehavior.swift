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
    @IBInspectable public var blurStyle: Int = UIBlurEffect.Style.defaultBlurStyle.rawValue
    
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
        presentationController.blurStyle  = UIBlurEffect.Style(rawValue: blurStyle) ?? .defaultBlurStyle
        
        return presentationController
    }
}

private extension UIBlurEffect.Style {
    static let defaultBlurStyle = UIBlurEffect.Style.dark
}
