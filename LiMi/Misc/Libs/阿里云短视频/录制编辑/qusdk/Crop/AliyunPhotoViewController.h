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

- (void)cropFinished:(UIViewController *)cropViewController videoPath:(NSString *)videoPath sourcePath:(NSString *)sourcePath;

/**
 裁剪完成回调，裁剪对象有两种：视频或者图片

 @param cropViewController 裁剪viewController
 @param type 媒体类型
 @param photo 如果媒体类型是图像，则返回裁剪出来的图像，否则返回nil
 @param videoPath 如果媒体类型是视频，则返回裁剪出来的视频路径，否则返回nil
 */
- (void)cropFinished:(UIViewController *)cropViewController mediaType:(kPhotoMediaType)type photo:(UIImage *)photo videoPath:(NSString *)videoPath;

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
