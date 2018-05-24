//
//  AliyunImage.m
//
//  Created by TripleL on 17/5/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunImage.h"

@implementation AliyunImage

+ (UIImage *)imageNamed:(NSString *)name {
    
    NSString *fullName = [[AliyunIConfig config] imageName:name];
    
    return [UIImage imageNamed:fullName];
}

@end
