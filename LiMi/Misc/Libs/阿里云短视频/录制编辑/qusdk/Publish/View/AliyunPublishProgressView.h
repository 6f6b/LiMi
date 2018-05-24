//
//  AliyunPublishProgressView.h
//  qusdk
//
//  Created by Worthy on 2017/11/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunPublishProgressView : UIView
- (void)setProgress:(CGFloat)progress;
- (void)markAsFinihed;
- (void)markAsFailed;
@end
