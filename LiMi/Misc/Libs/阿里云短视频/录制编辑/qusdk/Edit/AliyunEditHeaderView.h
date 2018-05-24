//
//  AliyunEditHeaderView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliyunEditHeaderView : UIView

@property (nonatomic, copy) void (^backClickBlock)();
@property (nonatomic, copy) void (^saveClickBlock)();

@end
