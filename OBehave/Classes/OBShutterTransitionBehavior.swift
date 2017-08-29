//
//  OBShutterTransitionBehavior.swift
//  OBehave
//
//  Created by Warren Gavin on 20/01/2016.
//  Copyright © 2017 Apokrupto. All rights reserved.
//

import UIKit

/// Shutter settings
public protocol OBShutterTransitionBehaviorDataSource: OBTransitionDelegateBehaviorDataSource {
    var topHeight: CGFloat { get }
}

// The shutter presentation splits the displayed view in two and initialises
// the two views offscreen. The transition animates the top and bottom views
// coming together, as they combine to create the presented view
public class OBShutterTransitionBehavior: OBTransitionDelegateBehavior {
    private var topView: UIImageView?
    private var bottomView: UIImageView?
    private var subviews: [UIView]?
    private var backgroundColor: UIColor?
    private var presentedView: UIView?
    
    override public func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) -> (() -> Void)? {
        guard let presentedView = transitionContext.view(forKey: .to) else {
            return nil
        }
        
        let dataSource: OBShutterTransitionBehaviorDataSource? = getDataSource()
        let height = dataSource?.topHeight ?? .defaultTopHeight
        
        (topView, bottomView) = split(view: presentedView, at: height)
        
        if let topView = topView {
            topView.frame = CGRect(origin: CGPoint(x: 0, y: -height), size: topView.bounds.size)
        }

        if let bottomView = bottomView {
            bottomView.frame = CGRect(origin: CGPoint(x: 0, y: presentedView.bounds.size.height), size: bottomView.bounds.size)
        }
        
        backgroundColor = presentedView.backgroundColor
        subviews = presentedView.subviews.filter {
            $0.alpha == 1.0
        }
        
        presentedView.backgroundColor = .clear
        subviews?.forEach {
            $0.alpha = 0.0
        }
        
        [topView, bottomView].flatMap({ $0 }).forEach {
            presentedView.addSubview($0)
        }
    
        return { [unowned self] in
            if let topView = self.topView {
                topView.frame = CGRect(origin: .zero, size: topView.bounds.size)
            }
            
            if let bottomView = self.bottomView {
                bottomView.frame = CGRect(origin: CGPoint(x: 0, y: height), size: bottomView.bounds.size)
            }
        }
    }
    
    override public func cleanupPresentation() -> ((Bool) -> Void)? {
        return {  [unowned self] finished in
            if finished {
                self.topView?.removeFromSuperview()
                self.bottomView?.removeFromSuperview()
            }

            self.subviews?.forEach {
                $0.alpha = 1.0
            }
            
            self.presentedView?.backgroundColor = self.backgroundColor
        }
    }
    
    override public func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) -> (() -> Void)? {
        guard let presentingView = transitionContext.view(forKey: .from) else {
            return nil
        }
        
        let dataSource: OBShutterTransitionBehaviorDataSource? = getDataSource()
        let height = dataSource?.topHeight ?? .defaultTopHeight
        
        let (topView, bottomView) = split(view: presentingView, at: height)
        
        if let topView = topView {
            topView.frame = CGRect(origin: .zero, size: topView.bounds.size)
        }
        
        if let bottomView = bottomView {
            bottomView.frame = CGRect(origin: CGPoint(x: 0, y: height), size: bottomView.bounds.size)
        }

        presentingView.backgroundColor = .clear
        presentingView.subviews.forEach {
            $0.alpha = 0.0
        }
        
        [topView, bottomView].flatMap({ $0 }).forEach {
            presentingView.addSubview($0)
        }
        
        return {
            if let topView = topView {
                topView.frame = CGRect(origin: CGPoint(x: 0, y: -height), size: topView.bounds.size)
            }
            
            if let bottomView = bottomView {
                bottomView.frame = CGRect(origin: CGPoint(x: 0, y: presentingView.bounds.size.height), size: bottomView.bounds.size)
            }
        }
    }
}

private extension OBShutterTransitionBehavior {
    func split(view: UIView, at height: CGFloat) -> (UIImageView?, UIImageView?) {
        let frames = (top: CGRect(origin: .zero, size: CGSize(width: view.bounds.size.width, height: height)),
                      bottom: CGRect(origin: CGPoint(x: 0, y: height), size: CGSize(width: view.bounds.size.width,
                                                                                    height: view.bounds.size.height - height)))
        
        let topImage    = view.imageRepresentation(of: frames.top)
        let bottomImage = view.imageRepresentation(of: frames.bottom)
        
        return (UIImageView(image: topImage), UIImageView(image: bottomImage))
    }
}

private extension UIView {
    func imageRepresentation(of frame: CGRect) -> UIImage? {
        guard frame.size.height >= 0.0 else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        
        guard var snapshot = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        if bounds != frame {
            let scaledFrame = CGRect(x: snapshot.scale * frame.origin.x,
                                     y: snapshot.scale * frame.origin.y,
                                     width: snapshot.scale * frame.size.width,
                                     height: snapshot.scale * frame.size.height)
            
            guard let croppedImageRef = snapshot.cgImage?.cropping(to: scaledFrame) else {
                return nil
            }

            snapshot = UIImage(cgImage: croppedImageRef,
                               scale: snapshot.scale,
                               orientation: snapshot.imageOrientation)
        }
        
        return snapshot
    }
}

// MARK: - Constants
private extension CGFloat {
    static let defaultTopHeight: CGFloat = 280.0
}
