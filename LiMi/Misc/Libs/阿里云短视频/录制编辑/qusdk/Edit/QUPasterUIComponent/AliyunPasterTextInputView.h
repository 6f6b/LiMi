//
//  AliyunPasterTextInputView.h
//  AliyunVideo
//
//  Created by Vienta on 2017/3/10.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunColor.h"

@protocol AliyunPasterTextInputViewDelegate <NSObject>

- (void)keyboardFrameChanged:(CGRect)rect animateDuration:(CGFloat)duration;
- (void)keyboardWillHide;
- (void)editWillFinish:(CGRect)inputviewFrame text:(NSString *)text fontName:(NSString *)fontName;

@end

@interface AliyunPasterTextInputView : UIView

@property (nonatomic, weak) id<AliyunPasterTextInputViewDelegate> delegate;
@property (nonatomic, assign) int maxCharacterCount;//最大可输入的字符个数  如果为0，则不显示字符个数

+ (id)createPasterTextInputView;

+ (id)createPasterTextInputViewWithText:(NSString *)text
                              textColor:(AliyunColor *)textColor
                               fontName:(NSString *)fontName
                           maxCharacterCount:(int)maxCount;

- (NSString *)getText;

- (void)shouldHiddenKeyboard;

- (void)shouldAppearKeyboard;

- (void)setFilterTextColor:(AliyunColor *)color;

- (AliyunColor *)getTextColor;

- (void)setFontName:(NSString *)fontName;

- (NSString *)fontName;

@end
