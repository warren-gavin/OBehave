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
    
    private let supportedBarCodes: [AVMetadataObject.ObjectType] = [
        .upce,
        .code39,
        .code39Mod43,
        .ean13,
        .ean8,
        .code93,
        .code128,
        .pdf417,
        .qr,
        .aztec,
        .dataMatrix
    ]
    
    private lazy var session: AVCaptureSession = {
        return AVCaptureSession()
    }()
    
    private lazy var cameraPreviewLayer: AVCaptureVideoPreviewLayer = {
        var layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        return layer
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
        guard
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
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
    public func metadataOutput(captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        var barCodeBounds = CGRect.zero
        var barCodeString = ""
        
        for metadata in metadataObjects {
            for type in supportedBarCodes {
                if metadata.type == type,
                   let bounds = cameraPreviewLayer.transformedMetadataObject(for: metadata)?.bounds,
                   let stringValue = (metadata as? AVMetadataMachineReadableCodeObject)?.stringValue {
                    barCodeBounds = bounds
                    barCodeString = stringValue
                    break
                }
            }
        }
        
        let delegate: OBBarCodeScannerBehaviorDelegate? = getDelegate()
        delegate?.barCodeScanner(self, didScanBarCodeString: barCodeString, frame: barCodeBounds)
    }
}
