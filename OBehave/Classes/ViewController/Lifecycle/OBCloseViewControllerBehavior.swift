//
//  OBCloseViewControllerBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 24/10/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

public protocol OBCloseViewControllerBehaviorDelegate: OBBehaviorDelegate {
    func viewControllerWillClose(for behavior: OBCloseViewControllerBehavior)
    func viewControllerDidClose(for behavior: OBCloseViewControllerBehavior)
    func viewControllerCompletion()
}

public extension OBCloseViewControllerBehaviorDelegate {
    func viewControllerWillClose(for behavior: OBCloseViewControllerBehavior) {
    }
    
    func viewControllerDidClose(for behavior: OBCloseViewControllerBehavior) {
    }
    
    func viewControllerCompletion() {
    }
}

public protocol OBNavigationModalPresentationSegueDelegate {
    func dismissModalPresentation(controller: UIViewController, animated: Bool, completion: (() -> Void)?)
}

public final class OBCloseViewControllerBehavior: OBBehavior {
    @IBInspectable public var shouldPop: Bool = false
    
    /**
     Close a view controller
     
     Note: iOS 8
     This will not work if you are attempting to close a modal view embedded in a navigation view controller. Use
     closeEnclosingViewController: instead
     
     - parameter sender: UI element that instantated the close
     */
    @IBAction public func closeViewController(sender: AnyObject?) {
        let closeDelegate: OBCloseViewControllerBehaviorDelegate? = getDelegate()
        
        closeDelegate?.viewControllerWillClose(for: self)
        
        if let navigationController = owner?.navigationController, shouldPop {
            navigationController.popViewController(animated: true)
            closeDelegate?.viewControllerCompletion()
        }
        else {
            owner?.dismiss(animated: true, completion: closeDelegate?.viewControllerCompletion)
        }
        
        closeDelegate?.viewControllerDidClose(for: self)
    }
    
    /**
     Close a navigation stack that has been presented modally over another window
     
     - parameter sender: UI element that instantated the close
     */
    @IBAction public func closeEnclosingViewController(sender: AnyObject?) {
        if let navigationController = owner?.navigationController {
            let closeDelegate: OBCloseViewControllerBehaviorDelegate? = getDelegate()
            let enclosingWindowDelegate = navigationController.enclosingWindowDelegate
            
            closeDelegate?.viewControllerWillClose(for: self)
            
            enclosingWindowDelegate?.dismissModalPresentation(controller: navigationController,
                                                              animated: true,
                                                              completion: closeDelegate?.viewControllerCompletion)

            closeDelegate?.viewControllerDidClose(for: self)
        }
    }
}

// MARK: - OBNavigationModalPresentationSegueDelegate

/**
Extend UIViewController to have a delegate to allow dismissing of presented modals that contain embedding navigation
view controllers
*/
extension UIViewController: OBNavigationModalPresentationSegueDelegate {
    private struct Constants {
        static var associatedKey = "com.apokrupto.OBBehaviorModalDelegateBinding"
    }

    @nonobjc
    public var enclosingWindowDelegate: OBNavigationModalPresentationSegueDelegate? {
        get {
            return objc_getAssociatedObject(self, &Constants.associatedKey) as? OBNavigationModalPresentationSegueDelegate
        }
        
        set {
            if let enclosingWindowDelegate = newValue {
                objc_setAssociatedObject(self,
                                         &Constants.associatedKey,
                                         enclosingWindowDelegate as AnyObject,
                                         .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    @nonobjc
    public func dismissModalPresentation(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        dismiss(animated: animated, completion: completion)
    }
}
