//
//  JLSliderMoveView.h
//  WQHCarJob
//
//  Created by job on 16/12/5.
//  Copyright © 2016年 job. All rights reserved.
//

#import <UIKit/UIKit.h>





@protocol SlidMoveDelegate <NSObject>

-(void)slidMovedLeft:(CGFloat)leftPosition andRightPosition:(CGFloat) rightPosition;



-(void)slidDidEndMovedLeft:(CGFloat)leftPosition andRightPosition:(CGFloat) rightPosition;


@end





@interface JLSliderMoveView : UIView
@property (strong, nonatomic) UILabel *leftLabel;
@property (strong, nonatomic) UILabel *rightLabel;
@property (assign, nonatomic) CGFloat   leftPosition;
@property (assign, nonatomic) CGFloat   rightPosition;
@property (assign, nonatomic) BOOL isRound;
@property (strong, nonatomic) UIColor *thumbColor;
@property (weak,   nonatomic) id <SlidMoveDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame leftPosition:(CGFloat)leftposition rightPosition:(CGFloat)rightposition;
@end
