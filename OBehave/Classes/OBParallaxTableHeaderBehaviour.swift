//
//  OBParallaxTableHeaderBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 04/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let tableWillMove = Notification.Name(rawValue: "com.apokrupto.OBParallaxTableHeaderBehavior.tableWillMove")
    static let tableDidMove  = Notification.Name(rawValue: "com.apokrupto.OBParallaxTableHeaderBehavior.tableDidMove")
    static let tableWillStop = Notification.Name(rawValue: "com.apokrupto.OBParallaxTableHeaderBehavior.tableWillStop")
}

class OBParallaxTableHeaderBehavior: OBBehavior {
    ///     speed  < 0 - header moves faster than table
    ///     speed == 0 - header moves with table
    /// 0 < speed  < 1 - table moves faster than header
    ///     speed == 1 - header doesn't move
    ///     speed  > 1 - table and header move in different directions
    @IBInspectable var relativeSpeed: CGFloat = 0.0

    @IBOutlet var imageView: UIImageView? {
        didSet {
            headerImage = imageView?.image?.copy() as? UIImage
        }
    }
    
    private var headerImage: UIImage?
    private var lastScrollPoint: CGFloat = 0.0
    
    func tableHeaderStartMoving(_ notification: Notification?) {
        imageView?.frame = resizedImageFrame()
    }
    
    func tableHeaderStopping(_ notification: Notification?) {
        guard let header = imageView?.superview,
            let offsetInfo = notification?.userInfo as? [String: CGFloat],
            let point = offsetInfo["point"] else {
                return
        }
        
        imageView?.frame = header.bounds
        imageView?.image = headerImage
        lastScrollPoint = point
    }
    
    func tableHeaderMoved(_ notification: Notification?) {
        guard let offsetInfo = notification?.userInfo as? [String: CGFloat], let point = offsetInfo["point"] else {
            return
        }
        
        let offset = (point - lastScrollPoint) * relativeSpeed
        
        if -maxOffset() < offset && offset < maxOffset() {
            imageView?.frame = resizedImageFrame().offsetBy(dx: offset, dy: 0)
        }
    }
    
    override func setup() {
        super.setup()
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: .tableHeaderStartMoving, name: .tableWillMove, object: nil)
        notificationCenter.addObserver(self, selector: .tableHeaderStopping,    name: .tableWillStop, object: nil)
        notificationCenter.addObserver(self, selector: .tableHeaderMoved,       name: .tableDidMove,  object: nil)
        
        lastScrollPoint = 0.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension OBParallaxTableHeaderBehavior {
    func resizedImageWidth() -> CGFloat {
        guard let image = imageView?.image, let header = imageView?.superview else {
            return 0.0
        }
        
        return image.size.width * header.bounds.size.height / image.size.height
    }
    
    func resizedImageFrame() -> CGRect {
        guard let header = imageView?.superview else {
            return CGRect.zero
        }
        
        return CGRect(x: -maxOffset(), y: 0, width: resizedImageWidth(), height: header.bounds.size.height)
    }
    
    func maxOffset() -> CGFloat {
        guard let header = imageView?.superview else {
            return 0.0
        }
        
        return (resizedImageWidth() - header.bounds.size.width) / 2.0
    }
}

private extension Selector {
    static let tableHeaderStartMoving = #selector(OBParallaxTableHeaderBehavior.tableHeaderStartMoving(_:))
    static let tableHeaderStopping    = #selector(OBParallaxTableHeaderBehavior.tableHeaderStopping(_:))
    static let tableHeaderMoved       = #selector(OBParallaxTableHeaderBehavior.tableHeaderMoved(_:))
}

