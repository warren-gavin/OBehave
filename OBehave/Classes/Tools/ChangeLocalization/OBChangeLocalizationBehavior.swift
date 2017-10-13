//
//  OBChangeLocalizationBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 26/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

/**
 *    Perform a runtime switch of an app's language.
 *
 *    Normally when an app has its language changed the user won't see the
 *    change until the next time the app is run. For apps that provide the
 *    user with the abiltity to change  language in-app there are a number
 *    of solutions, all of which involve having to create custom code that
 *    overrides, mimics or wraps NSLocalizedString() in some way.
 *
 *    While this is a reasonable  solution it does not handle localization
 *    of visual elements very well.  Localized storyboards cannot delegate
 *    to the custom solution  and any  properly localized  storyboard will
 *    result in a call to NSLocalizedString().
 *
 *    Some solutions I've  seen included using a  localize method that had
 *    to be called on each load, which meant absolutely every text element
 *    was forced  to be an outlet  of the view controller.  This is not an
 *    elegant solution.
 *
 *    This  behavior  swizzles localizedStringForKey:value:table:  so that
 *    NSLocalizedString  calls a new implementation using  the bundle that
 *    corresponds to the localization specified in the data source.
 *
 *    This behavior will post a  notification to view controllers that are
 *    already loaded so they can reset any labels. You must make sure that
 *    your view controllers listen for this notification for best results.
 *
 *    @param localization  ISO country code for the localization to switch
 *                         to.
 */
public final class OBChangeLocalizationBehavior: OBBehavior {
    override public func setup() {
        super.setup()
        addObserver(self, forKeyPath: "owner.view", options: .new, context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if "owner.view" == keyPath {
            owner?.observeLocalizationChanges()
        }
        
        removeObserver(self, forKeyPath: "owner.view")
    }
    
    deinit {
        if let owner = owner {
            NotificationCenter.default.removeObserver(owner)
        }
    }
    
    @IBAction func switchLocalization(_ sender: AnyObject?) {
        // If we have switched to a different bundle we reset the runtime bundle and
        // post a notification to all listeners (any loaded view controllers)
        if let path = pathForLocalizationBundle(), let bundle = Bundle(path: path) {
            NotificationCenter.default.post(name: .appLanguageWillChange, object: nil)
            Bundle.switchToLocalizationInBundle(bundle)
            NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
        }
    }
}

private extension OBChangeLocalizationBehavior {
    func pathForLocalizationBundle() -> String? {
        guard let dataSource: OBChangeLocalizationBehaviorDataSource = getDataSource() else {
            return nil
        }
        
        let localization = dataSource.localizationToChangeTo(self)
        
        if localization == Bundle.Localization.currentLocalization {
            return nil
        }
        
        return Bundle.main.path(forResource: localization, ofType: .projectFileExt)
    }
}

extension Notification.Name {
    static let appLanguageWillChange = Notification.Name(rawValue: "com.apokrupto.OBChangeLocalizationBehavior.languageWillChange")
    static let appLanguageDidChange  = Notification.Name(rawValue: "com.apokrupto.OBChangeLocalizationBehavior.languageDidChange")
}

/**
 *    The behavior's data source must supply the localization to switch to. If there is
 *    no data source this behavior will do nothing.
 */
@objc protocol OBChangeLocalizationBehaviorDataSource: OBBehaviorDataSource {
    func localizationToChangeTo(_ behavior: OBChangeLocalizationBehavior) -> String
}

private let swizzleLocalizationMethods: () = {
    guard
        let originalMethod = class_getInstanceMethod(Bundle.self, .originalSelector),
        let swizzledMethod = class_getInstanceMethod(Bundle.self, .swizzledSelector)
    else {
        return
    }
    
    method_exchangeImplementations(originalMethod, swizzledMethod)
}()

/**
 *    Extension for NSBundle to swizzle localization
 */
extension Bundle {
    struct Localization {
        static var currentBundle = Bundle.main
        static var currentLocalization: String {
            return currentBundle.preferredLocalizations[0]
        }
    }
    
    // Swizzled implementation of the localization functionality
    @objc func swizzledLocalizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return Localization.currentBundle.swizzledLocalizedString(forKey: key, value: value, table: tableName)
    }
    
    // Perform the swizzling of the localization functionality & set the active bundle
    public class func switchToLocalizationInBundle(_ bundle: Bundle) {
        _ = swizzleLocalizationMethods
        Localization.currentBundle = bundle
    }
}

extension UIViewController {
    func observeLocalizationChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: .reloadViewController,
                                               name: .appLanguageDidChange,
                                               object: nil)
    }
}

private extension String {
    static let projectFileExt = "lproj"
}

private extension Selector {
    static let originalSelector = #selector(Bundle.localizedString(forKey:value:table:))
    static let swizzledSelector = #selector(Bundle.swizzledLocalizedString(forKey:value:table:))
    static let reloadViewController = #selector(UIViewController.loadView)
}

