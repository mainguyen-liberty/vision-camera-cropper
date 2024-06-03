import {NativeModules, Platform} from 'react-native';
import {VisionCameraProxy, type Frame} from 'react-native-vision-camera';

const LINKING_ERROR =
  `The package 'vision-camera-cropper' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ios: "- You have run 'pod install'\n", default: ''}) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const VisionCameraCropper = NativeModules.VisionCameraCropper
  ? NativeModules.VisionCameraCropper
  : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    }
  );

const plugin = VisionCameraProxy.initFrameProcessorPlugin('crop');

export function multiply(a: number, b: number): Promise<number> {
  return VisionCameraCropper.multiply(a, b);
}

/**
 * Crop
 */
export function crop(frame: Frame, config?: CropConfig): CropResult {
  'worklet'
  if (plugin == null) throw new Error('Failed to load Frame Processor Plugin "crop"!')
  if (config) {
    let record: Record<string, any> = {};
    record["maxWidth"] = config.maxWidth ?? 0
    record["maxHeight"] = config.maxHeight ?? 0
    if (config.includeImageBase64 != undefined && config.includeImageBase64 != null) {
      record["includeImageBase64"] = config.includeImageBase64;
    }
    if (config.saveAsFile != undefined && config.saveAsFile != null) {
      record["saveAsFile"] = config.saveAsFile;
    }
    if (config.nameFile != undefined && config.nameFile != null) {
      record["nameFile"] = config.nameFile;
    }

    if (config.cropRegion) {
      let cropRegionRecord: Record<string, any> = {};
      cropRegionRecord["left"] = config.cropRegion.left;
      cropRegionRecord["top"] = config.cropRegion.top;
      cropRegionRecord["width"] = config.cropRegion.width;
      cropRegionRecord["height"] = config.cropRegion.height;
      record["cropRegion"] = cropRegionRecord;
    }
    return plugin.call(frame, record) as any;
  } else {
    return plugin.call(frame) as any;
  }
}

export function cropImage(path: string, config: CropImageConfig) {
  if (config) {
    let record: Record<string, any> = {};
    record["width"] = config.width ?? 0
    record["height"] = config.height ?? 0
    record["top"] = config.top ?? 0
    record["left"] = config.left ?? 0
    record["quality"] = config.quality ?? 100
    record["nameFile"] = config.nameFile ?? "cropImage"
    record["maxWidth"] = config.maxWidth ?? 0
    record["maxHeight"] = config.maxHeight ?? 0

    return VisionCameraCropper.cropImage(path, record) as any;
  } else {
    return new Error("miss config")
  }
}


export const resizeImage = (path: string, options: {maxSizeInMB: number, quality: number, fileName?: string}) => {
  const _options = {
    maxSizeInMB: options?.maxSizeInMB ?? 5,
    quality: options?.quality ?? 0.9,
    fileName: options?.fileName ?? '',
  };

  return new Promise(async (resolve: (data: ResizeResult) => void, reject) => {
    try {
      const response = await VisionCameraCropper.resizeImage(path?.replace("file://", ''), {..._options})
      resolve(response as ResizeResult);
      return;
    } catch (e) {
      reject(e);
    }
  });
};

export const clearCache = () => {
  try {
    VisionCameraCropper.clearCache()
  } catch { }
};



//the value is in percentage
export interface CropRegion {
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface CropConfig {
  cropRegion?: CropRegion;
  includeImageBase64?: boolean;
  saveAsFile?: boolean;
  nameFile?: string;
  maxWidth?: number;
  maxHeight?: number;
}
export interface CropImageConfig {
  width: number;
  height: number;
  top: number;
  left: number;
  quality: number;
  nameFile: string;
  maxWidth?: number;
  maxHeight?: number;
}


export interface CropResult {
  base64?: string;
  path?: string;
}

export interface ResizeResult {
  path: string;
  width: number;
  height: number;
  size: number;
}