/**
 * Copyright (c) 2015-present, Callstack Sp z o.o.
 * All rights reserved.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

@import UIKit;
#import "RCTOpenTokPublisherView.h"
#import "OTKBasicVideoCapturer.h"
#import "RCTEventDispatcher.h"
#import "RCTUtils.h"
#import <OpenTok/OpenTok.h>

@interface RCTOpenTokPublisherView () <OTSessionDelegate, OTPublisherDelegate>

@end

@implementation RCTOpenTokPublisherView {
    OTSession *_session;
    OTPublisher *_publisher;
    BOOL _isSessionCreated;
    BOOL _isPaused;
    BOOL _isPublished;
}

/**
 * Create session after all props were passed
 */
- (void)didMoveToWindow {
    [super didMoveToSuperview];
    if (!_isSessionCreated) {
      [self createSession];
    }
}


/**
 * Creates a new session with a given apiKey, sessionID and token
 *
 * Calls `onStartFailure` in case an error happens during initial creation.
 *
 * Otherwise, `onSessionCreated` callback is called asynchronously
 */
- (void) createSession {
    _isPaused = NO;
    _session = [[OTSession alloc] initWithApiKey:_apiKey sessionId:_sessionId delegate:self];

    OTError *error = nil;
    [_session connectWithToken:_token error:&error];

    if (error) {
        _onPublishError(RCTJSErrorFromNSError(error));
    } else {
      _isSessionCreated = YES;
    }
}

/**
 * Creates an instance of `OTPublisher` and publishes stream to the current
 * session
 *
 * Calls `onPublishError` in case of an error, otherwise, a camera preview is inserted
 * inside the mounted view
 */
- (void)startPublishing {
    _publisher = [[OTPublisher alloc] initWithDelegate:self
                                                  name: @"My Video"
                                      cameraResolution: _cameraResolution
                                       cameraFrameRate: _cameraFrameRate];

   _publisher.publishAudio = YES;
   _publisher.publishVideo = _videoEnabled;
   _publisher.audioFallbackEnabled = YES;

    OTError *error = nil;

    [_session publish:_publisher error:&error];

    if (error) {
        _onPublishError(RCTJSErrorFromNSError(error));
        return;
    }

    [self attachPublisherView];

    _publisher.videoCapture = [[OTKBasicVideoCapturer alloc]
                                  initWithPreset: [self getCapturePreset:_cameraResolution]
                                  andDesiredFrameRate:_cameraFrameRate];
}

- (NSString *) getCapturePreset:(NSInteger) resolution
{
  if (resolution == OTCameraCaptureResolutionLow) {
    return AVCaptureSessionPreset352x288;
  } else if (resolution == OTCameraCaptureResolutionMedium) {
    return AVCaptureSessionPreset640x480;
  } else if (resolution == OTCameraCaptureResolutionHigh) {
    return AVCaptureSessionPreset1280x720;
  }
  [NSException raise:@"Invalid camera resolution value" format:@" %ld is invalid", (long)resolution];
  return @"";
}

- (void)pausePublish{
    _isPaused = YES;
    OTError* error = nil;
    [_session unpublish:_publisher error:&error];
    if (error) {
        NSLog(@"pausePublish with error: (%@)", error);
    }
}
- (void)resumePublish{
    _isPaused = NO;
    // for web we could preserve the publisher, but it doesnt seem to work here.
    // So we need to recreate the publisher
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startPublishing];
    });
}

- (void)stopPublish{
    _isPaused = NO;
    if (_isPublished) {
        OTError* error = nil;
        [_session unpublish:_publisher error:&error];
        if (error) {
            NSLog(@"stopPublish failed with error: (%@)", error);
        }
    }
}


/**
 * Attaches publisher preview
 */
- (void)attachPublisherView {
    [_publisher.view setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _publisher.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self addSubview:_publisher.view];
}

/**
 * Cleans up publisher
 */
- (void)cleanupPublisher {
    if (! _isPaused) {
        [_publisher.view removeFromSuperview];
        _publisher = nil;
    }
}

- (void) saveThumbnail {
    [self screenShotImageWithView:_publisher.view];
}

- (UIView *) screenShotViewWithView:(UIView *)view
{
    return  [view snapshotViewAfterScreenUpdates:YES];
}

- (void) screenShotImageWithView :(UIView *) view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    
    UIImage *originalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *image = [[UIImage alloc] initWithCGImage: originalImage.CGImage
                                                        scale: originalImage.scale
                                                        orientation: UIImageOrientationUpMirrored];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"OpentokLastThumbnail.png"];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
    
    _onThumbnailReady(@{
                        @"filePath": filePath,
                        });
}



#pragma mark - OTSession delegate callbacks

/**
 * When session is created, we start publishing straight away
 */
- (void)sessionDidConnect:(OTSession*)session {
    _onSessionDidConnect(@{
         @"sessionId": session.sessionId,
    });
    [self startPublishing];
}

- (void)sessionDidDisconnect:(OTSession*)session {
    _onSessionDidDisconnect(@{
        @"sessionId": session.sessionId,
    });
}

/**
 * @todo multiple streams in a session are out of scope
 * for our use-cases. To be implemented later.
 */
- (void)session:(OTSession*)session streamCreated:(OTStream *)stream {}
- (void)session:(OTSession*)session streamDestroyed:(OTStream *)stream {}

/**
 * Called when another client connects to the session
 */
- (void)session:(OTSession *)session connectionCreated:(OTConnection *)connection {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];

  [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  NSString *creationTimeString = [dateFormatter stringFromDate:connection.creationTime];
    _onClientConnected(@{
        @"connectionId": connection.connectionId,
        @"creationTime": creationTimeString,
        @"data": connection.data,
    });
}

/**
 * Called when client disconnects from the session
 */
- (void)session:(OTSession *)session connectionDestroyed:(OTConnection *)connection {
    _onClientDisconnected(@{
        @"connectionId": connection.connectionId,
    });
}

- (void)session:(OTSession*)session didFailWithError:(OTError*)error {
    _onPublishError(RCTJSErrorFromNSError(error));
}

#pragma mark - OTSession delegate - archive callbacks
- (void)session:(OTSession *)session archiveStartedWithId:(NSString *)archiveId name:(NSString *)name {
    [self saveThumbnail];
    
    _onArchiveStarted(@{
        @"archiveId": archiveId,
        @"name": name,
   });
}

- (void)session:(OTSession *)session archiveStoppedWithId:(NSString *)archiveId {
    _onArchiveStopped(@{
        @"archiveId": archiveId,
    });
}

#pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit*)publisher streamCreated:(OTStream *)stream {
    _isPublished = YES;
    _onPublishStart(@{});
}

- (void)publisher:(OTPublisherKit*)publisher streamDestroyed:(OTStream *)stream {
    _isPublished = NO;
    _onPublishStop(@{});
    [self cleanupPublisher];
}

- (void)publisher:(OTPublisherKit*)publisher didFailWithError:(OTError*)error {
    _isPublished = NO;
    _onPublishError(RCTJSErrorFromNSError(error));
    [self cleanupPublisher];
}


- (void)removeFromSuperview {
  _isSessionCreated = NO;
  [self cleanupPublisher];
  [_session disconnect:nil];
  [super removeFromSuperview];
}

@end
