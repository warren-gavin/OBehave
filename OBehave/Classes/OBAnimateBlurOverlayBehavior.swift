//
//  OBAnimateBlurOverlayBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 07/07/2017.
//  Copyright © 2017 Apokrupto. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
class OBAnimateBlurOverlayBehavior: OBBehavior {
    @IBOutlet var underlyingView: UIView! {
        didSet {
            underlyingView.addSubview(blurView)
            
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.topAnchor.constraint(equalTo: underlyingView.topAnchor).isActive = true
            blurView.bottomAnchor.constraint(equalTo: underlyingView.bottomAnchor).isActive = true
            blurView.trailingAnchor.constraint(equalTo: underlyingView.trailingAnchor).isActive = true
            blurView.leadingAnchor.constraint(equalTo: underlyingView.leadingAnchor).isActive = true
        }
    }

    private lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private lazy var animator: UIViewPropertyAnimator = {
        let propertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.blurView.effect = nil
        }
        
        propertyAnimator.fractionComplete = 1.0
        return propertyAnimator
    }()

    var blurProgress: CGFloat = 0.0 {
        didSet {
            animator.fractionComplete = 1.0 - min(max(blurProgress, 0.0), 1.0)
        }
    }
}

// MARK: OBBehaviorSideEffectDelegate
@available(iOS 10.0, *)
extension OBAnimateBlurOverlayBehavior {
    func setSideEffectProgress(_ progress: CGFloat) {
        blurProgress = progress
    }
}
