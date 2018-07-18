//
//  TextModel.h
//  TextRotateViewDemo
//
//  Created by dev.liufeng on 2018/6/27.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TextModel : NSObject

/**
 文本大小，默认值15
 */
@property (nonatomic,assign) CGFloat textFont;

/**
 文本颜色，默认值 黑色
 */
@property (nonatomic,strong) UIColor *textColor;

/**
 展示文本
 */
@property (nonatomic,copy) NSString *text;


/**
 文本尺寸
 */
@property (nonatomic,assign) CGSize textSize;

- (instancetype)initWithText:(NSString *)text;
@end
