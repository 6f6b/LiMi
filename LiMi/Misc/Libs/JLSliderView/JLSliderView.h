//
//  JLSliderView.h
//  WQHCarJob
//
//  Created by job on 16/12/5.
//  Copyright © 2016年 job. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol JLSliderViewDelegate <NSObject>

-(void)sliderViewDidSliderLeft:(NSUInteger )leftValue right:(NSUInteger )rightValue;

@end





typedef NS_ENUM(NSInteger, JLSliderType) {
    //滑动的在轴上
    JLSliderTypeCenter = 0,
    JLSliderTypeBottom = 1,
};

@interface JLSliderView : UIView

@property (strong, nonatomic) UIColor *thumbColor;

@property (strong, nonatomic) UIColor *bgColor;

@property (assign, nonatomic) NSUInteger minValue;


@property (assign, nonatomic) NSUInteger maxValue;

@property (assign, nonatomic) JLSliderType sliderType;

@property (assign, nonatomic) NSUInteger currentMinValue;

@property (assign, nonatomic) NSUInteger currentMaxValue;

@property (assign, nonatomic) id<JLSliderViewDelegate> delegate;


-(instancetype)initWithFrame:(CGRect)frame sliderType:(JLSliderType )type;

- (instancetype)initWithFrame:(CGRect)frame sliderType:(JLSliderType)type maxValue:(NSUInteger)maxValue minValue:(NSUInteger)minValue currentMaxValue:(NSUInteger)currentMaxValue currentMinValue:(NSUInteger)currentMinValue;

- (void)setCurrentMinValue:(NSUInteger)minValue currentMaxValue:(NSUInteger)maxValue;

@end
