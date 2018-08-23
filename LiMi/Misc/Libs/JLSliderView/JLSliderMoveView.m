//
//  JLSliderMoveView.m
//  WQHCarJob
//
//  Created by job on 16/12/5.
//  Copyright © 2016年 job. All rights reserved.
//

#import "JLSliderMoveView.h"
#import "UIView+Frame.h"



typedef enum : NSUInteger {
    SlideTypeLeft,
    SlideTypeRight,
    SlideTypeNone,
} SlideType;

@interface JLSliderMoveView  () {
    CGFloat  iconwidth;
}

//是否重合
@property (assign, nonatomic) BOOL isCoincide;
@property (assign, nonatomic) SlideType slideType;
@property (assign, nonatomic) CGFloat coincideX;
@property (assign, nonatomic) CGFloat startX;


//@property (assign, nonatomic) CGFloat startLeftX;
//@property (assign, nonatomic) CGFloat startRightX;

@end


@implementation JLSliderMoveView


- (instancetype)initWithFrame:(CGRect)frame leftPosition:(CGFloat)leftposition rightPosition:(CGFloat)rightposition{
    self = [self initWithFrame:frame];
    if(self){
        self.leftPosition  = leftposition;
        self.rightPosition = rightposition;
        self.leftLabel.centerX = leftposition;
        self.rightLabel.centerX = rightposition;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.userInteractionEnabled = YES;
        iconwidth = 22;
 
        
        self.leftLabel = [self creatLabelWithFrame:CGRectMake(0, 0, iconwidth, iconwidth)];
        [self addSubview:self.leftLabel];
        UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doLeftPanGesture:)];
        [self.leftLabel addGestureRecognizer:leftPan];
        
        
        self.rightLabel = [self creatLabelWithFrame:CGRectMake(self.width - iconwidth, 0, iconwidth, iconwidth)];
        [self addSubview:self.rightLabel];
        
        UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(doRightPanGesture:)];
        [self.leftLabel addGestureRecognizer:rightPan];
        
        self.leftPosition  = self.leftLabel.centerX;
        self.rightPosition = self.rightLabel.centerX;
    }
    return self;
}


- (void)setLeftPosition:(CGFloat)leftPosition{
    _leftPosition = leftPosition;
    if(leftPosition<10){
        self.leftLabel.centerX = 10;
    }else{
        self.leftLabel.centerX = leftPosition;
    }
}

- (void)setRightPosition:(CGFloat)rightPosition{
    _rightPosition = rightPosition;
    self.rightLabel.centerX = rightPosition;
}

