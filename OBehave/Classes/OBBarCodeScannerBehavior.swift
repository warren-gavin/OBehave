//
//  OBBarCodeScannerBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 06/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit
import AVFoundation

public protocol OBBarCodeScannerBehaviorDelegate: OBBehaviorDelegate {
    func barCodeScanner(_ scanner: OBBarCodeScannerBehavior, didScanBarCodeString string: String, frame: CGRect)
    func barCodeScanner(_ scanner: OBBarCodeScannerBehavior, didFailWithError error: NSError?)
}

final public class OBBarCodeScannerBehavior: OBBehavior {
    @IBOutlet public var containerView: UIView? {
        didSet {
            containerView?.layer.insertSublayer(cameraPreviewLayer, at: 0)
        }
    }
    
    fileprivate let supportedBarCodes = [
        AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeCode39Code,
        AVMetadataObjectTypeCode39Mod43Code,
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeQRCode,
        AVMetadataObjectTypeAztecCode,
        AVMetadataObjectTypeDataMatrixCode
    ]
    
    fileprivate lazy var session: AVCaptureSession = {
        return AVCaptureSession()
    }()
    
    fileprivate lazy var cameraPreviewLayer: AVCaptureVideoPreviewLayer = {
        var layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer?.videoGravity = AVLayerVideoGravityResizeAspectFill

        return layer!
    }()
    
    // MARK: Public
    override public func setup() {
        super.setup()

        setupBarCodeScanner()
        addObserver(self, forKeyPath: "containerView.bounds", options: .new, context: nil)
    }
    
    deinit {
        session.stopRunning()
        removeObserver(self, forKeyPath: "containerView.bounds")
        cameraPreviewLayer.removeFromSuperlayer()
    }
    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        updateCameraPreviewLayer()
    }
}

private extension OBBarCodeScannerBehavior {
    func updateCameraPreviewLayer() {
        if let containerView = containerView {
            cameraPreviewLayer.frame = containerView.bounds
        }
    }
    
    func setupBarCodeScanner() {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            let delegate: OBBarCodeScannerBehaviorDelegate? = getDelegate()
            delegate?.barCodeScanner(self, didFailWithError: nil)
            
            return
        }
        
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        session.startRunning()
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate
extension OBBarCodeScannerBehavior: AVCaptureMetadataOutputObjectsDelegate {
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var barCodeBounds = CGRect.zero
        var barCodeString = ""
        
        for metadata in metadataObjects as! [AVMetadataObject] {
            for type in supportedBarCodes {
                if metadata.type == type {
                    barCodeBounds = cameraPreviewLayer.transformedMetadataObject(for: metadata).bounds
                    barCodeString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    break
                }
            }
        }
        
        let delegate: OBBarCodeScannerBehaviorDelegate? = getDelegate()
        delegate?.barCodeScanner(self, didScanBarCodeString: barCodeString, frame: barCodeBounds)
    }
}
