//
//  OBTintImageBehaviorEffect.swift
//  OBehave
//
//  Created by Warren Gavin on 02/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

final public class OBTintImageBehaviorEffect: OBBehaviorEffect {
    @IBInspectable public var tintColor: UIColor?
    
    override func performEffect(on object: AnyObject?, percentage percent:CGFloat) -> AnyObject? {
        guard let image = object as? UIImage, let tintColor = tintColor, percent > 0 else {
            return object
        }
        
        return image.applyTintEffectWithColor(tintColor: tintColor.withAlphaComponent(percent))
    }
}
