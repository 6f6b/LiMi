//
//  AliyunPhotoViewController.h
//  AliyunVideo
//
//  Created by dangshuai on 17/1/11.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class AliyunMediaConfig;
#import "AliyunMediaConfig.h"



@protocol AliyunPhotoViewControllerDelegate <NSObject>

- (void)recodBtnClick:(UIViewController *)vc;

- (void)backBtnClick:(UIViewController *)vc;

@end

@interface AliyunPhotoViewController : UIViewController

@property (nonatomic, assign) BOOL cutMode;
@property (nonatomic, assign) CGSize destSize;
@property (nonatomic, assign) int videoQuality;
@property (nonatomic, assign) int fps;
@property (nonatomic, assign) int gop;
@property (nonatomic, strong) AliyunMediaConfig *cutInfo;

@property (nonatomic, weak) id<AliyunPhotoViewControllerDelegate> delegate;
@end
