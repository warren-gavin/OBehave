//
//  OBDimmedOverlayViewController.swift
//  OBehave
//
//  Created by Warren Gavin on 16/02/2017.
//  Copyright © 2017 Apokrupto. All rights reserved.
//

import UIKit

open class OBDimmedOverlayViewController: UIViewController {
    @IBInspectable public var dimmingColor: UIColor = UIColor.black.withAlphaComponent(0.2)
    @IBInspectable public var tapToDismiss: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        guard tapToDismiss else {
            return
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: .dismiss)
        gesture.cancelsTouchesInView = false

        view.addGestureRecognizer(gesture)
    }
}

extension OBDimmedOverlayViewController {
    @objc public func dismiss(_: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - OBInsetPresentationControllerDataSource
extension OBDimmedOverlayViewController: OBInsetPresentationControllerDataSource {
}

// MARK: - OBTransitionDelegateBehaviorDataSource
extension OBDimmedOverlayViewController: OBTransitionDelegateBehaviorDataSource {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController {
        let presentationController = OBInsetPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.dataSource = self
        
        return presentationController
    }
}

private extension Selector {
    static let dismiss = #selector(OBDimmedOverlayViewController.dismiss(_:))
}
