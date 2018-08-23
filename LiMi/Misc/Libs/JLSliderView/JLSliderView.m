//
//  JLSliderView.m
//  WQHCarJob
//
//  Created by job on 16/12/5.
//  Copyright © 2016年 job. All rights reserved.
//

#import "JLSliderView.h"
#import "UIView+Frame.h"
#import "JLSliderMoveView.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define iconwidth   44
#define iconheight  44

@interface JLSliderView()<SlidMoveDelegate>

@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) JLSliderMoveView *moveView;
@property (strong, nonatomic) UIView *bgView;


@property (assign, nonatomic) CGFloat moveVHeight;

@property (assign, nonatomic) CGFloat lineVHeight;

@end

@implementation JLSliderView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame sliderType:(JLSliderType )type {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
        self.sliderType = type;
    }
    return self;
}



-(void)initView {
    self.moveVHeight = 20;
    self.lineVHeight = 4;
    self.userInteractionEnabled = YES;
    self.minValue = 18;
    self.maxValue = 48;
    [self initMoveView];
    
   
}

-(UILabel *)creatLabelWithFrame:(CGRect )frame {
    UILabel *label =  [[UILabel alloc]initWithFrame:frame];
    label.textColor = [UIColor whiteColor];
    label.font      = [UIFont systemFontOfSize:14];
    label.layer.cornerRadius = 5;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor blueColor];
    return  label;
}





-(void)initMoveView {
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.lineVHeight)];
    self.bgView.backgroundColor = [UIColor colorWithRed:53.0/255 green:53.0/255 blue:53.0/255 alpha:1];
    self.bgView.layer.cornerRadius = self.bgView.height/2                                                            ;
    self.bgView.layer.masksToBounds = YES;
    [self addSubview:self.bgView];
    //改变颜色的线
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.lineVHeight)];
    self.bgView.backgroundColor = [UIColor whiteColor];
    
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.lineVHeight)];
    self.lineView.backgroundColor = [UIColor blueColor];
    self.lineView.layer.cornerRadius = self.lineView.height/2                                                            ;
    self.lineView.layer.masksToBounds = YES;
    [self addSubview:self.lineView];
    
    //手指移动的视图
    self.moveView = [[JLSliderMoveView alloc]initWithFrame:CGRectMake(self.lineView.left-self.moveVHeight/2 , self.lineView.bottom, self.lineView.width+self.moveVHeight, self.moveVHeight)];
    self.moveView.delegate = self;
    [self addSubview:self.moveView];
}

-(void)setSliderType:(JLSliderType)sliderType {
    if (sliderType == JLSliderTypeCenter) {
        self.moveView.centerY = self.lineView.centerY;
        self.moveView.isRound = YES;
    }else if (sliderType == JLSliderTypeBottom){
        self.moveView.top = self.lineView.bottom+10;
        self.moveView.isRound = NO;
        self.moveView.thumbColor = [UIColor blueColor];
    }
}

-(void)setThumbColor:(UIColor *)thumbColor {
    _thumbColor = thumbColor;
    self.lineView.backgroundColor = thumbColor;
}

-(void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    self.bgView.backgroundColor = bgColor;
}

//- (void)setCurrentMinValue:(NSUInteger)currentMinValue{
//    _currentMinValue = currentMinValue;
//    _currentMaxValue == nil ? 0 : _currentMaxValue;
//    if (_currentMaxValue >= _currentMinValue){
//        self.lineView.width = (CGFloat)(_currentMaxValue-_currentMinValue)/(CGFloat)(_maxValue-_minValue)*self.bgView.width;
//    }
//    NSUInteger width = self.maxValue - self.minValue;
//    self.lineView.x = (CGFloat)(currentMinValue - self.minValue)/(CGFloat)(width)*self.bgView.width + self.bgView.x;
//    self.moveView.leftPosition = self.lineView.x;
//}
//
//- (void)setCurrentMaxValue:(NSUInteger)currentMaxValue{
//    _currentMaxValue = currentMaxValue;
//    _currentMinValue == nil ? 0 : _currentMinValue;
//
//}

- (void)setCurrentMinValue:(NSUInteger)minValue currentMaxValue:(NSUInteger)maxValue{
    _currentMaxValue = maxValue;
    _currentMinValue = minValue;
    
    if (_currentMaxValue >= _currentMinValue){
        self.lineView.width = (CGFloat)(_currentMaxValue-_currentMinValue)/(CGFloat)(_maxValue-_minValue)*self.bgView.width;
    }
    
    NSUInteger width = self.maxValue - self.minValue;
    
    self.lineView.x = (CGFloat)(_currentMinValue - self.minValue)/(CGFloat)(width)*self.bgView.width + self.bgView.x;
    self.lineView.right =(CGFloat)(_currentMaxValue - self.minValue)/(CGFloat)(width)*self.bgView.width + self.bgView.x;
    
    self.moveView.rightPosition = self.lineView.x + self.lineView.width;
    self.moveView.leftPosition = self.lineView.x;
}

#pragma mark --- 代理方法
-(void)slidMovedLeft:(CGFloat)leftPosition andRightPosition:(CGFloat)rightPosition {
    self.lineView.x = leftPosition;
    self.lineView.width = rightPosition - leftPosition;

    
    NSUInteger width = self.maxValue - self.minValue;
    NSUInteger left  = self.minValue +(int) (self.lineView.x - self.bgView.x)/self.bgView.width * width;
    NSUInteger right  = self.minValue +(int) (self.lineView.right - self.bgView.x)/self.bgView.width * width;
    self.currentMinValue = left;
    self.currentMaxValue = right;

    if (self.lineView.width == 0) {
        self.lineView.width = 1;
    }
}

-(void)slidDidEndMovedLeft:(CGFloat)leftPosition andRightPosition:(CGFloat)rightPosition {
    
    if ([self.delegate respondsToSelector:@selector(sliderViewDidSliderLeft:right:)]) {
        [self.delegate sliderViewDidSliderLeft:self.currentMinValue right:self.currentMaxValue];
    }
}



@end
