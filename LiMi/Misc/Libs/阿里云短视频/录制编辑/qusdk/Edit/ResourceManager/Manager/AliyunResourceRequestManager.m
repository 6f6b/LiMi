//
//  AliyunResourceRequestManager.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunResourceRequestManager.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>


@implementation AliyunResourceRequestManager

+ (void)requestWithEffectTypeTag:(NSInteger)typeTag
                         success:(void(^)(NSArray *resourceListArray))success
                         failure:(void(^)(NSError *error))failure {
    
    AliyunHttpClient *client = [[AliyunHttpClient alloc] initWithBaseUrl:kQPResourceHostUrl];
    NSString *url = [NSString stringWithFormat:@"api/res/type/%ld", (long)typeTag];
    NSDictionary *param = @{@"type":@(typeTag),
                            @"bundleId":BundleID};
    [client GET:url parameters:param completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
//        NSLog(@"%@",responseObject);
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if ( [responseObject isKindOfClass:[NSString class]] && [responseObject length] == 0) {
                NSError *error = [NSError errorWithDomain:@"Data Empty Error" code:-10001 userInfo:nil];
                if (failure) {
                    failure(error);
                }
                return ;
            }
            if ([responseObject isKindOfClass:[NSArray class]] && [responseObject count] == 0) {
                
                NSError *error = [NSError errorWithDomain:@"Data Empty Error" code:-10001 userInfo:nil];
                if (failure) {
                    failure(error);
                }
                return ;
            }
            
            if (success) {
                success((NSArray *)responseObject);
            }
        }
  
    }];
}

@end
