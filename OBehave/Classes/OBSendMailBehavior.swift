//
//  OBSendMailBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 28/02/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit
import MessageUI

public protocol OBSendMailBehaviorDataSource: OBBehaviorDataSource {
    var textColor: UIColor { get }
    var barColor: UIColor { get }
    var textAttributes: [String: Any]? { get }
    
    func subject(for Behavior: OBSendMailBehavior) -> String
    func address(for Behavior: OBSendMailBehavior) -> String
    func body(for Behavior: OBSendMailBehavior) -> String
}

extension OBSendMailBehaviorDataSource {
    public var textAttributes: [String: Any]? {
        return nil
    }
}

public protocol OBSendMailBehaviorDelegate: OBBehaviorDelegate {
    func finished(presenting Behavior: OBSendMailBehavior)
    func unavailable(_ Behavior: OBSendMailBehavior)
}

extension OBSendMailBehaviorDelegate {
    public func finished(presenting Behavior: OBSendMailBehavior) {
    }

    public func unavailable(_ Behavior: OBSendMailBehavior) {
    }
}

public class OBSendMailBehavior: OBBehavior {
    @IBAction public func showMail(_ sender: UIButton? = nil) {
        if !MFMailComposeViewController.canSendMail() {
            let delegate: OBSendMailBehaviorDelegate? = self.getDelegate()
            delegate?.unavailable(self)
            
            return
        }
        
        guard let dataSource = self.dataSource as? OBSendMailBehaviorDataSource else {
            return
        }
        
        let mailViewController = MailComposeViewController()
        mailViewController.navigationBar.tintColor = dataSource.textColor
        mailViewController.navigationBar.backgroundColor = dataSource.barColor
        mailViewController.navigationBar.isTranslucent = false
        
        if let textAttributes = dataSource.textAttributes {
            mailViewController.navigationBar.titleTextAttributes = textAttributes
        }
        
        mailViewController.setSubject(dataSource.subject(for: self))
        mailViewController.setMessageBody(dataSource.body(for: self), isHTML: false)
        mailViewController.setToRecipients([dataSource.address(for: self)])
        mailViewController.mailComposeDelegate = self
        
        self.owner?.present(mailViewController, animated: true, completion: {
            let delegate: OBSendMailBehaviorDelegate? = self.getDelegate()
            delegate?.finished(presenting: self)
        })
    }
}

extension OBSendMailBehavior: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

private class MailComposeViewController: MFMailComposeViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
