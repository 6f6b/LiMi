//
//  AliyunVideo
//
//  Created by dangshuai on 17/1/14.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"
@class AVAsset;
@protocol AliyunCutThumbnailViewDelegate <NSObject>

- (void)cutBarDidMovedToTime:(CGFloat)time;

- (void)cutBarTouchesDidEnd;
@end

@interface AliyunCropThumbnailView : UIView

@property (nonatomic, weak) id<AliyunCutThumbnailViewDelegate> delegate;

@property (nonatomic, strong) AVAsset *avAsset;

- (instancetype)initWithFrame:(CGRect)frame withCutInfo:(AliyunMediaConfig *)cutInfo;

- (void)loadThumbnailData;

- (void)updateProgressViewWithProgress:(CGFloat)progress;
@end
