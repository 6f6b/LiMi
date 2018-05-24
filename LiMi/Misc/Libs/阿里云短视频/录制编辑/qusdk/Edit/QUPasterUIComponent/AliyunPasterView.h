//
//  AliyunPasterView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunVideoSDKPro/AliyunPasterController.h>
#import <AliyunVideoSDKPro/AliyunPasterUIEventProtocol.h>
#import "AliyunColor.h"

@protocol AliyunPasterViewActionTarget <NSObject>

- (void)oneClick:(id)obj;

@end


@interface AliyunPasterView : UIView

@property (nonatomic, assign) BOOL editStatus;//是否为编辑状态
@property (nonatomic, assign) BOOL selectStatus;//是否为选中状态
@property (nonatomic, strong) AliyunColor *textColor;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *textFontName;
@property (nonatomic, weak) id<AliyunPasterUIEventProtocol> delegate;
@property (nonatomic, weak) id<AliyunPasterViewActionTarget> actionTarget;
@property (nonatomic, assign) CGSize nativeDisplaySize; //用native控件播放视频的容器大小
@property (nonatomic, assign) CGSize renderedMediaSize; //需要渲染到的视频分辨率

- (id)initWithPasterController:(AliyunPasterController *)pasterController;

- (BOOL)touchPoint:(CGPoint)point fromView:(UIView *)view;

- (void)touchMoveFromPoint:(CGPoint)fp to:(CGPoint)tp;

- (void)touchEnd;

- (UIImage *)textImage;

- (UIColor *)contentColor;

- (UIColor *)strokeColor;


@end
