//
//  AliyunCoverPickViewController.h
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunCoverPickViewController : UIViewController
@property (nonatomic, assign) CGSize outputSize;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) void(^finishHandler)(UIImage *image);
@end
