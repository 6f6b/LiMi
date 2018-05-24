//
//  QUConfigureViewController.h
//  AliyunVideo
//
//  Created by dangshuai on 17/1/12.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunMediaConfig;

@protocol AliyunConfigureViewControllerDelegate <NSObject>

- (void)configureDidFinishWithMedia:(AliyunMediaConfig *)mediaConfig;

@end

@interface AliyunConfigureViewController : UIViewController

@property (nonatomic, weak) id<AliyunConfigureViewControllerDelegate> delegate;

@end

