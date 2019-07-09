//
//  OBBlurImageBehaviorEffect.swift
//  OBehave
//
//  Created by Warren Gavin on 02/11/15.
//  Copyright © 2015 Apokrupto. All rights reserved.
//

import UIKit
import Accelerate

public final class OBBlurImageBehaviorEffect: OBBehaviorEffect {
    @IBInspectable public var maxRadius: CGFloat = .maxRadius
    @IBInspectable public var saturation: CGFloat = .saturation
    @IBInspectable public var tintColor: UIColor?

    override public func performEffect(on object: AnyObject?, percentage percent: CGFloat) -> AnyObject? {
        guard let image = object as? UIImage, percent > 0 else {
            return super.performEffect(on: object, percentage: percent)
        }
        
        return image.applyBlur(withRadius: percent * maxRadius,
                               tintColor: tintColor?.withAlphaComponent(percent / 2.0),
                               saturationDeltaFactor: .saturation + (percent * (saturation - .saturation)),
                               maskImage:nil)
    }
}

private extension CGFloat {
    static let maxRadius:  CGFloat = 40.0
    static let saturation: CGFloat = 1.0
    static let effectSaturation: CGFloat = 1.8
    static let effectColorAlpha: CGFloat = 0.6
    static let saturationDivisor: CGFloat = 256.0
    static let floatEpsilon = CGFloat(Float.ulpOfOne)
}

extension UIBlurEffect.Style {
    func color() -> UIColor {
        switch self {
        case .extraLight:
            return UIColor(white: 0.97, alpha: 0.82)
            
        case .dark, .extraDark:
            return UIColor(white: 0.11, alpha: 0.73)

        case .light, .prominent, .regular:
            return UIColor(white: 1.0, alpha: 0.3)

        default:
            return UIColor(white: 1.0, alpha: 0.3)
        }
    }
    
    func radius() -> CGFloat {
        switch self {
        case .light, .prominent, .regular:
            return 30.0
            
        case .extraLight, .dark, .extraDark:
            return 20.0

        default:
            return 30.0
        }
    }
}

extension UIImage {
    private func createEffectBuffer(context: CGContext) -> vImage_Buffer {
        return vImage_Buffer(data: context.data,
                             height: vImagePixelCount(context.height),
                             width: vImagePixelCount(context.width),
                             rowBytes: context.bytesPerRow)
    }
    
    private func applyBlur(inputRadius: CGFloat,
                           effectInContext: CGContext,
                           effectOutContext: CGContext) -> (vImage_Buffer, vImage_Buffer) {
        var effectInBuffer = createEffectBuffer(context: effectInContext)
        var effectOutBuffer = createEffectBuffer(context: effectOutContext)
        
        if inputRadius > .floatEpsilon {
            let tmp = floor(inputRadius * 3.0 * CGFloat(sqrt(2 * .pi)) / 4 + 0.5)
            var radius = UInt32(tmp)
            radius += (radius % 2 == 0 ? 1 : 0)
            
            let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
            
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
        }
        
        return (effectInBuffer, effectOutBuffer)
    }
    
