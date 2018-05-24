//
//  AliyunEffectMusicCell.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/15.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectMusicInfo.h"

@class AliyunEffectMusicCell;
@protocol AliyunEffectMusicCellDelegate <NSObject>

- (void)musicCell:(AliyunEffectMusicCell *)cell willDown:(AliyunEffectMusicInfo *)musicInfo;

@end

@interface AliyunEffectMusicCell : UITableViewCell

@property (nonatomic, weak) id<AliyunEffectMusicCellDelegate> delegate;
@property (nonatomic, strong) AliyunEffectMusicInfo *musicInfo;


// 更新下载进度
- (void)updateProgress:(CGFloat)progress;
// 下载失败
- (void)updateDownloadFaliure;


@end
