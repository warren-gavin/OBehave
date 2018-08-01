//
//  OBBarCodeScannerBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 06/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit
import AVFoundation

public enum OBBarCodeScannerError {
    case unauthorized
    case unknown
}

public protocol OBBarCodeScannerBehaviorDelegate: OBBehaviorDelegate {
    func barCodeScanner(_ scanner: OBBarCodeScannerBehavior, didScanBarCodeString string: String, frame: CGRect)
    func barCodeScanner(_ scanner: OBBarCodeScannerBehavior, didFailWithError error: OBBarCodeScannerError)
}

public final class OBBarCodeScannerBehavior: OBBehavior {
    @IBOutlet public var containerView: UIView? {
        didSet {
            containerView?.layer.insertSublayer(cameraPreviewLayer, at: 0)
            containerBoundsObserver = containerView?.observe(\.bounds, options: .new) { [unowned self] (_, _) in
                self.updateCameraPreviewLayer()
            }
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
        .interleaved2of5,
        .itf14,
        .dataMatrix
    ]
    
    private lazy var session: AVCaptureSession = AVCaptureSession()
    private var containerBoundsObserver: NSKeyValueObservation?
    
    private lazy var cameraPreviewLayer: AVCaptureVideoPreviewLayer = {
        var layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        return layer
    }()
    
    // MARK: Public
    override public func setup() {
        super.setup()
        checkCameraAccess(completion: setupBarCodeScanner)
    }
    
    deinit {
        session.stopRunning()
        cameraPreviewLayer.removeFromSuperlayer()
    }
    
    /// The scanner is running by default. This method isn't necessary
    /// unless you have previously called `stop()`
    public func start() {
        session.startRunning()
    }
    
    public func stop() {
        session.stopRunning()
    }
}

private extension OBBarCodeScannerBehavior {
    func updateCameraPreviewLayer() {
        if let containerView = containerView {
            cameraPreviewLayer.frame = containerView.bounds
        }
    }
    
    func checkCameraAccess(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
            
        case .restricted, .denied:
            completion(false)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                DispatchQueue.main.async {
                    completion(authorized)
                }
            }
        }
    }
    
    func setupBarCodeScanner(authorized: Bool) {
        guard
            authorized,
            let device = AVCaptureDevice.default(for: AVMediaType.video),
            let input = try? AVCaptureDeviceInput(device: device)
        else {
            let delegate: OBBarCodeScannerBehaviorDelegate? = getDelegate()
            delegate?.barCodeScanner(self, didFailWithError: authorized ? .unknown : .unauthorized)
            
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
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
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
