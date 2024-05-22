package com.visioncameracropper;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.uimanager.PixelUtil;

import java.io.File;
@ReactModule(name = VisionCameraCropperModule.NAME)
public class VisionCameraCropperModule extends ReactContextBaseJavaModule {
  public static final String NAME = "VisionCameraCropper";
  private static ReactApplicationContext mContext;
  public VisionCameraCropperModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mContext = reactContext;
  }
  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  public static ReactApplicationContext getContext(){
    return mContext;
  }

  // Example method
  // See https://reactnative.dev/docs/native-modules-android
  @ReactMethod
  public void multiply(double a, double b, Promise promise) {
    promise.resolve(a * b);
  }

  @ReactMethod
  public void cropImage(String imagePath, ReadableMap options, Promise promise) {
    try {
      BitmapFactory.Options bmOptions = new BitmapFactory.Options();
      Bitmap bitmap = BitmapFactory.decodeFile(imagePath, bmOptions);
      if (bitmap == null) {
        promise.reject("E_IMAGE_DECODE_ERROR", "Could not decode image at " + imagePath);
        return;
      }

      float width = (float) options.getDouble("width");
      float height = (float) options.getDouble("height");

      int left = (int) PixelUtil.toPixelFromDIP(options.getDouble("left"));
      int top = (int) PixelUtil.toPixelFromDIP(options.getDouble("top"));
      int cropWidth = (int) PixelUtil.toPixelFromDIP(width);
      int cropHeight = (int) PixelUtil.toPixelFromDIP(height);
      String nameFile = (String) options.getString("nameFile");

      int maxWidth = (int)width;
      int maxHeight = (int)height;

      if (options.hasKey("maxWidth")) {
        maxWidth = (int) options.getDouble("maxWidth");
      }
      if (options.hasKey("maxHeight")) {
        maxHeight = (int) options.getDouble("maxHeight");
      }

      Bitmap croppedBitmap = Bitmap.createBitmap(bitmap, (int) left, (int) top, (int) cropWidth, (int) cropHeight);
      croppedBitmap = BitmapUtils.resizeImage(croppedBitmap,maxWidth,maxHeight);

      File cacheDir = VisionCameraCropperModule.getContext().getCacheDir();
      String path = BitmapUtils.saveImage(croppedBitmap,cacheDir,nameFile,100);
      promise.resolve(path);
    } catch (Exception e) {
      promise.reject("E_IMAGE_CROP_ERROR", "Image cropping failed", e);
    }
  }
}
