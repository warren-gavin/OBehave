//
//  OBKenBurnsBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 01/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit
import CoreImage

class OBKenBurnsBehavior: OBBehavior {
    @IBOutlet public var kenBurnsView: OBKenBurnsView?
    
    @IBAction func start(_ sender: AnyObject?) {
        kenBurnsView?.animating = true
    }
    
    @IBAction func stop(_ sender: AnyObject?) {
        kenBurnsView?.animating = false
    }
}

@IBDesignable
class OBKenBurnsView: UIView {
    @IBInspectable public var detectFaces: Bool = false {
        didSet {
            applyToAllKenBurnsSubviews { subview in
                subview.detectFaces = detectFaces
            }
        }
    }
    
    @IBInspectable public var image: UIImage! {
        didSet {
            addImageSubview(image)
        }
    }
    
    @IBInspectable public var alternative1: UIImage? {
        didSet {
            addImageSubview(alternative1)
        }
    }
    
    @IBInspectable public var alternative2: UIImage? {
        didSet {
            addImageSubview(alternative2)
        }
    }
    
    @IBInspectable public var alternative3: UIImage? {
        didSet {
            addImageSubview(alternative3)
        }
    }
    
    @IBInspectable public var panningSpeed: Double = .panningSpeed {
        didSet {
            applyToAllKenBurnsSubviews { subview in
                subview.panningSpeed = panningSpeed
            }
            
            resetAnimation()
        }
    }
    
    @IBInspectable public var sceneDuration: Double = .sceneDuration {
        didSet {
            resetAnimation()
        }
    }
    
    @IBInspectable public var transitionTime: Double = .transitionTime {
        didSet {
            applyToAllKenBurnsSubviews { subview in
                subview.transitionTime = transitionTime
            }
            
            resetAnimation()
        }
    }
    
    @IBInspectable public var pause: Double = .pause {
        didSet {
            applyToAllKenBurnsSubviews { subview in
                subview.pause = pause
            }
        }
    }
    
    @IBInspectable public var maxZoom: CGFloat = .maxZoom {
        didSet {
            applyToAllKenBurnsSubviews { subview in
                subview.maximumZoomScale = maxZoom
            }
            
            resetAnimation()
        }
    }
    
    @IBInspectable public var minZoom: CGFloat = .minZoom {
        didSet {
            applyToAllKenBurnsSubviews { subview in
                subview.minimumZoomScale = minZoom
            }
            
            resetAnimation()
        }
    }
    
    @IBInspectable public var animating: Bool = false {
        willSet {
            if newValue {
                startAnimating()
            }
            else {
                stopAnimating()
            }
        }
    }
    
    fileprivate var fadeInTimer: Timer?
    
    internal func fadeBetweenSubviews() {
        let kenBurnsSubviews = allKenBurnsSubviews
        
        if kenBurnsSubviews.count < 2 {
            return
        }
        
        let subViewToDisplay = kenBurnsSubviews[Int(arc4random_uniform(UInt32(kenBurnsSubviews.count - 1)))]
        
        subViewToDisplay.alpha = 0.0
        bringSubview(toFront: subViewToDisplay)
        
        let showSubviews = {
            subViewToDisplay.alpha = 1.0
        }
        
        let completion: (Bool) -> Void = { [unowned self] finished in
            if finished {
                self.fadeInTimer = Timer.scheduledTimer(timeInterval: self.sceneDuration,
                                                        target: self,
                                                        selector: .fadeBetweenSubviews,
                                                        userInfo: nil,
                                                        repeats: false
                )
            }
        }
        
        UIView.animate(withDuration: transitionTime,
                       delay: sceneDuration,
                       options: UIViewAnimationOptions(),
                       animations:showSubviews,
                       completion: completion)
    }
}

private extension OBKenBurnsView {
    var allKenBurnsSubviews: [OBKenBurnsSubview] {
        return subviews.flatMap {
            $0 as? OBKenBurnsSubview
        }
    }
    
    func addImageSubview(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        
        let subview = OBKenBurnsSubview(maxZoom: maxZoom, minZoom: minZoom, detectFaces: detectFaces)
        
        subview.image = image
        subview.panningSpeed = panningSpeed
        subview.transitionTime = transitionTime
        subview.pause = pause
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        sendSubview(toBack: subview)

        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        layoutIfNeeded()
        
        if animating {
            subview.startAnimating()
        }
    }
    
    func resetAnimation() {
        if animating {
            animating = false
            animating = true
        }
    }
    
    func startAnimating() {
        if !animating {
            applyToAllKenBurnsSubviews { subview in
                subview.startAnimating()
            }
            
            fadeBetweenSubviews()
        }
    }
    
