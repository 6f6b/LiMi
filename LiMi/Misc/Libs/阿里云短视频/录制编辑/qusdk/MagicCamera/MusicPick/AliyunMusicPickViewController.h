//
//  AliyunMusicPickViewController.h
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMusicPickModel.h"

@class AliyunMusicPickModel;
@protocol AliyunMusicPickViewControllerDelegate <NSObject>

- (void)didCancelPick;
- (void)didSelectMusic:(AliyunMusicPickModel *)music;

@end

@interface AliyunMusicPickViewController : UIViewController
@property (nonatomic, weak) id<AliyunMusicPickViewControllerDelegate> delegate;
@property (nonatomic, assign) CGFloat duration;
@end
