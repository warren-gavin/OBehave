//
//  OBPhoneCallBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 25/10/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

public protocol OBPhoneCallBehaviorDataSource {
    func numberForPhoneCallBehavior(_ behavior: OBPhoneCallBehavior) -> String?
}

/**
*    Behavior to place phone calls
*/
public final class OBPhoneCallBehavior: OBBehavior {
    ///    Number to call, made inspectable so the number can be set
    ///    directly in Interface Builder
    @IBInspectable public var phoneNumber: String?

    ///    Set this inspectable value if you want to prompt the user before making the call
    @IBInspectable public var promptUser: Bool = false

    /**
    Action to place a phone call. 
     
    The phone number to call can either come from a data source or directly in the storyboard in the inspectable property.
    If the value is set in the storyboard and also comes from a data source, the data source takes precedence
    
    - parameter sender: UIControl that executes this action
    */
    @IBAction public func performPhoneCall(_ sender: AnyObject?) {
        let dataSource: OBPhoneCallBehaviorDataSource? = getDataSource()

        if let number = dataSource?.numberForPhoneCallBehavior(self) {
            phoneNumber = number
        }
        
        if let number = phoneNumber {
            let scheme = (promptUser ? "telprompt://" : "tel://")
            UIApplication.shared.open(URL(string: "\(scheme)\(number)")!, options: [:], completionHandler: nil)
        }
    }
}
