import { NativeModules } from 'react-native';

const OpenTokPublisherViewManager = NativeModules.OpenTokPublisherViewManager;

export default {
	CameraCaptureResolution: OpenTokPublisherViewManager.CameraCaptureResolution,
	CameraCaptureFrameRate: OpenTokPublisherViewManager.CameraCaptureFrameRate
}