    func stopAnimating() {
        if animating {
            applyToAllKenBurnsSubviews { subview in
                subview.stopAnimating()
            }
            
            fadeInTimer?.invalidate()
            fadeInTimer = nil
        }
    }
    
    func applyToAllKenBurnsSubviews(_ applyToSubview: ((OBKenBurnsSubview) -> Void)) {
        allKenBurnsSubviews.forEach { applyToSubview($0) }
    }
}


private class OBKenBurnsSubview: UIScrollView {
    fileprivate var zoomIn: Bool           = false
    fileprivate var panningSpeed: Double   = .panningSpeed
    fileprivate var transitionTime: Double = .transitionTime
    fileprivate var pause: Double          = .pause
    
    var detectFaces: Bool = false
    
    var image: UIImage? {
        didSet {
            guard let image = image else {
                imageView?.removeFromSuperview()
                imageView = nil
                return
            }
            
            imageView = UIImageView(image: image)
            
            contentSize = image.size
            setContentOffset(randomOffset(at: minimumZoomScale), animated: false)
        }
    }
    
    fileprivate var imageView: UIImageView? {
        didSet {
            guard let imageView = imageView else {
                return
            }
            
            imageView.contentMode = .topLeft
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(imageView)
        }
    }
    
    convenience init(maxZoom: CGFloat, minZoom: CGFloat, detectFaces: Bool) {
        self.init()
        
        self.maximumZoomScale = maxZoom
        self.minimumZoomScale = minZoom
        self.detectFaces      = detectFaces
        
        delegate         = self
    }
    
    @objc
    func startAnimating() {
        let zoom = toggledZoom()
        let offset = newOffset(zoom)
        let duration = timeToReach(point: offset, atZoom: zoom)
        
        let move = { [unowned self] in
            let rect = CGRect(origin: offset, size: CGSize(width: self.bounds.size.width / zoom, height: 1))
            
            self.zoom(to: rect, animated: false)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64((self.pause + duration) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                self.startAnimating()
            }
        }
        
        UIView.animate(withDuration: duration,
                       delay: .animationDelay,
                       options: .beginFromCurrentState,
                       animations: move,
                       completion: nil
        )
    }
    
    func stopAnimating() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: .startAnimating, object: nil)
    }
}

private extension OBKenBurnsSubview {
    func newOffset(_ zoom: CGFloat) -> CGPoint {
        guard let cgImage = image?.cgImage, detectFaces else {
            return randomOffset(at: zoom)
        }
        
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let detective = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
        
        guard let features = detective?.features(in: CIImage(cgImage: cgImage)), !features.isEmpty else {
            return randomOffset(at: zoom)
        }
        
        let bounds = features[Int(arc4random_uniform(UInt32(features.count)))].bounds
        return CGPoint(x: bounds.origin.x + bounds.size.width / 2,
                       y: bounds.origin.y + bounds.size.height / 2)
    }
    
    func randomOffset(at zoom: CGFloat) -> CGPoint {
        guard let window = UIApplication.shared.delegate?.window, let image = image else {
            return CGPoint.zero
        }
        
        let windowSize = window!.bounds.size
        
        let x = arc4random_uniform(UInt32(abs((image.size.width - windowSize.width) * zoom)))
        let y = arc4random_uniform(UInt32(abs((image.size.height - windowSize.height) * zoom)))
        
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    func toggledZoom() -> CGFloat {
        zoomIn = !zoomIn
        return (zoomIn ? maximumZoomScale : minimumZoomScale)
    }
    
    func distanceFromCenterToPoint(_ point: CGPoint, atZoom zoom: CGFloat) -> Double {
        return Double(sqrt(pow(contentOffset.x * zoom - point.x, 2) + pow(contentOffset.y * zoom - point.y, 2)))
    }
    
    func timeToReach(point: CGPoint, atZoom zoom: CGFloat) -> TimeInterval {
        return min(distanceFromCenterToPoint(point, atZoom: zoom) / panningSpeed, .maximumPanningTime)
    }
}

// MARK: UIScrollViewDelegate
extension OBKenBurnsSubview: UIScrollViewDelegate {
    @objc
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

private extension Selector {
    static let fadeBetweenSubviews = #selector(OBKenBurnsView.fadeBetweenSubviews)
    static let startAnimating      = #selector(OBKenBurnsSubview.startAnimating)
}

private extension Double {
    static let panningSpeed = 3.0
    static let animationDelay = 0.0
    static let sceneDuration = 10.0
    static let transitionTime = 3.0
    static let pause = 2.0
    static let maximumPanningTime = 20.0
}

private extension CGFloat {
    static let maxZoom: CGFloat = 1.5
    static let minZoom: CGFloat = 1.0
}
