//
//  OBBehavior.swift
//  OBehave
//
//  Created by Warren on 24/10/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

private struct Keys {
    static var allBehaviorsKey = "com.apokrupto.OBBehave.AllBehaviors"
}

/**
 *    A Behavior is a unit of code that does a single job that may be reused in multiple areas of a project or projects.
 *
 *    Using composition, View Controllers are given ownership of a Behavior in Interface Builder (or the storyboard).
 *    Composition is favoured over inheriting functionality from a base view controller for the following reasons:
 *
 *    1.  Behaviors can be re-used across multiple projects
 *    2.  A base View Controller with lots of code that may be used by some
 *        but not all subclassed view controllers is poor design.
 *    3.  Using Behaviors provides true separation of concerns.
 *    4.  View Controllers are reduced in size
 *
 *    See http://www.objc.io/issue-13/behaviors.html for details.
 *
 *    Additionally, in this library a Behavior can have a data source, a delegate and an effect
 *    object, each of which can add individual and specific functionality to the Behavior which 
 *    will help customise a Behavior as it's used per instance.
 *
 *    For instance, in a Behavior that displays an action sheet, the text displayed in the sheet
 *    can be customised by a data source, while the functionality of the Behavior is unchanged
 */
open class OBBehavior: NSObject {
    // Binding key, needs to be unique
    private(set) var associatedKey = NSUUID().uuidString
    
    // MARK: Outlets
    @IBOutlet public var effect: OBBehaviorEffect?
    @IBOutlet public weak var dataSource: OBBehaviorDataSource?
    @IBOutlet public weak var delegate: OBBehaviorDelegate?
    @IBOutlet public weak var owner: UIViewController? {
        didSet {
            objc_setAssociatedObject(oldValue, &self.associatedKey, nil,  .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(owner,    &self.associatedKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            var allBehaviors = objc_getAssociatedObject(owner, &Keys.allBehaviorsKey) as? [OBBehavior] ?? [OBBehavior]()
            allBehaviors.append(self)
            
            objc_setAssociatedObject(owner, &Keys.allBehaviorsKey, allBehaviors, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            setup()
        }
    }
    
    /**
     You should implement this method in your behavior if there is anything that must be in place
     before the Behavior can be used.
     
     For example you would start observing notifications, or KVO, or change outlet settings in this method
     */
    open func setup() {
        /*
         The behavior's data source and delegate can be set directly in the storyboard. If they are
         not set in the storyboard we set them to the owner, which is guaranteed to conform to the protocols
         */
        dataSource = dataSource ?? owner
        delegate   = delegate   ?? owner
    }
    
    /**
     In order to define default data source functionality some Behaviors may implement their
     own data source. This method returns the data source if it exists, otherwise it tries
     to return the Behavior if it implements the data source protocol.
     
     usage:  let dataSource: MyBehaviorsDataSource? = Behavior.getDataSource()
     
     - returns: The first data source we find that matches on the type
     */
    public func getDataSource<T>() -> T? {
        return (dataSource as? T) ?? (self as? T)
    }

    /**
     In order to define default delegate functionality some Behaviors may be their
     own delegate. This method returns the delegate if it exists, otherwise it tries
     to return the Behavior if it implements the delegate protocol.
     
     usage:  let delegate: MyBehaviorDelegate = Behavior.getDelegate()
     
     - returns: The first delegate we find that matches on the type
     */
    public func getDelegate<T>() -> T? {
        return (delegate as? T) ?? (self as? T)
    }
}

/**
 *    Behaviors can have their own data source, to get things like localised text, colours or any other data that
 *    the Behavior needs during its execution. With a data source we can make our general Behaviors customised
 *    for a specific use case.
 *
 *    For convenience all Behavior data sources should inherit from this protocol.
 */
@objc public protocol OBBehaviorDataSource {
}

/**
 *    Behaviors can have their own delegate, to react to events that the Behavior will trigger during its execution.
 *
 *    For convenience all Behavior delegates should inherit from this protocol.
 */
@objc public protocol OBBehaviorDelegate {
}

/**
 *    Our Behavior's owner (see above) can conform to the Behavior data source and delegate protocols
 */
extension UIViewController {
    func allAssociatedBehaviors() -> [OBBehavior]? {
        return objc_getAssociatedObject(self, &Keys.allBehaviorsKey) as? [OBBehavior]
    }
}

/**
 *    Behaviors can have side effects that happen while the Behavior executes. For example a stretching
 *    image Behavior might add a blur, or colour tinting or some other effect to the image being stretched.
 *
 *    Because a blur or tint change is a side effect and not always wanted it shouldn't be part of the stretch
 *    Behavior itself, instead the full experience as shown on screen is a combination of the Behavior plus
 *    side effect objects working together
 */
@objc public protocol OBBehaviorEffect {
    /**
    Perform the side effect on an object. This can be anything we want
    
    - parameter object:  Some object that will have a side effect applied to it, e.g. an image that will have
    a blurring, transparency or tinting effect
    - parameter percent: The effect may be gradual, use this value to control the extent of the effect
    
    - returns: The result of the effect applied to the input object, e.g. a blurred image
    */
    @objc optional func performEffect(on object: AnyObject?, percentage percent:CGFloat) -> AnyObject?
}

/**
 *    Extend NSObject for effects. We need this because the effect will be hooked up in Interface Builder and so
 *    must be an NSObject.
 */
extension NSObject: OBBehaviorDataSource, OBBehaviorEffect, OBBehaviorDelegate {
}
