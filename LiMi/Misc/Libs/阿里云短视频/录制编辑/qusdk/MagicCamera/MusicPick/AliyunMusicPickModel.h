//
//  AliyunMusicPickModel.h
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AliyunMusicPickModel : NSObject
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) BOOL expand;
@end
