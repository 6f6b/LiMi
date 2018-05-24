//
//  AliyunCropViewController.h
//  AliyunVideo
//
//  Created by dangshuai on 17/1/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"

@protocol AliyunCropViewControllerDelegate;
@interface AliyunCropViewController : UIViewController

@property (nonatomic, strong) AliyunMediaConfig *cutInfo;
@property (nonatomic, weak) id<AliyunCropViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL fakeCrop; // 假裁剪，获取裁剪时间段，不真正裁剪视频
@end


@protocol AliyunCropViewControllerDelegate <NSObject>

- (void)cropViewControllerExit;

- (void)cropViewControllerFinish:(AliyunMediaConfig *)mediaInfo viewController:(UIViewController *)controller;


@end
