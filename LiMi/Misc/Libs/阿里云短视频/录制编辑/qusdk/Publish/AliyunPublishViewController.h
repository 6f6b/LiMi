//
//  AliyunPublishViewController.h
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"

@interface AliyunPublishViewController : UIViewController
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) NSString *taskPath;
@property (nonatomic, strong) AliyunMediaConfig *config;
@property (nonatomic, assign) CGSize outputSize;
@end
