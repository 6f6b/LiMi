//
//  AliyunEditZoneView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/8.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunPasterView.h"

@protocol AliyunEditZoneViewDelegate <NSObject>

- (void)currentTouchPoint:(CGPoint)point;
- (void)mv:(CGPoint)fp to:(CGPoint)tp;
- (void)touchEnd;

@end

@interface AliyunEditZoneView : UIView

@property (nonatomic, weak) id<AliyunEditZoneViewDelegate> delegate;

@property (nonatomic, weak) AliyunPasterView *currentPasterView;

@end
