//
//  AliyunDownloadCycleView.h
//  AliyunVideo
//
//  Created by TripleL on 17/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunDownloadCycleView : UIView

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat percentage;
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, strong) UIColor *progressBackgroundColor;

@end
