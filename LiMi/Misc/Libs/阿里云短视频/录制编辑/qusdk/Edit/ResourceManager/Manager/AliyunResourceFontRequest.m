//
//  AliyunResourceFontRequest.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunResourceFontRequest.h"
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
#import "AliyunEffectResourceModel.h"


@implementation AliyunResourceFontRequest

+ (void)requestWithFontId:(NSInteger)fontId
                  success:(void(^)(AliyunEffectResourceModel *))success
                  failure:(void(^)(NSError *error))failure {
    
    AliyunHttpClient *client = [[AliyunHttpClient alloc] initWithBaseUrl:kQPResourceHostUrl];
    NSString *url = [NSString stringWithFormat:@"api/res/get/1/%ld", fontId];
    NSDictionary *param = @{@"type":@(1),
                            @"id":@(fontId),
                            @"bundleId":BundleID};
    [client GET:url parameters:param completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if (error) {
            if (failure) {
                failure(error);
            }
        } else {
            if ([responseObject isKindOfClass:[NSArray class]] && [responseObject count] == 0) {
                
                NSError *error = [NSError errorWithDomain:@"Data Empty Error" code:-10001 userInfo:nil];
                if (failure) {
                    failure(error);
                }
                return ;
            }
            
            AliyunEffectResourceModel *model = [[AliyunEffectResourceModel alloc] initWithDictionary:responseObject error:nil];
            [model setValue:@(1) forKey:@"effectType"];
            if (success) {
                success(model);
            }
        }
        
    }];

}

@end
