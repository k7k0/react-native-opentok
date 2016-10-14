/**
 * Copyright (c) 2015-present, Callstack Sp z o.o.
 * All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "RCTOpenTokPublisherViewManager.h"
#import "RCTOpenTokPublisherView.h"
#import "RCTComponent.h"
#import <OpenTok/OpenTok.h>

@implementation RCTOpenTokPublisherViewManager {
    RCTOpenTokPublisherView *_recorderView;
}

- (UIView *)view
{
    // Alloc UI element
    if (_recorderView == nil) {
        _recorderView =  [RCTOpenTokPublisherView new];
    }
    return _recorderView;
}

- (NSDictionary *)constantsToExport
{
    return @{
             @"CameraCaptureResolution": @{
                     @"Low": @(OTCameraCaptureResolutionLow),
                     @"Medium": @(OTCameraCaptureResolutionMedium),
                     @"High": @(OTCameraCaptureResolutionHigh)
                     },
             @"CameraCaptureFrameRate": @{
                     @"FR30FPS": @(OTCameraCaptureFrameRate30FPS),
                     @"FR15FPS": @(OTCameraCaptureFrameRate15FPS),
                     @"FR7FPS": @(OTCameraCaptureFrameRate7FPS),
                     @"FR1FPS": @(OTCameraCaptureFrameRate1FPS),
                },
             };
}

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(apiKey, NSString)
RCT_EXPORT_VIEW_PROPERTY(sessionId, NSString)
RCT_EXPORT_VIEW_PROPERTY(token, NSString)
RCT_EXPORT_VIEW_PROPERTY(cameraResolution, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(cameraFrameRate, NSInteger)

RCT_EXPORT_VIEW_PROPERTY(onPublishStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPublishError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPublishStop, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onClientConnected, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onClientDisconnected, RCTDirectEventBlock)

RCT_EXPORT_VIEW_PROPERTY(onSessionDidConnect, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onSessionDidDisconnect, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onArchiveStarted, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onArchiveStopped, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onThumbnailReady, RCTDirectEventBlock)


RCT_EXPORT_METHOD(resumePublish)
{
    [_recorderView resumePublish];
}
RCT_EXPORT_METHOD(pausePublish)
{
    [_recorderView pausePublish];
}

@end
