//
//  AliyunTimelineItem.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AliyunTimelineItem : NSObject

@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, assign) CGFloat endTime;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, weak) id obj;
@property (nonatomic, assign) CGFloat minDuration;

@end
