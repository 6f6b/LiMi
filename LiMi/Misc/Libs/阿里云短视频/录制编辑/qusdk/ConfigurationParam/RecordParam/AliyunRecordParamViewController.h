//
//  QURecordParamViewController.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunMediaConfig;

@protocol AliyunRecordParamViewControllerDelegate <NSObject>

- (void)toRecordViewControllerWithMediaConfig:(id)config;

@end


@interface AliyunRecordParamViewController : UIViewController

@property (nonatomic, weak) id<AliyunRecordParamViewControllerDelegate> delegate;

@end
