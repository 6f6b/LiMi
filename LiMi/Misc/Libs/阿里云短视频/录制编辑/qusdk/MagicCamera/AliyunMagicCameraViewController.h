//
//  ViewController.h
//  AliyunVideo
//
//  Created by Vienta on 2016/12/29.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunMagicCameraViewController : UIViewController

@property (nonatomic, assign) BOOL beauty;
@property (nonatomic, assign) BOOL faceTrack;

- (void)setVideoSize:(CGSize)size;

@end

