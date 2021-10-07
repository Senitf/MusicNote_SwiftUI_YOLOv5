//
//  UIImageExtension.swift
//  MusicNote
//
//  Created by 김민호 on 2021/10/06.
//

import Foundation
import UIKit

extension UIImage {
    func resized(from prevSize: CGSize, to newSize: CGSize, scale: CGFloat = 1) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        let image = renderer.image { _ in
            //draw(in: CGRect(origin: .zero, size: newSize))
            draw(in: CGRect(origin: .zero, size: prevSize))
        }
        return image
    }
    
    func normalized() -> [Float32]? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        let w = cgImage.width
        let h = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * w
        let bitsPerComponent = 8
        var rawBytes: [UInt8] = [UInt8](repeating: 0, count: w * h * 4)
        var r, g, b, a: Float32
        rawBytes.withUnsafeMutableBytes { ptr in
            if let cgImage = self.cgImage,
                let context = CGContext(data: ptr.baseAddress,
                                        width: w,
                                        height: h,
                                        bitsPerComponent: bitsPerComponent,
                                        bytesPerRow: bytesPerRow,
                                        space: CGColorSpaceCreateDeviceRGB(),
                                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                let rect = CGRect(x: 0, y: 0, width: w, height: h)
                context.draw(cgImage, in: rect)
            }
        }
        var normalizedBuffer: [Float32] = [Float32](repeating: 0, count: w * h * 3)
        for i in 0 ..< w * h {
            /*
            normalizedBuffer[i] = abs(Float32(rawBytes[i * 4 + 0]) / 255.0 - 1)
            normalizedBuffer[w * h + i] = abs(Float32(rawBytes[i * 4 + 1]) / 255.0 - 1)
            normalizedBuffer[w * h * 2 + i] = abs(Float32(rawBytes[i * 4 + 2]) / 255.0 - 1)
            */
            /*
            normalizedBuffer[i] = abs(Float32(rawBytes[i * 4 + 0]) - 255.0)
            normalizedBuffer[w * h + i] = abs(Float32(rawBytes[i * 4 + 1]) - 255.0)
            normalizedBuffer[w * h * 2 + i] = abs(Float32(rawBytes[i * 4 + 2]) - 255.0)
            */
            r = Float32(rawBytes[i * 4 + 0])
            g = Float32(rawBytes[i * 4 + 1])
            b = Float32(rawBytes[i * 4 + 2])
            a = Float32(rawBytes[i * 4 + 3]) / 255.0
            normalizedBuffer[i] = 255.0 - (r * a + (1.0 - a) * 255.0)
            normalizedBuffer[w * h + i] = 255.0 - (g * a + (1.0 - a) * 255.0)
            normalizedBuffer[w * h * 2 + i] = 255.0 - (b * a + (1.0 - a) * 255.0)
        }
        return normalizedBuffer
    }
    
    /*
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
      
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    */

    func overlayWith(image: UIImage, posX: CGFloat, posY: CGFloat) -> UIImage {
        let newWidth = size.width < posX + image.size.width ? posX + image.size.width : size.width
        let newHeight = size.height < posY + image.size.height ? posY + image.size.height : size.height
        let newSize = CGSize(width: newWidth, height: newHeight)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        image.draw(in: CGRect(origin: CGPoint(x: posX, y: posY), size: image.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return newImage
    }
}
