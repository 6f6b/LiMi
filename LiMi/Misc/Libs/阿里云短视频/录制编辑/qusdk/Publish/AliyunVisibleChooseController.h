//
//  AliyunVisibleChooseController.h
//  LiMi
//
//  Created by dev.liufeng on 2018/5/27.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, VisibleChooseType) {
    VisibleChooseTypeAll,//默认从0开始
    VisibleChooseTypeFollowers,
    VisibleChooseTypeOnlySelf
};

@interface AliyunVisibleChooseController : UIViewController
@property (nonatomic,assign) VisibleChooseType visibleType;
@property (nonatomic,strong) void(^chooseTypeBlock)(VisibleChooseType);
@end
