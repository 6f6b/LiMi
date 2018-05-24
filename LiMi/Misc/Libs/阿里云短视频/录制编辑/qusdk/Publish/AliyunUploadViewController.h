//
//  AliyunUploadViewController.h
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunUploadViewController : UIViewController
@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, copy) NSString *coverImagePath;
@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, copy) NSString *desc;
@end
