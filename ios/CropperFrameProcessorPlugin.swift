//
//  CropperFrameProcessorPlugin.swift
//  VisionCameraCropper
//
//  Created by xulihang on 2024/2/21.
//

import Foundation

@objc(CropperFrameProcessorPlugin)
public class CropperFrameProcessorPlugin: FrameProcessorPlugin {
    public override init(proxy: VisionCameraProxyHolder, options: [AnyHashable : Any]! = [:]) {
        super.init(proxy: proxy, options: options)
    }
    
    public override func callback(_ frame: Frame, withArguments arguments: [AnyHashable : Any]?) -> Any {
        let maxWidth = arguments!["maxWidth"] as? Int ?? 0
        let maxHeight = arguments!["maxHeight"] as? Int ?? 0
        
        let buffer = frame.buffer
        var cropResult: [String:Any] = [:]
        guard let imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer) else {
            print("Failed to get CVPixelBuffer!")
            return cropResult
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        guard let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) else {
            print("Failed to create CGImage!")
            return cropResult
        }
        
        var image:UIImage;
        let cropRegion = arguments?["cropRegion"] as? [String: Int]
        if cropRegion != nil {
            let imgWidth = Double(cgImage.width)
            let imgHeight = Double(cgImage.height)
            let left:Double = Double(cropRegion?["left"] ?? 0) / 100.0 * imgWidth
            let top:Double = Double(cropRegion?["top"] ?? 0) / 100.0 * imgHeight
            let width:Double = Double(cropRegion?["width"] ?? 100) / 100.0 * imgWidth
            let height:Double = Double(cropRegion?["height"] ?? 100) / 100.0 * imgHeight
            
            // The cropRect is the rect of the image to keep,
            // in this case centered
            let cropRect = CGRect(
                x: left,
                y: top,
                width: width,
                height: height
            ).integral
            
            let cropped = cgImage.cropping(
                to: cropRect
            )!
            image = UIImage(cgImage: cropped)
            print("use cropped image")
        }else{
            image = UIImage(cgImage: cgImage)
        }
        let includeImageBase64 = arguments!["includeImageBase64"] as? Bool ?? false
        if includeImageBase64 == true {
            cropResult["base64"] = getBase64FromImage(image)
        }
        
        if includeImageBase64 == true {
            cropResult["base64"] = getBase64FromImage(image)
        }
        let saveAsFile = arguments!["saveAsFile"] as? Bool ?? false
        let nameFile = arguments!["nameFile"] as? String ?? UUID().uuidString
        
        image = resizeImage(image, newWidth: maxWidth, newHeight: maxHeight)
        
        if saveAsFile == true {
            cropResult["path"] = saveImage(image, nameFile: nameFile)
        }
        return cropResult
    }
    
    func resizeImage(_ image: UIImage, newWidth: Int, newHeight: Int) -> UIImage {
        let imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
        let _newWidth = CGFloat(newWidth)
        let _newHeight = CGFloat(newHeight)
        
        if newWidth>0 && newHeight>0{
            let widthRatio = _newWidth / imageSize.width
            let heightRatio = _newHeight / imageSize.height
            
            var ratio = min(widthRatio, heightRatio)
            ratio = min(ratio, 1)
            let newSize = CGSizeMake(imageSize.width * ratio, imageSize.height * ratio)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage ?? image
        }
        return image
    }
    
    func getFileSize(_ filePath:String) -> Int64? {
        do {
            // Lấy thông tin của tệp
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            // Lấy kích thước từ thông tin tệp
            if let fileSize = fileAttributes[.size] as? Int64 {
                return fileSize
            } else {
                return 0
            }
        } catch {
            print("Error getting file size: \(error.localizedDescription)")
            return 0
        }
    }
    
    
    func saveImage(_ image:UIImage, nameFile: String) -> String {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(nameFile)
            .appendingPathExtension("jpeg")
        try? image.jpegData(compressionQuality: 1.0)?.write(to: url)
        return url.path
    }
    
    func getBase64FromImage(_ image:UIImage) -> String {
        let dataTmp = image.jpegData(compressionQuality: 100)
        if let data = dataTmp {
            return data.base64EncodedString()
        }
        return ""
    }
}
