//
//  OBOpenSettingsBehavior.swift
//  OBehave
//
//  Created by Nicolas Bichon on 07/03/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit

final class OBOpenSettingsBehavior: OBBehavior {
    /**
     Open the iOS Settings app.
     
     - parameter sender: UI element that instantiated the open settings.
     */
    @IBAction func openSettings(_ sender: AnyObject?) {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
    }
}
