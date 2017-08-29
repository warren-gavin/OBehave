//
//  OBKeyboardObserverBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 25/10/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

public protocol OBKeyboardObserverBehaviorDelegate: OBBehaviorDelegate {
    func keyboardWillAppear(from Behavior: OBKeyboardObserverBehavior)
    func keyboardWillDisappear(from Behavior: OBKeyboardObserverBehavior)
    func keyboardDidAppear(from Behavior: OBKeyboardObserverBehavior)
    func keyboardDidDisappear(from Behavior: OBKeyboardObserverBehavior)
    func keyboardBehaviorShouldObserveKeyboard(from Behavior: OBKeyboardObserverBehavior) -> Bool
}

public extension OBKeyboardObserverBehaviorDelegate {
    func keyboardWillAppear(from Behavior: OBKeyboardObserverBehavior) {
    }
    
    func keyboardWillDisappear(from Behavior: OBKeyboardObserverBehavior) {
    }
    
    func keyboardDidAppear(from Behavior: OBKeyboardObserverBehavior) {
    }
    
    func keyboardDidDisappear(from Behavior: OBKeyboardObserverBehavior) {
    }
}

/**
 * Behavior that listen to keyboard appear / disappear notifications and changes the bottom constraint
 * of a view.
 * This is useful for example for full screen view controllers that can be partially hidden by the keyboard.
 */
public class OBKeyboardObserverBehavior: OBBehavior {
    // MARK: Outlets
    @IBOutlet public var view: UIView?
    @IBInspectable public var tapToDismiss: Bool = true
    
    internal var locked = false

    // MARK: Private
    fileprivate var keyboardInfo: [String: NSValue]?
    
    private(set) public lazy var tapGesture: UITapGestureRecognizer? = {
        if !self.tapToDismiss {
            return nil
        }
        
        var gesture = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard(_:)))
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        
        return gesture
    }()
    
    override public func setup() {
        super.setup()

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: .dismissKeyboard,  name: .dismissKeyboard,    object: nil)
        notificationCenter.addObserver(self, selector: .keyboardWillShow, name: .UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: .keyboardWillHide, name: .UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /**
     The actions taken when the keyboard appears onscreen. By default it does nothing, but different subclasses of this observer
     class can react in different ways
     
     - parameter rect: The end frame of the keyboard onscreen
     */
    public func onKeyboardAppear(in rect: CGRect) {
    }

    /**
     The actions taken when the keyboard disappears from the screen. By deffault it does nothing, but different subclasses of this observer
     class can react in different ways

     
     - parameter rect: The end frame of the keyboard
     */
    public func onKeyboardDisappear(in rect: CGRect) {
    }
    
    public func endEditing() {
        let delegate: OBKeyboardObserverBehaviorDelegate? = getDelegate()
        delegate?.keyboardWillDisappear(from: self)
        
        owner?.view.endEditing(true)
        delegate?.keyboardDidDisappear(from: self)
    }
    
    /**
     Handle a tap to dismiss action
     
     - parameter _: Gesture recogniser
     */
    public func dismissKeyboard(_: UITapGestureRecognizer) {
        endEditing()
    }

    /**
     Handle a notification that the keyboard is about to appear onscreen
     
     - parameter notification: Notification object
     */
    public func keyboardWillShow(_ notification: NSNotification) {
        let delegate: OBKeyboardObserverBehaviorDelegate? = getDelegate()
        delegate?.keyboardWillAppear(from: self)
        
        if tapToDismiss {
            owner?.view.addGestureRecognizer(tapGesture!)
        }
        
        let animation: (CGRect) -> Void = { rect in
            if self.shouldAnimate() {
                self.onKeyboardAppear(in: rect)
            }
        }

        animateAlongsideKeyboard(keyboardInfo: notification.userInfo as? [String: NSValue],
                                 animation: animation) { (finished) -> Void in
            if finished {
                delegate?.keyboardDidAppear(from: self)
            }
        }
    }
    
    /**
     Handle a notification that the keyboard is about to disappear from the screen
     
     - parameter notification: Notification object
     */
    public func keyboardWillHide(_ notification: NSNotification) {
        locked = false
        
        let delegate: OBKeyboardObserverBehaviorDelegate? = getDelegate()
        delegate?.keyboardWillAppear(from: self)
        
        if tapToDismiss {
            owner?.view.removeGestureRecognizer(tapGesture!)
        }
        
        let animation: (CGRect) -> Void = { rect in
            if self.shouldAnimate() {
                self.onKeyboardDisappear(in: rect)
            }
        }
        
        animateAlongsideKeyboard(keyboardInfo: notification.userInfo as? [String: NSValue],
                                 animation: animation) { (finished) -> Void in
            if finished {
                delegate?.keyboardDidDisappear(from: self)
            }
        }
    }
}

private extension OBKeyboardObserverBehavior {
    /**
     Animations and other actions to perform as the keyboard is presented or removed
     
     - parameter keyboardInfo: Keyboard presentation information
     - parameter animation:    Animation to perform alongside the keyboard appearance/disappearance
     - parameter completion:   Action on completion of the animations
     */
    func animateAlongsideKeyboard(keyboardInfo: [String: NSValue]?, animation: @escaping (CGRect) -> Void, completion: ((Bool) -> Void)?) {
        guard
            let startFrame = keyboardInfo?[UIKeyboardFrameBeginUserInfoKey]?.cgRectValue,
            var endFrame = keyboardInfo?[UIKeyboardFrameEndUserInfoKey]?.cgRectValue,
            let duration = keyboardInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let options = keyboardInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
            !locked
        else {
            return
        }

        self.keyboardInfo = keyboardInfo
        
        if !startFrame.size.equalTo(endFrame.size) {
            endFrame.size.height += startFrame.size.height;
        }

        // The keyboard animation is not documented, so we have to hack the value a little to get it out of the keyboard info
        var animationCurve = UIViewAnimationOptions.curveEaseInOut
        NSNumber(value: options.intValue << 16).getValue(&animationCurve)
        
        let animateAndLayout = {
            animation(endFrame)
            self.view?.superview?.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: duration.doubleValue,
                       delay: 0.0,
                       options: animationCurve,
                       animations: animateAndLayout,
                       completion: completion)
    }
    
    /**
     - return: Flag that controls if the Behavior should animate alongside the keyboard appearing and disappearing, default true
     */
    func shouldAnimate() -> Bool {
        let delegate: OBKeyboardObserverBehaviorDelegate? = getDelegate()
        return delegate?.keyboardBehaviorShouldObserveKeyboard(from: self) ?? true
    }
}

extension OBKeyboardObserverBehavior: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Disallow recognition of tap gestures in buttons
        if let view = touch.view, let _ = view as? UIControl {
            return false
        }
        
        return true
    }
}

extension Selector {
    public static let dismissKeyboard  = #selector(OBKeyboardObserverBehavior.endEditing)
    public static let keyboardWillShow = #selector(OBKeyboardObserverBehavior.keyboardWillShow(_:))
    public static let keyboardWillHide = #selector(OBKeyboardObserverBehavior.keyboardWillHide(_:))
}

extension Notification.Name {
    public static let dismissKeyboard = Notification.Name(rawValue: "com.apokrupto.OBKeyboardObserverBehavior.dismiss")
}
