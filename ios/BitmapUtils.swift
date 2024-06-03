//
//  BitmapUtils.swift
//  VisionCameraCropper
//
//  Created by Nguyen Mai on 21/05/2024.
//

import Foundation
class BitmapUtils {
    static func resizeImage(_ image: UIImage, newWidth: Int, newHeight: Int) -> UIImage {
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
    
    static func getMinQuality(_ image: UIImage,path:String, quality: CGFloat, maxSizeInMB: CGFloat)-> CGFloat?{
        guard let resizedImageData = image.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        let maxSizeInBytes: Int = Int(maxSizeInMB * 1024 * 1024)
        
        var compressionQuality: CGFloat = quality
        while resizedImageData.count > maxSizeInBytes && compressionQuality > 0 {
            compressionQuality -= 0.1
            guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
                return nil
            }
            if compressionQuality == 0 {
                break
            }
        }
        return compressionQuality
    }
    
    static func getFileSize(_ filePath:String) -> Int64? {
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
    
    
    static func saveImage(_ image:UIImage, nameFile: String) -> String {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(nameFile)
            .appendingPathExtension("jpeg")
        try? image.jpegData(compressionQuality: 1.0)?.write(to: url)
        return url.path
    }
    
    static func compressImage(_ image:UIImage, path: String, quality: CGFloat) -> String {
        try? image.jpegData(compressionQuality: quality)?.write(to: URL(fileURLWithPath: path))
        return path
    }
    
    static func getBase64FromImage(_ image:UIImage) -> String {
        let dataTmp = image.jpegData(compressionQuality: 100)
        if let data = dataTmp {
            return data.base64EncodedString()
        }
        return ""
    }
    
    static func clearCacheDirectory(_ directory: URL) {
        do {
            // Get the contents of the temporary directory
            let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [])
            
            // Iterate over each item
            for itemURL in contents {
                var isDirectory: ObjCBool = false
                // Check if the item is a file
                if FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDirectory) && !isDirectory.boolValue {
                    // Remove the file
                    try FileManager.default.removeItem(at: itemURL)
                }
            }
        } catch {}
    }
}
