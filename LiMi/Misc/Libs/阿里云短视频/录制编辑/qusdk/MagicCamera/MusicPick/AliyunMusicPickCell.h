//
//  AliyunMusicPickCell.h
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMusicLineView.h"

@protocol AliyunMusicPickCellDelegate <NSObject>

- (void)didSelectStartTime:(CGFloat)startTime;

@end

@interface AliyunMusicPickCell : UITableViewCell
@property (nonatomic, weak) id<AliyunMusicPickCellDelegate> delegate;
@property (nonatomic, strong) AliyunMusicLineView *lineView;
@property (nonatomic, strong) UIScrollView *scrollView;
-(void)configureMusicDuration:(CGFloat)musicDuration pageDuration:(CGFloat)pageDuration;
@end
