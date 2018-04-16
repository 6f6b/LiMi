//
//  NTESDemoConfig.m
//  NIM
//
//  Created by amao on 4/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "NTESConfig.h"

@interface NTESConfig ()

@end

@implementation NTESConfig
+ (instancetype)sharedConfig
{
    static NTESConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESConfig alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _appKey = @"525f6f12511728fc7805594e96587546";
        _apiURL = @"https://app.netease.im/api";
        
        #ifdef DEBUG
                _apnsCername = @"apsdevelopmentp12N";
                _pkCername = @"VoIPdevelopment";
        #else
                _apnsCername = @"apsp12N";
                _pkCername = @"VoIPproduct";
        #endif
        
        _redPacketConfig = [[NTESRedPacketConfig alloc] init];
    }
    return self;
}

- (NSString *)apiURL
{
    NSAssert([[NIMSDK sharedSDK] isUsingDemoAppKey], @"只有 demo appKey 才能够使用这个API接口");
    return _apiURL;
}

- (void)registerConfig:(NSDictionary *)config
{
    if (config[@"red_packet_online"])
    {
        _redPacketConfig.useOnlineEnv = [config[@"red_packet_online"] boolValue];
    }
}


@end



@implementation NTESRedPacketConfig

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _useOnlineEnv = YES;
        _aliPaySchemeUrl = @"alipay052969";
        _weChatSchemeUrl = @"wx2a5538052969956e";
    }
    return self;
}

@end

