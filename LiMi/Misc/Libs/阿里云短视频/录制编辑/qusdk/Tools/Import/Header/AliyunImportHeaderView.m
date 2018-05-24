//
//  AliyunImportHeaderView.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/8.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunImportHeaderView.h"

@interface AliyunImportHeaderView ()
@property (nonatomic, strong) UIButton *buttonCancel;
@property (nonatomic, strong) UIButton *buttonTitle;
@end

@implementation AliyunImportHeaderView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.buttonTitle];
    [self addSubview:self.buttonCancel];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.buttonTitle setTitle:title forState:UIControlStateNormal];
    CGSize size = [title boundingRectWithSize:CGSizeMake(180, 60) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_buttonTitle.titleLabel.font} context:nil].size;
    [_buttonTitle setTitle:title forState:0];
    [_buttonTitle setTitleEdgeInsets:UIEdgeInsetsMake(0, -12 - 4, 0, 12 + 4)];
    [_buttonTitle setImageEdgeInsets:UIEdgeInsetsMake(0, size.width + 4, 0, -size.width - 4)];
}

- (UIButton *)buttonTitle {
    if (!_buttonTitle) {
        _buttonTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonTitle.bounds = CGRectMake(0, 0, 180, 44);
        _buttonTitle.center = CGPointMake(ScreenWidth / 2, 42);
        [_buttonTitle setTitleColor:[UIColor whiteColor] forState:0];
        [_buttonTitle setImage:[AliyunImage imageNamed:@"roll_list"] forState:0];
        [_buttonTitle addTarget:self action:@selector(buttonTitleClick) forControlEvents:UIControlEventTouchUpInside];
        _buttonTitle.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _buttonTitle;
}

- (UIButton *)buttonCancel {
    if (!_buttonCancel) {
        _buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonCancel.frame = CGRectMake(0, 20, 44, 44);
        [_buttonCancel setTitleColor:[UIColor whiteColor] forState:0];
        [_buttonCancel setTitle:NSLocalizedString(@"cancel_camera_import", nil) forState:0];
        [_buttonCancel addTarget:self action:@selector(buttonCancelClick) forControlEvents:UIControlEventTouchUpInside];
        _buttonCancel.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _buttonCancel;
}

- (void)buttonTitleClick {
    [_delegate headerViewDidSelect];
}

- (void)buttonCancelClick {
    [_delegate headerViewDidCancel];
}

@end
