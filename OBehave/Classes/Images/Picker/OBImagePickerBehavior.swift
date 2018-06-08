//
//  OBImagePickerBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 06/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

@objc protocol OBImagePickerBehaviorDelegate: OBBehaviorDelegate {
    @objc optional func imagePicker(_ behavior: OBImagePickerBehavior, didSelectImage image: UIImage?)
    @objc optional func imagePickerHasNoImageSource(_ behavior: OBImagePickerBehavior)
}

protocol OBImagePickerBehaviorDataSource: OBBehaviorDataSource {
    func imagePickerCancelText(_ behavior: OBImagePickerBehavior) -> String
    func imagePickerSelectFromCameraText(_ behavior: OBImagePickerBehavior) -> String?
    func imagePickerSelectFromLibraryText(_ behavior: OBImagePickerBehavior) -> String?
    func imagePickerSelectionTitle(_ behavior: OBImagePickerBehavior) -> String?
    func imagePickerSelectionMessage(_ behavior: OBImagePickerBehavior) -> String?
}

public final class OBImagePickerBehavior: OBBehavior, OBImagePickerBehaviorDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet public var imageView: UIImageView?
    
    @IBAction func displayImagePickerOptions(_ sender: AnyObject?) {
        let dataSource: OBImagePickerBehaviorDataSource = getDataSource()!
        
        let title = dataSource.imagePickerSelectionTitle(self)
        let message = dataSource.imagePickerSelectionMessage(self)
        
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // If the user wants to select images from the camera they must supply the
        // text to prompt the user to do this
        if let selectFromCamera = dataSource.imagePickerSelectFromCameraText(self), UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickCameraImage = UIAlertAction(title: selectFromCamera, style: .default) { [unowned self] (action: UIAlertAction) -> Void in
                self.pickImage(.camera)
            }
            
            actionSheet.addAction(pickCameraImage)
        }
        
        // If the user wants to select images from the library they must supply the
        // text to prompt the user to do this
        if let selectFromLibrary = dataSource.imagePickerSelectFromLibraryText(self), UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickLibraryImage = { [unowned self] (action: UIAlertAction) -> Void in
                self.pickImage(.photoLibrary)
            }
            
            actionSheet.addAction(UIAlertAction(title: selectFromLibrary, style: .default, handler: pickLibraryImage))
        }
        
        // Only display the action sheet if we have actions to pick images with
        if actionSheet.actions.isEmpty {
            let delegate: OBImagePickerBehaviorDelegate? = getDelegate()
            delegate?.imagePickerHasNoImageSource?(self)
        }
        else {
            let cancel = dataSource.imagePickerCancelText(self)
            actionSheet.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))
            
            owner?.present(actionSheet, animated: true, completion: nil)
        }
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [unowned self] in
            let delegate: OBImagePickerBehaviorDelegate? = self.getDelegate()
            let image = info[.originalImage] as? UIImage
            
            self.imageView?.image = image
            delegate?.imagePicker?(self, didSelectImage: image)
        }
    }
}

private extension OBImagePickerBehavior {
    func pickImage(_ sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.modalPresentationStyle = .fullScreen
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        
        owner?.present(imagePicker, animated: true, completion: nil)
    }
}

extension OBImagePickerBehaviorDataSource {
    func imagePickerCancelText(_ behavior: OBImagePickerBehavior) -> String {
        return NSLocalizedString("Cancel", comment: "Default 'Cancel' text in OBImagePickerBehaviorDataSource")
    }
    
    func imagePickerSelectFromCameraText(_ behavior: OBImagePickerBehavior) -> String? {
        return NSLocalizedString("Use camera", comment: "Default 'Use camera' text in OBImagePickerBehaviorDataSource")
    }
    
    func imagePickerSelectFromLibraryText(_ behavior: OBImagePickerBehavior) -> String? {
        return NSLocalizedString("Image from photo album", comment: "Default 'Image from photo album' text in OBImagePickerBehaviorDataSource")
    }
    
    func imagePickerSelectionTitle(_ behavior: OBImagePickerBehavior) -> String? {
        return nil
    }

    func imagePickerSelectionMessage(_ behavior: OBImagePickerBehavior) -> String? {
        return nil
    }
}
