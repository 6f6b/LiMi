//
//  QUEditViewController.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"

@interface AliyunEditViewController : UIViewController
@property (nonatomic, strong) NSString *taskPath;
@property (nonatomic, strong) AliyunMediaConfig *config;
@property (nonatomic,assign) NSInteger musicId;
@property (nonatomic,assign) float startTime;
@property (nonatomic,assign) float duration;

@property (nonatomic,assign) int filterIndex;
@end
