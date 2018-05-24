//
//  QUProgressView.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QUProgressView : UIView

@property (nonatomic, assign) NSInteger videoCount;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) BOOL showBlink;
@property (nonatomic, assign) BOOL showNoticePoint;
@property (nonatomic, assign) CGFloat minDuration;
@property (nonatomic, assign) CGFloat maxDuration;
@property (nonatomic, strong) NSMutableArray *pointArray;

@property (nonatomic, strong) UIColor *colorProgress;
@property (nonatomic, strong) UIColor *colorSelect;
@property (nonatomic, strong) UIColor *colorNotice;
@property (nonatomic, strong) UIColor *colorSepatorPoint;

- (void)updateProgress:(CGFloat)progress;

-(void)reset;

@end
