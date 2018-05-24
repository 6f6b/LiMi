//
//  AddAnimationFilterController.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/23.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMediaConfig.h"
#import <AliyunVideoSDKPro/AliyunEditor.h>

@interface AddAnimationFilterController : UIViewController
@property (nonatomic, strong) NSString *taskPath;
@property (nonatomic, strong) AliyunMediaConfig *config;
@property (nonatomic, strong) AliyunEditor *editor;
@property (weak, nonatomic)  UIView *movieView;

@end
