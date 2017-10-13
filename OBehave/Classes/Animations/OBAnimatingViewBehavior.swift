//
//  OBAnimatingViewBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 25/10/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

public protocol OBAnimatingViewBehaviorDelegate: OBBehaviorDelegate {
    func prepareForAnimation(_ behavior: OBAnimatingViewBehavior)
    func executeAnimation(_ behavior: OBAnimatingViewBehavior)
    func reverseAnimation(_ behavior: OBAnimatingViewBehavior)
}

/**
 *    Base class for animation of UIViews
 *
 *    Any behavior that performs some form of animation (rotation, displacement,
 *    resizing etc) should inherit from this class.
 *
 *    This class exposes the animation duration, delay, damping and velocity as used in
 *    animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:
 *    as IBInspectable vars
 *
 *    When creating an animating behavior you should implement the delegate's execution method
 *    and optionally the methods to prepare and reverse the animation.
 */
open class OBAnimatingViewBehavior: OBBehavior {
    @IBInspectable public var fadeIn:   Bool    = false
    @IBInspectable public var duration: Double  = .defaultAnimationDuration
    @IBInspectable public var delay:    Double  = .defaultAnimateAfterDuration
    @IBInspectable public var damping:  CGFloat = .defaultDampingFactor
    @IBInspectable public var velocity: CGFloat = .defaultSpringVelocity
    @IBInspectable public var autoReverse: Bool = false
    
    @IBOutlet public var animatingViews: [UIView]?

    @IBAction func animate(_ sender: AnyObject?) {
        executeAnimation(self)
    }
    
    @objc public func prepare(_ notification: Notification?) {
        let delegate: OBAnimatingViewBehaviorDelegate? = getDelegate()
        delegate?.prepareForAnimation(self)
    }
    
    @objc public func execute(_ notification: Notification?) {
        let delegate: OBAnimatingViewBehaviorDelegate? = getDelegate()
        delegate?.executeAnimation(self)
    }
    
    @objc public func reverse(_ notification: Notification?) {
        let delegate: OBAnimatingViewBehaviorDelegate? = getDelegate()
        delegate?.reverseAnimation(self)
    }
    
    override open func setup() {
        super.setup()

        delegate = self
        
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: .prepare, name: .obAnimationPrepare, object: owner)
        notificationCenter.addObserver(self, selector: .execute, name: .obAnimationExecute, object: owner)
        notificationCenter.addObserver(self, selector: .reverse, name: .obAnimationReverse, object: owner)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension OBAnimatingViewBehavior: OBAnimatingViewBehaviorDelegate {
    @objc public func prepareForAnimation(_ behavior: OBAnimatingViewBehavior) {
    }
    
    @objc public func executeAnimation(_ behavior: OBAnimatingViewBehavior) {
    }
    
    @objc public func reverseAnimation(_ behavior: OBAnimatingViewBehavior) {
    }
}

public extension Notification.Name {
    static let obAnimationPrepare = NSNotification.Name(rawValue: "com.apokrupto.AnimatingViewBehavior.prepare")
    static let obAnimationExecute = NSNotification.Name(rawValue: "com.apokrupto.AnimatingViewBehavior.execute")
    static let obAnimationReverse = NSNotification.Name(rawValue: "com.apokrupto.AnimatingViewBehavior.reverse")
}

private extension Selector {
    static let prepare = #selector(OBAnimatingViewBehavior.prepare(_:))
    static let execute = #selector(OBAnimatingViewBehavior.execute(_:))
    static let reverse = #selector(OBAnimatingViewBehavior.reverse(_:))
}

private extension Double {
    static let defaultAnimationDuration    = 0.5
    static let defaultAnimateAfterDuration = 0.0
}

private extension CGFloat {
    static let defaultDampingFactor: CGFloat  = 0.5
    static let defaultSpringVelocity: CGFloat = 1.0
}
