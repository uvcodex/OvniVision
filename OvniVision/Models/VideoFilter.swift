//
//  VideoFilter.swift
//  OvniVision
//
//  Created by Ulises Vazquez on 3/17/26.
//

import Foundation
import CoreImage

enum VideoFilter {
    case noir
    case colorInvert
    case thermal

    var displayName: String {
        switch self {
        case .noir:        return "NOIR"
        case .colorInvert: return "INVERTED"
        case .thermal:     return "THERMAL"
        }
    }

    func apply(to image: CIImage) -> CIImage? {
        switch self {
        case .noir:
            return image.applyingFilter("CIPhotoEffectNoir")
        case .colorInvert:
            return image.applyingFilter("CIColorInvert")
        case .thermal:
            // Create thermal/heat map effect exactly like Apple's example
            // Step 1: Create a red→yellow→green gradient (thermal palette)
            let gradientSize = 256
            var gradientData = [Float]()
            
            for i in 0..<gradientSize {
                let t = Float(i) / Float(gradientSize - 1)
                
                if t < 0.5 {
                    // Red to Yellow (0.0 to 0.5)
                    let localT = t * 2.0
                    gradientData.append(1.0) // R
                    gradientData.append(localT) // G
                    gradientData.append(0.0) // B
                    gradientData.append(1.0) // A
                } else {
                    // Yellow to Green (0.5 to 1.0)
                    let localT = (t - 0.5) * 2.0
                    gradientData.append(1.0 - localT) // R
                    gradientData.append(1.0) // G
                    gradientData.append(0.0) // B
                    gradientData.append(1.0) // A
                }
            }
            
            // Create gradient image from data
            let gradientDataNS = NSData(bytes: gradientData, length: gradientData.count * MemoryLayout<Float>.size)
            let gradientImage = CIImage(bitmapData: gradientDataNS as Data,
                                        bytesPerRow: gradientSize * 4 * MemoryLayout<Float>.size,
                                        size: CGSize(width: gradientSize, height: 1),
                                        format: .RGBAf,
                                        colorSpace: CGColorSpaceCreateDeviceRGB())
            
            // Step 2: Apply color map to the image
            let colorMap = CIFilter(name: "CIColorMap")
            colorMap?.setValue(image, forKey: kCIInputImageKey)
            colorMap?.setValue(gradientImage, forKey: "inputGradientImage")
            
            return colorMap?.outputImage
        }
    }
}
