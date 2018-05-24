//
//  AliyunResourceFontDownload.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AliyunEffectResourceModel;

@interface AliyunResourceFontDownload : NSObject


- (void)downloadFontWithFontId:(NSInteger)fontId
                      progress:(void(^)(CGFloat progress))progress
                    completion:(void(^)(AliyunEffectResourceModel *newModel, NSError *error))completion;

@end
