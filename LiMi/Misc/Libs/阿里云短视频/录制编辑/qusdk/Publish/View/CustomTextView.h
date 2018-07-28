//
//  CustomTextView.h
//  LiMi
//
//  Created by dev.liufeng on 2018/7/25.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTextView;

@protocol CustomTextViewDelegate<NSObject>
- (void)customTextViewClickedDelete:(CustomTextView *)customTextView;
@end

@interface CustomTextView : UITextView
@property (nonatomic,weak) id<CustomTextViewDelegate>customTextViewDelegate;
- (void)manualDelete;
@end