-(UILabel *)creatLabelWithFrame:(CGRect )frame {
    UILabel *label =  [[UILabel alloc]initWithFrame:frame];
    label.textColor = [UIColor darkGrayColor];
    label.backgroundColor = [UIColor whiteColor];
    label.layer.masksToBounds = YES;
    label.layer.borderWidth = 0.5;
    label.layer.borderColor = [UIColor lightGrayColor].CGColor;
    return  label;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch  = [touches anyObject];
    CGPoint  point  = [touch locationInView:self];
    
    NSLog(@"%f,%f",point.x,point.y);
//    if(point.x > CGRectGetMaxX(self.frame)){return;}
    if(self.isCoincide){
        if (point.x > self.coincideX +1 ) {
            self.slideType = SlideTypeRight;
            self.isCoincide = NO;
        }else{
            self.slideType = SlideTypeLeft;
            self.isCoincide = NO;
        }
//        if (point.x < self.coincideX -1 ) {
//            self.slideType = SlideTypeLeft;
//            self.isCoincide = NO;
//        }
        return;
    }
    //超出滑动的位置则不可以控制---- 左边的位置大于右边的位置不能滑动
//    if (point.y>self.height) {
//        return;
//    }
    //当滑动的位置不在两个
//    if (self.slideType == SlideTypeNone) {
//        return;
//    }
    //当滑动左边的时候
    if (self.slideType == SlideTypeLeft || self.slideType == SlideTypeNone ) {
        CGFloat maxRight = self.rightLabel.centerX;
        if (point.x < maxRight || self.rightLabel.centerX > self.leftLabel.centerX) {
            self.leftLabel.centerX = point.x;
            if (self.leftLabel.centerX < iconwidth/2) {
                self.leftLabel.centerX = iconwidth/2;
            }
            if (self.leftLabel.centerX > self.rightLabel.centerX) {
                self.leftLabel.centerX = self.rightLabel.centerX;
            }
            self.leftPosition = self.leftLabel.centerX ;
            if ([self.delegate respondsToSelector:@selector(slidMovedLeft:andRightPosition:)]) {
                [self.delegate slidMovedLeft:self.leftPosition andRightPosition:self.rightPosition];
            }
        }
    }
    //当滑动右边的时候
    if (self.slideType == SlideTypeRight) {
        CGFloat maxLeft = self.leftLabel.centerX;
        if (point.x > maxLeft || self.rightLabel.centerX > self.leftLabel.centerX) {
            self.rightLabel.centerX = point.x;
            if (self.rightLabel.centerX > self.width-iconwidth/2) {
                self.rightLabel.centerX = self.width-iconwidth/2;
                NSLog(@"滑动右边---上");
            }
            if (self.leftLabel.centerX > self.rightLabel.centerX) {
                self.rightLabel.centerX = self.leftLabel.centerX;
                NSLog(@"滑动右边---下");
            }
            self.rightPosition = self.rightLabel.centerX ;
            if ([self.delegate respondsToSelector:@selector(slidMovedLeft:andRightPosition:)]) {
                [self.delegate slidMovedLeft:self.leftPosition andRightPosition:self.rightPosition];
            }
            
        }
    }
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"开始点击");
    UITouch *touch  = [touches anyObject];
    CGPoint  point  = [touch locationInView:self];
    self.startX = point.x;
    //当手指点中下面的滑条时，才能滑动
    
    //如果重合
    if (self.rightLabel.centerX-5<self.leftLabel.centerX    &&  self.leftLabel.centerX< self.rightLabel.centerX+5 )  {
        self.isCoincide = YES;
        self.coincideX  = point.x;
        return;
    }else {
        self.isCoincide = NO;
    }
 
    //手指放在左边范围
    if (point.x <self.leftLabel.right && point.x >self.leftLabel.left) {
        self.slideType = SlideTypeLeft;
    }else  if (point.x <self.rightLabel.right && point.x >self.rightLabel.left) {
        self.slideType = SlideTypeRight;
    }else {
        self.slideType = SlideTypeNone;
    }
    
  
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(slidDidEndMovedLeft:andRightPosition:)]) {
        [self.delegate slidDidEndMovedLeft:self.leftPosition  andRightPosition:self.rightPosition];
    }

}


-(void)setIsRound:(BOOL)isRound {
    _isRound = isRound;
    if (isRound) {
        self.leftLabel.size    = CGSizeMake(self.height, self.height);
        self.leftLabel.layer.cornerRadius = self.leftLabel.height /2;
        self.rightLabel.size = CGSizeMake(self.height, self.height);
        self.rightLabel.layer.cornerRadius = self.rightLabel.height /2;
    }
}
-(void)setThumbColor:(UIColor *)thumbColor {
    _thumbColor = thumbColor;
    _leftLabel.backgroundColor = thumbColor;
    _rightLabel.backgroundColor = thumbColor;
}


-(void)doLeftPanGesture:(UIPanGestureRecognizer *)gesture {
    
    CGFloat startX = 0.0;
    CGPoint point = [gesture translationInView:self];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        startX = gesture.view.centerX;
        
    }if (gesture.state == UIGestureRecognizerStateChanged) {
        self.leftLabel.centerX = startX + point.x;
        
    }if (gesture.state == UIGestureRecognizerStateEnded) {
        
    }
    
}

-(void)doRightPanGesture:(UIPanGestureRecognizer *)gesture {
    
}

@end
