//
//  RCTOpenTokNetworkTest.m
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import "RCTOpenTokNetworkTest.h"
#import "OTNetworkTest.h"

@implementation RCTOpenTokNetworkTest

#pragma mark - Private Vars

OTNetworkTest *_networkTest;
RCTPromiseResolveBlock _resolveNetworkTest;
RCTPromiseRejectBlock _rejectNetworkTest;


#pragma mark - JavaScript Exports

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(testConnection:(NSString *)apiKey
                    sessionId:(NSString *)sessionId
                        token:(NSString *)token
                     duration:(int)duration
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject)
{
    _resolveNetworkTest = resolve;
    _rejectNetworkTest = reject;
    
  [self runNetworkTest:apiKey sessionId:sessionId token:token duration:duration];
}



#pragma mark - OpenTok Network Test

- (void)runNetworkTest:(NSString *)apiKey
             sessionId:(NSString *)sessionId
                 token:(NSString *)token
              duration:(int)duration
{
    _networkTest = [[OTNetworkTest alloc] init];
  
    [_networkTest runConnectivityTestWithApiKey:apiKey
                                      sessionId:sessionId
                                          token:token
                             executeQualityTest:YES
                            qualityTestDuration:duration
                                       delegate:self];
}


#pragma mark - OTNetworkTestDelegate Methods

- (void)networkTestDidCompleteWithResult:(enum OTNetworkTestResult)result
                                   error:(OTError *)error
{
    NSString *resultMessage = nil;
  
    if(result == OTNetworkTestResultVideoAndVoice) {
        resultMessage = @"PASS";
        _resolveNetworkTest(resultMessage);
    }
    else if(result == OTNetworkTestResultVoiceOnly) {
        resultMessage = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
        _rejectNetworkTest(@"FAIL", resultMessage, error);
    }
    else {
        resultMessage = [NSString stringWithFormat:@"Error %@", error.localizedDescription];
        _rejectNetworkTest(@"FAIL", resultMessage, error);
    }
  
    resultMessage = nil;
    _networkTest = nil;
    _resolveNetworkTest = nil;
    _rejectNetworkTest = nil;
}


#pragma mark - Network Test Queue

// Dispatch all these methods on a separate queue
- (dispatch_queue_t)methodQueue
{
  return dispatch_queue_create("com.commercialtribe.OpenTok.NetworkTest", DISPATCH_QUEUE_SERIAL);
}

@end