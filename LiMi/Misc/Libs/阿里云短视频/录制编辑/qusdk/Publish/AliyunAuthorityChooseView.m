//
//  AliyunAuthorityChooseView.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/27.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "AliyunAuthorityChooseView.h"
@interface AliyunAuthorityChooseView ()
@property (nonatomic,strong) UILabel *leftInfoLabel;
@property (nonatomic,strong) UIImageView *rightArrowImageView;
@end
@implementation AliyunAuthorityChooseView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _leftInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _leftInfoLabel.text = @"谁可以看";
        _leftInfoLabel.textColor = UIColor.whiteColor;
        _leftInfoLabel.font = [UIFont systemFontOfSize:14];
        [_leftInfoLabel sizeToFit];
        CGPoint _leftInfoLabelCenter = CGPointZero;
        _leftInfoLabelCenter.x = _leftInfoLabel.frame.size.width/2 +15;
        _leftInfoLabelCenter.y = frame.size.height/2;
        _leftInfoLabel.center = _leftInfoLabelCenter;
        [self addSubview:_leftInfoLabel];
        
        _rightArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
        _rightArrowImageView.image = [UIImage imageNamed:@"rightbtn"];
        CGPoint rightArrowImageViewCenter = CGPointZero;
        rightArrowImageViewCenter.y = frame.size.height/2;
        rightArrowImageViewCenter.x = frame.size.width-15-11;
        _rightArrowImageView.center = rightArrowImageViewCenter;
        [self addSubview:_rightArrowImageView];
        
        _rightInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rightInfoLabel.text = @"所有人可见";
        _rightInfoLabel.textColor = UIColor.whiteColor;
        _rightInfoLabel.font = [UIFont systemFontOfSize:14];
        [_rightInfoLabel sizeToFit];
        _rightInfoLabel.textAlignment = NSTextAlignmentRight;
        CGPoint _rightInfoLabelCenter = CGPointZero;
        _rightInfoLabelCenter.x = _rightArrowImageView.frame.origin.x-9-_rightInfoLabel.frame.size.width/2;
        _rightInfoLabelCenter.y = frame.size.height/2;
        _rightInfoLabel.center = _rightInfoLabelCenter;
        [self addSubview:_rightInfoLabel];
        
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
