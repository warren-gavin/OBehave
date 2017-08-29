//
//  OBParallaxBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 01/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

class OBParallaxBehavior: OBBehavior {
    @IBInspectable public var parallaxOffset: CGPoint = .zero
    @IBInspectable public var parallaxRatio: CGPoint  = .ratio
    
    @IBOutlet public var scrollView: UIScrollView? {
        didSet {
            scrollView?.delegate = self
            initializeViews()
        }
    }
    
    @IBOutlet public var view: UIView? {
        didSet {
            if let view = view {
                if parallaxOffset.equalTo(.zero) {
                    parallaxOffset = view.center
                }
                
                initializeViews()
            }
        }
    }
}

private extension OBParallaxBehavior {
    func initializeViews() {
        if let view = view, let scrollView = scrollView {
            scrollView.contentSize = CGSize(width: view.bounds.width, height: 0)
            scrollView.contentOffset = CGPoint(x: scrollView.contentSize.width / 2.0, y: scrollView.contentSize.height / 2.0)
            view.center = CGPoint(x: view.bounds.width / 2.0, y: view.bounds.height / 2.0)
        }
    }
}

// MARK: UIScrollViewDelegate
extension OBParallaxBehavior: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let view = view {
            view.center = CGPoint(x: parallaxOffset.x + scrollView.contentOffset.x * parallaxRatio.x,
                                  y: view.center.y)
        }
    }
}

private extension CGPoint {
    static let ratio = CGPoint(x: -0.5, y: 0)
}
