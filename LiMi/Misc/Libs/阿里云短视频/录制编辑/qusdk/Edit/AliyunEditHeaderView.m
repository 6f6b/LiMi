

//
//  AliyunEditHeaderView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEditHeaderView.h"

@implementation AliyunEditHeaderView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.clearColor;
//        self.backgroundColor = [UIColor colorWithRed:35.0/255 green:42.0/255 blue:66.0/255 alpha:1];
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
//        titleLabel.center = CGPointMake(CGRectGetMidX(frame), frame.size.height/2);
//        titleLabel.backgroundColor = [UIColor clearColor];
//        titleLabel.textColor = [UIColor whiteColor];
//        titleLabel.text = NSLocalizedString(@"video_title_edit", nil);
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:titleLabel];
        
        UIButton *backButton = [self buttonWithRect:CGRectMake(15, 25, 24, 14) image:@"short_video_back" action:@selector(backButtonClicked:)];
        [backButton sizeToFit];
        
        UIButton *saveButton = [self buttonWithRect:CGRectMake(ScreenWidth - 89, 20, 64, 25) image:nil action:@selector(saveButtonClicked:)];
        [saveButton setTitle:@"下一步" forState:UIControlStateNormal];
        [saveButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont systemFontOfSize:15];
        saveButton.backgroundColor = rgba(127, 110, 241, 1);
        saveButton.layer.cornerRadius = 4;
        saveButton.clipsToBounds = true;
    }
    return self;
}

- (UIButton *)buttonWithRect:(CGRect)rect image:(NSString *)imageName action:(SEL)sel
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)backButtonClicked:(id)sender
{
    if (self.backClickBlock) {
        self.backClickBlock();
    }
}

- (void)saveButtonClicked:(id)sender
{
    if (self.saveClickBlock) {
        self.saveClickBlock();
    }
}

@end
