//
//  TNLRequestConfigurationTest.m
//  TwitterNetworkLayer
//
//  Created on 11/11/14.
//  Copyright (c) 2014 Twitter. All rights reserved.
//

#import "NSHTTPCookieStorage+TNLAdditions.h"
#import "NSURLCache+TNLAdditions.h"
#import "NSURLCredentialStorage+TNLAdditions.h"
#import "NSURLSessionConfiguration+TNLAdditions.h"
#import "TNL_Project.h"
#import "TNLGlobalConfiguration.h"
#import "TNLRequestConfiguration_Project.h"

@import XCTest;

@interface TNLRequestConfigurationTest : XCTestCase

@end

@implementation TNLRequestConfigurationTest

- (void)runTestParamsEqualBetweenOriginal:(TNLParameterCollection *)originalParams roundTrip:(TNLParameterCollection *)roundTripParams
{
    for (NSString *key in originalParams) {
        id<NSObject> val1 = originalParams[key];
        NSString *val2 = roundTripParams[key];

        if ([val1 isKindOfClass:[NSNumber class]]) {
            XCTAssertEqual([(NSNumber *)val1 doubleValue], [val2 doubleValue]);
        } else {
            XCTAssertEqualObjects(val1, val2);
        }
    }
}

- (void)testConfigRoundTrips
{
    TNLMutableRequestConfiguration *config = [TNLMutableRequestConfiguration defaultConfiguration];
    TNLMutableParameterCollection *params;
    TNLParameterCollection *roundTripParams;
    TNLMutableRequestConfiguration *roundTripConfig;
    NSString *paramString;
    NSString *testParamString;

    params = TNLMutableParametersFromRequestConfiguration(config, nil, nil, nil);
    params[@"double"] = @(3.14159265359);
    paramString = params.stableURLEncodedStringValue;
    roundTripParams = [[TNLParameterCollection alloc] initWithURLEncodedString:paramString options:0];
    roundTripConfig = (id)[TNLRequestConfiguration configurationFromParameters:params executionMode:config.executionMode version:[TNLGlobalConfiguration version]];

#if TARGET_OS_IOS
    testParamString = @"aca=1&atmpTO=60&ckiplcy=1&cnvty=0&dfrI=0&dis=0&double=3.14159265359&idlTO=30&nst=0&opTO=180&ptcls=0&rcp=0&rdcm=1&rdp=1&setcki=0&ssle=1";
#else
    testParamString = @"aca=1&atmpTO=60&ckiplcy=1&cnvty=0&dfrI=0&dis=0&double=3.14159265359&idlTO=30&nst=0&opTO=180&ptcls=0&rcp=0&rdcm=1&rdp=1&setcki=0&ssle=0";
#endif

    XCTAssertEqualObjects(paramString, testParamString);
    XCTAssertEqual(params.count, roundTripParams.count);
    [self runTestParamsEqualBetweenOriginal:params roundTrip:roundTripParams];
    XCTAssertEqualObjects(roundTripConfig, config);

    if (tnl_available_multipath_service_type) {
        config.multipathServiceType = NSURLSessionMultipathServiceTypeInteractive;
#if TARGET_OS_IOS
        testParamString = @"aca=1&atmpTO=60&ckiplcy=1&cnvty=0&dfrI=0&dis=0&idlTO=30&mptcp=2&nst=0&opTO=180&ptcls=0&rcp=0&rdcm=1&rdp=1&setcki=0&ssle=1";
#else
        testParamString = @"aca=1&atmpTO=60&ckiplcy=1&cnvty=0&dfrI=0&dis=0&idlTO=30&mptcp=2&nst=0&opTO=180&ptcls=0&rcp=0&rdcm=1&rdp=1&setcki=0&ssle=0";
#endif
        params = TNLMutableParametersFromRequestConfiguration(config, nil, nil, nil);
        paramString = params.stableURLEncodedStringValue;
        roundTripParams = [[TNLParameterCollection alloc] initWithURLEncodedString:paramString options:0];
        roundTripConfig = (id)[TNLRequestConfiguration configurationFromParameters:params executionMode:config.executionMode version:[TNLGlobalConfiguration version]];

        XCTAssertEqualObjects(paramString, testParamString);
        XCTAssertEqual(params.count, roundTripParams.count);
        [self runTestParamsEqualBetweenOriginal:params roundTrip:roundTripParams];
        XCTAssertEqualObjects(roundTripConfig, config);
        config.multipathServiceType = 0;
    }

    config.contributeToExecutingNetworkConnectionsCount = NO;
    config.executionMode = TNLRequestExecutionModeBackground;
    config.redirectPolicy = TNLRequestRedirectPolicyDontRedirect;
    config.responseDataConsumptionMode = TNLResponseDataConsumptionModeSaveToDisk;
    config.protocolOptions = TNLRequestProtocolOptionPseudo;
    config.connectivityOptions = TNLRequestConnectivityOptionWaitForConnectivity | TNLRequestConnectivityOptionInvalidateAttemptTimeoutWhenWaitForConnectivityTriggered;
    config.idleTimeout = 180.1;
    config.attemptTimeout = 360.1;
    config.operationTimeout = 720.1;
    config.deferrableInterval = 30.1;
    config.cachePolicy = NSURLCacheStorageAllowedInMemoryOnly;
    config.networkServiceType = NSURLNetworkServiceTypeBackground;
    config.allowsCellularAccess = NO;
    config.discretionary = YES;
    config.sharedContainerIdentifier = @"container.id";
    config.shouldLaunchAppForBackgroundEvents = NO;
    config.shouldSetCookies = NO;
    config.cookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;

    XCTAssertNotNil(config.sharedContainerIdentifier);
    XCTAssertEqualObjects(config, [config copy]);

    params = TNLMutableParametersFromRequestConfiguration(config, nil, nil, nil);
    paramString = params.stableURLEncodedStringValue;
    roundTripParams = [[TNLParameterCollection alloc] initWithURLEncodedString:paramString options:0];
    roundTripConfig = (id)[TNLRequestConfiguration configurationFromParameters:params executionMode:config.executionMode version:[TNLGlobalConfiguration version]];
    XCTAssertNotEqual(roundTripConfig.contributeToExecutingNetworkConnectionsCount, config.contributeToExecutingNetworkConnectionsCount);
    roundTripConfig.contributeToExecutingNetworkConnectionsCount = config.contributeToExecutingNetworkConnectionsCount;

    testParamString = [NSString stringWithFormat:@"aca=0&atmpTO=360.1&ckiplcy=1&cnvty=5&dfrI=30.1&dis=1&idlTO=180.1&nst=3&opTO=720.1&ptcls=2&rcp=1&rdcm=2&rdp=0&%@setcki=0&ssle=0", config.sharedContainerIdentifier ? @"scid=container.id&" : @""];
    XCTAssertEqualObjects(paramString, testParamString);
    [self runTestParamsEqualBetweenOriginal:params roundTrip:roundTripParams];
    XCTAssertEqualObjects(roundTripConfig, config);

    // Re-test with shared URL cache and credential storage

    config.URLCache = [NSURLCache sharedURLCache];
    config.URLCredentialStorage = [NSURLCredentialStorage sharedCredentialStorage];
    config.cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    params = TNLMutableParametersFromRequestConfiguration(config, nil, nil, nil);
    paramString = params.stableURLEncodedStringValue;
    roundTripParams = [[TNLParameterCollection alloc] initWithURLEncodedString:paramString];
    roundTripConfig = (id)[TNLRequestConfiguration configurationFromParameters:params executionMode:config.executionMode version:[TNLGlobalConfiguration version]];
    XCTAssertNotEqual(roundTripConfig.contributeToExecutingNetworkConnectionsCount, config.contributeToExecutingNetworkConnectionsCount);
    XCTAssertNil(roundTripConfig.URLCache);
    XCTAssertNil(roundTripConfig.URLCredentialStorage);
    roundTripConfig.contributeToExecutingNetworkConnectionsCount = config.contributeToExecutingNetworkConnectionsCount;
    roundTripConfig.URLCredentialStorage = config.URLCredentialStorage;
    roundTripConfig.URLCache = config.URLCache;
    roundTripConfig.cookieStorage = config.cookieStorage;
    testParamString = [NSString stringWithFormat:@"aca=0&atmpTO=360.1&ckiplcy=1&ckisto=NSHTTPCookieStorage_%p&cnvty=5&crdsto=NSURLCredentialStorage_%p&dfrI=30.1&dis=1&idlTO=180.1&nst=3&opTO=720.1&ptcls=2&rcp=1&rdcm=2&rdp=0&%@setcki=0&ssle=0&urlcch=NSURLCache_%p", config.cookieStorage, config.URLCredentialStorage, config.sharedContainerIdentifier ? @"scid=container.id&" : @"", config.URLCache];
    XCTAssertEqualObjects(paramString, testParamString);
    [self runTestParamsEqualBetweenOriginal:params roundTrip:roundTripParams];
    XCTAssertEqualObjects(roundTripConfig, config);

    // Re-test with proxies to shared URL cache and credential storage

    config.URLCache = [NSURLCache tnl_sharedURLCacheProxy];
    config.URLCredentialStorage = [NSURLCredentialStorage tnl_sharedCredentialStorageProxy];
    config.cookieStorage = [NSHTTPCookieStorage tnl_sharedHTTPCookieStorageProxy];
    params = TNLMutableParametersFromRequestConfiguration(config, nil, nil, nil);
    paramString = params.stableURLEncodedStringValue;
    roundTripParams = [[TNLParameterCollection alloc] initWithURLEncodedString:paramString options:0];
    roundTripConfig = (id)[TNLRequestConfiguration configurationFromParameters:params executionMode:config.executionMode version:[TNLGlobalConfiguration version]];
    XCTAssertNotEqual(roundTripConfig.contributeToExecutingNetworkConnectionsCount, config.contributeToExecutingNetworkConnectionsCount);
    XCTAssertNil(roundTripConfig.URLCache);
    XCTAssertNil(roundTripConfig.URLCredentialStorage);
    roundTripConfig.contributeToExecutingNetworkConnectionsCount = config.contributeToExecutingNetworkConnectionsCount;
    roundTripConfig.URLCredentialStorage = config.URLCredentialStorage;
    roundTripConfig.URLCache = config.URLCache;
    roundTripConfig.cookieStorage = config.cookieStorage;
    testParamString = [NSString stringWithFormat:@"aca=0&atmpTO=360.1&ckiplcy=1&ckisto=NSHTTPCookieStorage_%p&cnvty=5&crdsto=NSURLCredentialStorage_%p&dfrI=30.1&dis=1&idlTO=180.1&nst=3&opTO=720.1&ptcls=2&rcp=1&rdcm=2&rdp=0&%@setcki=0&ssle=0&urlcch=NSURLCache_%p", config.cookieStorage, config.URLCredentialStorage, config.sharedContainerIdentifier ? @"scid=container.id&" : @"", config.URLCache];
    XCTAssertNotEqualObjects(paramString, testParamString);
    testParamString = [NSString stringWithFormat:@"aca=0&atmpTO=360.1&ckiplcy=1&ckisto=NSHTTPCookieStorage_%p&cnvty=5&crdsto=NSURLCredentialStorage_%p&dfrI=30.1&dis=1&idlTO=180.1&nst=3&opTO=720.1&ptcls=2&rcp=1&rdcm=2&rdp=0&%@setcki=0&ssle=0&urlcch=NSURLCache_%p", TNLUnwrappedCookieStorage(config.cookieStorage), TNLUnwrappedURLCredentialStorage(config.URLCredentialStorage), config.sharedContainerIdentifier ? @"scid=container.id&" : @"", TNLUnwrappedURLCache(config.URLCache)];
    XCTAssertEqualObjects(paramString, testParamString);
    [self runTestParamsEqualBetweenOriginal:params roundTrip:roundTripParams];
    XCTAssertEqualObjects(roundTripConfig, config);
}

@end
