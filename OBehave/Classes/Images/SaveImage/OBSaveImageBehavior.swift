//
//  OBSaveImageBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 01/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

protocol OBSaveImageBehaviorDataSource: OBBehaviorDataSource {
    var saveTitle: String { get }
    var saveMessage: String? { get }
    var saveActionTitle: String { get }
    var cancelActionTitle: String { get }
    var saveError: String { get }
    var dismissText: String { get }
    var confirmationText: String { get }
}

class OBSaveImageBehavior: OBBehavior, OBSaveImageBehaviorDataSource {
    @IBInspectable public var prompt: Bool = false
    @IBInspectable public var pressToSave: Bool = false {
        didSet {
            setupLongPressSaveAction()
        }
    }
    
    @IBOutlet public var imageView: UIImageView? {
        didSet {
            setupLongPressSaveAction()
        }
    }
    
    private lazy var gesture = UILongPressGestureRecognizer(target: self, action: .saveOnLongPress)
    
    @objc func saveOnLongPress(_ gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            saveImage(nil)
        }
    }
    
    @IBAction func saveImage(_ sender: AnyObject?) {
        guard let image = imageView?.image else {
            return
        }
        
        let dataSource: OBSaveImageBehaviorDataSource = getDataSource()!
        
        let saveImage = { (alertAction: UIAlertAction?) -> Void in
            let saveImage: () -> Void = {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
            
            PHPhotoLibrary.shared().performChanges(saveImage) { (success, _) in
                let title = (success ? dataSource.confirmationText : dataSource.saveError)
                
                let alertView = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: dataSource.dismissText,
                                                  style: .cancel,
                                                  handler: nil))
                
                DispatchQueue.main.async { [unowned self] in
                    self.owner?.present(alertView, animated: true, completion: nil)
                }
            }
        }
        
        if prompt {
            let alertController = UIAlertController(title: dataSource.saveTitle,
                                                    message: dataSource.saveMessage,
                                                    preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: dataSource.saveActionTitle,
                                                    style: .default,
                                                    handler: saveImage))
            
            alertController.addAction(UIAlertAction(title: dataSource.cancelActionTitle,
                                                    style: .cancel,
                                                    handler: nil))
            
            DispatchQueue.main.async { [unowned self] in
                self.owner?.present(alertController, animated: true, completion: nil)
            }
        }
        else {
            saveImage(nil)
        }
    }
}

private extension OBSaveImageBehavior {
    func setupLongPressSaveAction() {
        if pressToSave {
            imageView?.isUserInteractionEnabled = true
            imageView?.addGestureRecognizer(gesture)
        }
    }
}

// MARK: - OBSaveImageBehaviorDataSource defaults
extension OBSaveImageBehaviorDataSource {
    var saveTitle: String {
        return NSLocalizedString("Save", comment: "Default 'Save' text for OBSaveImageBehaviorDataSource")
    }
    
    var saveMessage: String? {
        return nil
    }
    
    var saveActionTitle: String {
        return NSLocalizedString("Ok", comment: "Default 'Save' action text for OBSaveImageBehaviorDataSource")
    }
    
    var cancelActionTitle: String {
        return NSLocalizedString("Cancel", comment: "Default 'Cancel' text for OBSaveImageBehaviorDataSource")
    }
    
    var saveError: String {
        return NSLocalizedString("Could not save image", comment: "Default 'Save error' text for OBSaveImageBehaviorDataSource")
    }
    
    var dismissText: String {
        return NSLocalizedString("Ok", comment: "Default 'Dismiss' text for OBSaveImageBehaviorDataSource")
    }
    
    var confirmationText: String {
        return NSLocalizedString("Image saved", comment: "Default 'Image saved' text for OBSaveImageBehaviorDataSource")
    }
}

private extension Selector {
    static let saveOnLongPress = #selector(OBSaveImageBehavior.saveOnLongPress(_:))
}
