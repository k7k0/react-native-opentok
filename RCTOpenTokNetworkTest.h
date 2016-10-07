//
//  RCTOpenTokNetworkTest.m
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//
#import "OTNetworkTest.h"
#import "RCTBridgeModule.h"

@interface RCTOpenTokNetworkTest : NSObject <OTNetworkTestDelegate, RCTBridgeModule>

@property (nonatomic, strong) RCTPromiseResolveBlock resolveNetworkTest;
@property (nonatomic, strong) RCTPromiseRejectBlock rejectNetworkTest;

- (void)runNetworkTest:(NSString *)apiKey
             sessionId:(NSString *)sessionId
                 token:(NSString *)token
              duration:(int)duration;

- (void)networkTestDidCompleteWithResult:(enum OTNetworkTestResult)result
                                   error:(OTError*)error;

@end