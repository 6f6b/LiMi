//
//  ShotCountDownView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/18.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShotCountDownView : UIView
    - (void)showWith:(int)time;
    @property (nonatomic,strong) void(^completeBlock)(void);

@end
