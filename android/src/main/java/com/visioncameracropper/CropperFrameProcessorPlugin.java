package com.visioncameracropper;
import android.graphics.Bitmap;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.mrousavy.camera.core.FrameInvalidError;
import com.mrousavy.camera.frameprocessors.Frame;
import com.mrousavy.camera.frameprocessors.FrameProcessorPlugin;
import com.mrousavy.camera.frameprocessors.VisionCameraProxy;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CropperFrameProcessorPlugin extends FrameProcessorPlugin {
  CropperFrameProcessorPlugin(@NonNull VisionCameraProxy proxy, @Nullable Map<String, Object> options) {super();}

  @Nullable
  @Override
  public Object callback(@NonNull Frame frame, @Nullable Map<String, Object> arguments) {
    Map<String, Object> result = new HashMap<String, Object>();
    try {
      Bitmap bm = BitmapUtils.getBitmap(frame);
      if (arguments != null && arguments.containsKey("cropRegion")) {
        Map<String,Object> cropRegion = (Map<String, Object>) arguments.get("cropRegion");
        double left = ((double) cropRegion.get("left")) / 100.0 * bm.getWidth();
        double top = ((double) cropRegion.get("top")) / 100.0 * bm.getHeight();
        double width = ((double) cropRegion.get("width")) / 100.0 * bm.getWidth();
        double height = ((double) cropRegion.get("height")) / 100.0 * bm.getHeight();
        bm = Bitmap.createBitmap(bm, (int) left, (int) top, (int) width, (int) height, null, false);
      }

      if (arguments != null && arguments.containsKey("includeImageBase64")) {
        boolean includeImageBase64 = (boolean) arguments.get("includeImageBase64");
        if (includeImageBase64 == true) {
          result.put("base64",BitmapUtils.bitmap2Base64(bm));
        }
      }

      int maxWidth = 0;
      int maxHeight = 0;

      if (arguments != null && arguments.containsKey("maxWidth")) {
        maxWidth = (int) Double.valueOf((double)arguments.get("maxWidth")).intValue();
      }
      if (arguments != null && arguments.containsKey("maxHeight")) {
        maxHeight = (int) Double.valueOf((double)arguments.get("maxHeight")).intValue();
      }

      bm = BitmapUtils.resizeImage(bm,maxWidth,maxHeight);
      if (arguments != null && arguments.containsKey("saveAsFile")) {
        boolean saveAsFile = (boolean) arguments.get("saveAsFile");
        String fileName = System.currentTimeMillis() + ".jpg";
        if(arguments.containsKey("nameFile")){
          fileName = (String) arguments.get("nameFile") + ".jpg";
        }
        if (saveAsFile == true) {
          File cacheDir = VisionCameraCropperModule.getContext().getCacheDir();
          String path = BitmapUtils.saveImage(bm,cacheDir,fileName,100);
//          float size = BitmapUtils.getFileSize(path);
          result.put("path",path);
        }
      }
    } catch (FrameInvalidError e) {
      throw new RuntimeException(e);
    }
    return result;
  }
}
