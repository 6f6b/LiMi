//
//  QURecordFoucesView.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/10.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunRecordFocusView : UIView

@property (nonatomic, assign) BOOL autoFocus;

- (void)refreshPosition;
- (void)changeExposureValue:(CGFloat)value;
@end



@interface AliyunLightProgress : UIView

@property (nonatomic, assign) CGFloat progress;

@end
