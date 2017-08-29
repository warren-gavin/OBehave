//
//  PhoneCallViewController.swift
//  OBehave
//
//  Created by Warren Gavin on 27/03/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit
import OBehave

class PhoneCallViewController: UIViewController {
    @IBOutlet var phoneNumberTextView: UITextField!
}

extension PhoneCallViewController: OBPhoneCallBehaviorDataSource {
    func numberForPhoneCallBehavior(_ behavior: OBPhoneCallBehavior) -> String? {
        return phoneNumberTextView.text
    }
}
