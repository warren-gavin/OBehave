//
//  OBDimmedBackgroundTransitionDelegateBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 06/03/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/**
 Present a small view modally, with a dimmed color background chrome.
 */
class OBDimmedBackgroundTransitionDelegateBehavior: OBInsetViewControllerBehavior {
    @IBInspectable public var dimmingColor: UIColor = .defaultDimmingColor
    
    // MARK: UIViewControllerTransitioningDelegate
    func presentationControllerForPresentedViewController(_ presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                          sourceViewController source: UIViewController) -> UIPresentationController? {
        guard let owner = owner, owner == presented else {
            return nil
        }
        
        let presentationController = OBDimmedBackgroundPresentationController(presentedViewController: presented,
                                                                              presenting: presenting)
        
        presentationController.dataSource   = self
        presentationController.dimmingColor = dimmingColor
        
        return presentationController
    }
}

private extension UIColor {
    static let defaultDimmingColor = UIColor.black.withAlphaComponent(0.6)
}
