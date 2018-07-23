//
//  BarCodeScannerViewController.swift
//  OBehave
//
//  Created by Warren Gavin on 13/03/16.
//  Copyright © 2016 Apokrupto. All rights reserved.
//

import UIKit
import OBehave

class BarCodeScannerViewController: UIViewController {
    @IBOutlet var scannedDataLabel: UILabel! {
        didSet {
            scannedDataLabel.text = ""
        }
    }
    
    private var displaying = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .obAnimationPrepare, object: self)
    }
}

extension BarCodeScannerViewController: OBBarCodeScannerBehaviorDelegate {
    func barCodeScanner(_ scanner: OBBarCodeScannerBehavior, didScanBarCodeString string: String, frame: CGRect) {
        scannedDataLabel.text = string
        scannedDataLabel.sizeToFit()
        
        displayScannedData()
    }
    
    func barCodeScanner(_ scanner: OBBarCodeScannerBehavior, didFailWithError error: OBBarCodeScannerError) {
        scannedDataLabel.text = "No data"
        displayScannedData(forceDisplay: true)
    }
}

private extension BarCodeScannerViewController {
    func displayScannedData(forceDisplay: Bool = false) {
        DispatchQueue.main.async { [unowned self] in
            if !self.displaying || forceDisplay {
                NotificationCenter.default.post(name: .obAnimationExecute, object: self)
                self.displaying = true
            }
        }
    }
}
