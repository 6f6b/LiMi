//
//  CustomTextView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/7/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "CustomTextView.h"

@implementation CustomTextView

- (void)deleteBackward{
//    if([self.customTextViewDelegate respondsToSelector:@selector(customTextViewClickedDelete:)]){
        [self.customTextViewDelegate customTextViewClickedDelete:self];
//    }
}

- (void)manualDelete{
    [super deleteBackward];
}
@end
