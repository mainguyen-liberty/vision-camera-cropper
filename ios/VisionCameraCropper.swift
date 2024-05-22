@objc(VisionCameraCropper)
class VisionCameraCropper: NSObject {
    
    @objc(multiply:withB:withResolver:withRejecter:)
    func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        resolve(a*b)
    }
    
    @objc(cropImage:options:resolver:rejecter:)
    func cropImage(imagePath: String, options: NSDictionary, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        guard let image = UIImage(contentsOfFile: imagePath) else {
            rejecter("E_IMAGE_DECODE_ERROR", "Could not decode image", nil)
            return
        }
        let scale = UIScreen.main.scale
        
        let imgWidth = image.size.width
        let imgHeight = image.size.height
        let left = (options["left"] ?? 0) as! CGFloat / 100.0 * imgWidth
        let top = (options["top"] ?? 0) as! CGFloat / 100.0 * imgHeight
        let width = (options["width"] ?? 100) as! CGFloat / 100.0 * imgWidth
        let height = (options["height"] ?? 100) as! CGFloat / 100.0 * imgHeight
        
        let nameFile = options["nameFile"] as? String ?? UUID().uuidString
        let maxWidth = options["maxWidth"] as? Int ?? 0
        let maxHeight = options["maxHeight"] as? Int ?? 0
        
        let cropRect = CGRect(x: left, y: top, width: width, height: height)
        guard let croppedCGImage = image.cgImage?.cropping(to: cropRect) else {
            rejecter("E_IMAGE_CROP_ERROR", "Could not crop image", nil)
            return
        }
        
        var croppedImage = UIImage(cgImage: croppedCGImage)
        
        guard let data = croppedImage.jpegData(compressionQuality: 1.0) else {
            rejecter("E_IMAGE_SAVE_ERROR", "Could not save cropped image", nil)
            return
        }
        
        croppedImage = BitmapUtils.resizeImage(croppedImage, newWidth: maxWidth, newHeight: maxHeight)
        let fileURL = BitmapUtils.saveImage(croppedImage, nameFile: nameFile)
        let size = BitmapUtils.getFileSize(fileURL)
        resolver(fileURL)
    }
}
