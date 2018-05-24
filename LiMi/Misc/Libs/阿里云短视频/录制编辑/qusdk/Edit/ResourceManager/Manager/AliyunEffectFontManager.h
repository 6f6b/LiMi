//
//  AliyunEffectFontManager.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliyunEffectFontManager : NSObject

+ (instancetype)manager;


/**
 注册字体

 @param fontPath 字体路径
 @return 字体名
 */
- (NSString *)registerFontWithFontPath:(NSString *)fontPath;

@end
