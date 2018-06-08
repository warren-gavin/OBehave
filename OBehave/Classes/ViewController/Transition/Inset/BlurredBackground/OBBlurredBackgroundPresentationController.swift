//
//  OBBlurredBackgroundPresentationController.swift
//  OBehave
//
//  Created by Warren Gavin on 13/01/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/// Custom presentation controller that displays a view over a blurred background
internal class OBBlurredBackgroundPresentationController: OBInsetPresentationController {
    var blurStyle: UIBlurEffect.Style = .light

    override func backgroundViewForPresentation() -> UIView? {
        guard let containerView = containerView else {
            return nil
        }
        
        let blurringView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        
        blurringView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurringView.frame = containerView.bounds
        
        return blurringView
    }
}
