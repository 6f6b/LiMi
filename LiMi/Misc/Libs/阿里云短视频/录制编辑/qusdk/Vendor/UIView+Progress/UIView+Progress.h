//
//  UIView+Progress.h
//  
//
//  Created by lslin on 14-6-13.
//  Copyright (c) 2014年 lessfun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - PieProgressView

@interface PieProgressView : UIView

/**
 * The progress range from 0.0 to 1.0.
 */
@property (nonatomic) CGFloat progress;

/**
 * The border margin spacing. default is 6
 */
@property (nonatomic) CGFloat borderSpacing;

/**
 * The color of the progress, default is [UIColor clearColor]
 */
@property (nonatomic, strong) UIColor *progressColor;

/**
 * The color of background mask. default is (255, 255, 255, 0.5).
 */
@property (nonatomic, strong) UIColor *backgroundMaskColor;

@end

#pragma mark - RectProgressView

@interface RectProgressView : UIView

/**
 * The progress range from 0.0 to 1.0.
 */
@property (nonatomic) CGFloat progress;

/**
 * The color of the progress, default is [UIColor clearColor]
 */
@property (nonatomic, strong) UIColor *progressColor;

@end

#pragma mark - UIView+Progress

@interface UIView (Progress)

/**
 * Get PieProgressView to modify the property.
 * @return PieProgressView, if not exists, will create a new one.
 */
- (PieProgressView *)pieProgressView;

/**
 * Update the progress status.
 * @param progress is from 0 to 1. "1" means done。
 */
- (void)setPieProgress:(CGFloat)progress;

/**
 * Get RectProgressView to modify the property.
 * @return RectProgressView, if not exists, will create a new one.
 */
- (RectProgressView *)rectProgressView;


/**
 * Update the progress status.
 * @param progress is from 0 to 1. "1" means done。
 */
- (void)setRectProgress:(CGFloat)progress;

@end
