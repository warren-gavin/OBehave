//
//  OBOverlayViewBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 20/03/2017.
//  Copyright © 2017 Apokrupto. All rights reserved.
//

import UIKit

public enum OverlayTransitionDirection: Int {
    case top
    case bottom
    case leading
    case trailing
}

public class OBOverlayViewBehavior: OBBehavior {
    @IBOutlet public var viewToDisplay: UIView!
    
    @IBInspectable public var dimmingColor: UIColor = .clear
    @IBInspectable public var showShadow: Bool = false
    @IBInspectable public var appearFrom: Int = OverlayTransitionDirection.bottom.rawValue {
        didSet {
            direction = OverlayTransitionDirection(rawValue: appearFrom) ?? direction
        }
    }
    
    fileprivate var dimmingView: UIView?
    fileprivate var offscreen: NSLayoutConstraint?
    fileprivate var onscreen:  NSLayoutConstraint?
    fileprivate var direction: OverlayTransitionDirection = .bottom
    
    public var isDisplaying: Bool {
        return dimmingView != nil
    }
    
    public func show() {
        guard let owner = owner else {
            return
        }
        
        let dimmingView = UIView(frame: .zero)
        dimmingView.alpha = 0.0

        owner.view.addSubview(dimmingView)
        owner.view.bringSubview(toFront: dimmingView)
        
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = dimmingColor
        
        dimmingView.topAnchor.constraint(equalTo: owner.view.topAnchor).isActive = true
        dimmingView.bottomAnchor.constraint(equalTo: owner.view.bottomAnchor).isActive = true
        dimmingView.leadingAnchor.constraint(equalTo: owner.view.leadingAnchor).isActive = true
        dimmingView.trailingAnchor.constraint(equalTo: owner.view.trailingAnchor).isActive = true
        
        dimmingView.addSubview(viewToDisplay)
        self.dimmingView = dimmingView
        configureDisplayedView()
        
        let showDimmingView: () -> Void = {
            dimmingView.alpha = 1.0
        }
        
        UIView.animate(withDuration: .transitionDuration, animations: showDimmingView) { [unowned self] _ in
            self.offscreen?.isActive = false
            self.onscreen?.isActive  = true
            
            let showView: () -> Void = {
                dimmingView.layoutIfNeeded()
            }
            
            UIView.animate(withDuration: .transitionDuration,
                           delay: 0.0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 1.0,
                           options: .curveEaseOut,
                           animations: showView,
                           completion: nil)
        }
    }
    
    public func hide(completion: ((Bool) -> Void)? = nil) {
        guard let dimmingView = dimmingView else {
            return
        }
        
        let hideView: () -> Void = {
            dimmingView.layoutIfNeeded()
        }
        
        onscreen?.isActive  = false
        offscreen?.isActive = true

        UIView.animate(withDuration: .transitionDuration, animations: hideView) { [unowned self] _ in
            let hideDimmingView: () -> Void = {
                dimmingView.alpha = 0.0
                
                if self.showShadow {
                    self.viewToDisplay.removeShadow()
                }
            }
            
            UIView.animate(withDuration: .transitionDuration, animations: hideDimmingView) { [unowned self] finished in
                dimmingView.removeFromSuperview()
                self.dimmingView = nil
                completion?(finished)
            }
        }
    }
}

private extension OBOverlayViewBehavior {
    func configureDisplayedView() {
        guard let dimmingView = dimmingView else {
            return
        }
        
        switch direction {
        case .top:
            viewToDisplay.centerXAnchor.constraint(equalTo: dimmingView.centerXAnchor).isActive = true
            offscreen = viewToDisplay.centerYAnchor.constraint(equalTo: dimmingView.centerYAnchor, constant: -1000)
            onscreen  = viewToDisplay.centerYAnchor.constraint(equalTo: dimmingView.centerYAnchor)
            
        case .bottom:
            viewToDisplay.centerXAnchor.constraint(equalTo: dimmingView.centerXAnchor).isActive = true
            offscreen = viewToDisplay.centerYAnchor.constraint(equalTo: dimmingView.centerYAnchor, constant: 1000)
            onscreen  = viewToDisplay.centerYAnchor.constraint(equalTo: dimmingView.centerYAnchor)
            
        case .leading:
            viewToDisplay.centerYAnchor.constraint(equalTo: dimmingView.centerYAnchor).isActive = true
            offscreen = viewToDisplay.centerXAnchor.constraint(equalTo: dimmingView.centerXAnchor, constant: -1000)
            onscreen  = viewToDisplay.centerXAnchor.constraint(equalTo: dimmingView.centerXAnchor)
            
        case .trailing:
            viewToDisplay.centerYAnchor.constraint(equalTo: dimmingView.centerYAnchor).isActive = true
            offscreen = viewToDisplay.centerXAnchor.constraint(equalTo: dimmingView.centerXAnchor, constant: 1000)
            onscreen  = viewToDisplay.centerXAnchor.constraint(equalTo: dimmingView.centerXAnchor)
        }
        
        viewToDisplay.translatesAutoresizingMaskIntoConstraints = false
        if showShadow {
            viewToDisplay.addShadow()
        }
        
        onscreen?.isActive  = false
        offscreen?.isActive = true
    }
}

private extension UIView {
    /// Add a shadow behind a view
    ///
    /// - Parameters:
    ///   - radius: Distance the shadow expands away from the view
    ///   - opacity: Strength of the shadow darkness
    ///   - offset: Angle of the shadow displayed
    ///   - color: Shadow color
    @nonobjc func addShadow(color: UIColor = .darkGray) {
        clipsToBounds       = false
        layer.shadowColor   = color.cgColor
        layer.shadowRadius  = .overlayShadowRadius
        layer.shadowOpacity = .overlayShadowOpacity
        layer.shadowOffset  = .overlayShadowOffset
    }
    
    @nonobjc func removeShadow() {
        layer.shadowRadius  = 0.0
        layer.shadowOpacity = 0.0
        layer.shadowOffset  = .zero
    }
}

private extension TimeInterval {
    static let transitionDuration: TimeInterval = 0.35
}

private extension CGFloat {
    static let overlayShadowRadius = CGFloat(3.0)
}

private extension Float {
    static let overlayShadowOpacity = Float(0.2)
}

private extension CGSize {
    static let overlayShadowOffset = CGSize(width: 0.0, height: 0.7)
}