    private func blurAndSaturate(blurRadius: CGFloat,
                                 saturationDeltaFactor: CGFloat,
                                 hasSaturationChange: Bool,
                                 imageRect: CGRect,
                                 screenScale: CGFloat) -> UIImage? {
        var effectImage = self
        
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let effectInContext = UIGraphicsGetCurrentContext(), let image = cgImage else {
            return nil
        }
        
        effectInContext.scaleBy(x: 1.0, y: -1.0)
        effectInContext.translateBy(x: 0, y: -size.height)
        effectInContext.draw(image, in: imageRect)
        
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        guard let effectOutContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        let (effectInBuffer, effectOutBuffer) = applyBlur(inputRadius: blurRadius * screenScale,
                                                          effectInContext: effectInContext,
                                                          effectOutContext: effectOutContext)
        
        var effectImageBuffersAreSwapped = false
        
        if hasSaturationChange {
            let s = saturationDeltaFactor
            let saturationMatrix: [Int16] = [
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,                    1
                ].map { (value: CGFloat) -> Int16 in
                    Int16(round(value * .saturationDivisor))
            }
            
            var srcBuffer = effectInBuffer
            var dstBuffer = effectOutBuffer
            
            if blurRadius > .floatEpsilon {
                srcBuffer = effectOutBuffer
                dstBuffer = effectInBuffer
                effectImageBuffersAreSwapped = (blurRadius > .floatEpsilon)
            }
            
            vImageMatrixMultiply_ARGB8888(&srcBuffer,
                                          &dstBuffer,
                                          saturationMatrix,
                                          Int32(.saturationDivisor),
                                          nil,
                                          nil,
                                          vImage_Flags(kvImageNoFlags))
        }
        
        if !effectImageBuffersAreSwapped {
            effectImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        else {
            UIGraphicsEndImageContext()
            effectImage = UIGraphicsGetImageFromCurrentImageContext()!
        }
        
        return effectImage
    }
    
    private func outputImage(image: UIImage,
                             maskImage: UIImage?,
                             hasBlur: Bool,
                             tintColor: UIColor?,
                             screenScale: CGFloat,
                             imageRect: CGRect) -> UIImage? {
        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard
            let outputContext = UIGraphicsGetCurrentContext(),
            let inputImage = image.cgImage
        else {
            return nil
        }
        
        outputContext.scaleBy(x: 1.0, y: -1.0)
        outputContext.translateBy(x: 0, y: -size.height)
        
        // Draw base image.
        outputContext.draw(inputImage, in: imageRect)
        
        // Draw effect image.
        if hasBlur {
            outputContext.saveGState()
            if let maskImage = maskImage?.cgImage, let image = image.cgImage {
                outputContext.clip(to: imageRect, mask: maskImage)
                outputContext.draw(image, in: imageRect)
            }
            outputContext.restoreGState()
        }
        
        // Add in color tint.
        if let tintColor = tintColor {
            outputContext.saveGState()
            outputContext.setFillColor(tintColor.cgColor)
            outputContext.fill(imageRect)
            outputContext.restoreGState()
        }
        
        // Output image is ready.
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    @nonobjc
    internal func applyBlurEffect(effect: UIBlurEffect.Style, saturation: CGFloat = .effectSaturation) -> UIImage? {
        return applyBlur(withRadius: effect.radius(), tintColor: effect.color(), saturationDeltaFactor: saturation)
    }
    
    @nonobjc
    internal func applyTintEffectWithColor(tintColor: UIColor) -> UIImage? {
        var effectColor = tintColor
        
        var red: CGFloat   = 0
        var green: CGFloat = 0
        var blue: CGFloat  = 0
        
        if tintColor.getRed(&red, green: &green, blue: &blue, alpha: nil) {
            effectColor = UIColor(red: red, green: green, blue: blue, alpha: .effectColorAlpha)
        }
        
        return applyBlur(withRadius: 10, tintColor: effectColor, saturationDeltaFactor: -1.0, maskImage: nil)
    }
    
    @nonobjc
    internal func applyBlur(withRadius blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if (size.width < 1 || size.height < 1) {
            return nil
        }
        
        if cgImage == nil {
            return nil
        }
        
        if let maskImage = maskImage, maskImage.cgImage == nil {
            return nil
        }
        
        let hasBlur = blurRadius > .floatEpsilon
        let hasSaturationChange = abs(saturationDeltaFactor - 1.0) > .floatEpsilon
        
        let screenScale = UIScreen.main.scale
        let imageRect = CGRect(origin: .zero, size: size)
        var effectImage = self
        
        if hasBlur || hasSaturationChange {
            guard let blurredAndSaturatedImage = blurAndSaturate(blurRadius: blurRadius,
                                                                 saturationDeltaFactor: saturationDeltaFactor,
                                                                 hasSaturationChange: hasSaturationChange,
                                                                 imageRect: imageRect,
                                                                 screenScale: screenScale)
            else {
                return nil
            }
            
            effectImage = blurredAndSaturatedImage
        }
        
        return outputImage(image: effectImage,
                           maskImage: maskImage,
                           hasBlur: hasBlur,
                           tintColor: tintColor,
                           screenScale: screenScale,
                           imageRect: imageRect)
    }
}
