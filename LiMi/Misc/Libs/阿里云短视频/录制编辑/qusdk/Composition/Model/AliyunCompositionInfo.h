//
//  AliyunCompositionInfo.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>

typedef enum : NSUInteger {
    AliyunCompositionInfoTypeVideo,
    AliyunCompositionInfoTypePhoto
} AliyunCompositionInfoType;

@interface AliyunCompositionInfo : NSObject
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, copy) NSString *sourcePath;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) PHAsset *phAsset;
@property (nonatomic, strong) UIImage *phImage;
@property (nonatomic, assign) AliyunCompositionInfoType type;
@property (nonatomic, assign) BOOL isFromCrop;

@end
