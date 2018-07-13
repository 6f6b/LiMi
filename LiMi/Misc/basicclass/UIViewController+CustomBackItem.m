//
//  UIViewController+CustomBackItem.m
//  LiMi
//
//  Created by dev.liufeng on 2018/7/9.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "UIViewController+CustomBackItem.h"
#import <RTRootNavigationController/RTRootNavigationController.h>

@implementation UIViewController (CustomBackItem)
- (UIBarButtonItem *)rt_customBackItemWithTarget:(id)target action:(SEL)action{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [backButton setImage:[UIImage imageNamed:@"short_video_back"] forState:UIControlStateNormal];
    [backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backItem;
}
@end
