//
//  AliyunTimelineMediaInfo.h
//  qusdk_debug
//
//  Created by Vienta on 2017/6/28.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AliyunTimelineMediaInfoTypeVedio,
    AliyunTimelineMediaInfoTypePhoto
} AliyunTimelineMediaInfoType;

@interface AliyunTimelineMediaInfo : NSObject

@property (nonatomic, assign) AliyunTimelineMediaInfoType mediaType; //媒体类型 视频或者图片
@property (nonatomic, copy) NSString *path;     //媒体资源路径
@property (nonatomic, assign) CGFloat duration; //媒体持续时长
@property (nonatomic, assign) CGFloat startTime; //媒体持续时长
@property (nonatomic, assign) int rotate;//旋转角度

@end
