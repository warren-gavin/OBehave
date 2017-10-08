
//  OBDimmedBackgroundPresentationController.swift
//  OBehave
//
//  Created by Warren Gavin on 06/03/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

/// Custom presentation controller that displays a view over a blurred background
class OBDimmedBackgroundPresentationController: OBInsetPresentationController {
    var dimmingColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    
    override func backgroundViewForPresentation() -> UIView? {
        guard let containerView = containerView else {
            return nil
        }
        
        let backroundView = UIView(frame: containerView.bounds)
        
        backroundView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backroundView.backgroundColor = dimmingColor
        
        return backroundView
    }
}
