//
//  AliyunEffectPrestoreManager.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/21.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliyunEffectPrestoreManager : NSObject

/**
 添加原始数据
 
 如滤镜、MV的原片等
 */

- (void)insertInitialData;


/**
 删除原始数据的沙盒拷贝

 @param type 类型
 */
- (void)removeInitialDataWithType:(NSInteger)type;

@end
