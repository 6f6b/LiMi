//
//  AliyunCustomFilter.h
//  qusdk
//
//  Created by Worthy on 2017/8/10.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliyunCustomFilter : NSObject
- (instancetype)initWithSize:(CGSize)size;
- (int)render:(int)srcTexture size:(CGSize)size;
@end
