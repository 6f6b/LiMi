//
//  PickerView.h
//  XingYuan
//
//  Created by YunKuai on 2017/10/14.
//  Copyright © 2017年 Vicki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

@interface PickerView : UIView
@property (nonatomic,weak) UIView *pickerContainView;

//取消按钮点击事件
- (void)dealCancel;

//确定按钮点击事件
- (void)dealOK;

//显示
- (void)toShow;

//消失
- (void)toDismiss;
@end
