//
//  PickerView.m
//  XingYuan
//
//  Created by YunKuai on 2017/10/14.
//  Copyright © 2017年 Vicki. All rights reserved.
//

#import "PickerView.h"

@interface PickerView ()
@property (nonatomic,weak) UIButton *cancelBtn;
@property (nonatomic,weak) UIButton *okBtn;
@end
@implementation PickerView

- (instancetype)initWithFrame:(CGRect)frame{
    if([super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        
        UIView *pickerContainView = [[UIView alloc] init];
        pickerContainView.backgroundColor = [UIColor whiteColor];
        [self addSubview:pickerContainView];
        [pickerContainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(260);
        }];
        self.pickerContainView = pickerContainView;
        
        UIView *toolsContainView = [[UIView alloc] init];
        toolsContainView.backgroundColor = [UIColor whiteColor
                                            ];
        [self addSubview:toolsContainView];
        [toolsContainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pickerContainView);
            make.right.equalTo(self.pickerContainView);
            make.bottom.equalTo(self.pickerContainView.mas_top);
            make.height.mas_equalTo(40);
        }];
        
        UIView *topCoverView = [[UIView alloc] init];
        UIColor *color = [[UIColor alloc] initWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:0.2];
        topCoverView.backgroundColor = color;
        [self addSubview:topCoverView];
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toDismiss)];
        [topCoverView addGestureRecognizer:tapG];
        [topCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(toolsContainView.mas_top);
            make.top.equalTo(self);
        }];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        UIColor *cancelColor = [[UIColor alloc] initWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1];
        [cancelBtn setTitleColor:cancelColor forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(dealCancel) forControlEvents:UIControlEventTouchUpInside];
        [toolsContainView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(toolsContainView);
            make.top.equalTo(toolsContainView);
            make.bottom.equalTo(toolsContainView);
            make.width.mas_equalTo(50);
        }];
        self.cancelBtn = cancelBtn;
        
        UIButton *okBtn = [[UIButton alloc] init];
        [okBtn setTitle:@"确定" forState:UIControlStateNormal];
        UIColor *okBtncolor = [[UIColor alloc] initWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1];
        [okBtn setTitleColor:okBtncolor forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(dealOK) forControlEvents:UIControlEventTouchUpInside];
        [toolsContainView addSubview:okBtn];
        [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(toolsContainView);
            make.top.equalTo(toolsContainView);
            make.bottom.equalTo(toolsContainView);
            make.width.mas_equalTo(50);
        }];
        self.okBtn = okBtn;
        
        
        UIView *toolContianViewTopSeparateLine = [[UIView alloc] init];
        UIColor *topColor = [[UIColor alloc] initWithRed:184/255.0 green:186/255.0 blue:189/255.0 alpha:1];
        toolContianViewTopSeparateLine.backgroundColor = topColor;
        [toolsContainView addSubview:toolContianViewTopSeparateLine];
        [toolContianViewTopSeparateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(toolsContainView);
            make.left.equalTo(toolsContainView);
            make.right.equalTo(toolsContainView);
            make.height.mas_equalTo(0.5);
        }];
        
        UIView *toolContianViewBottomSeparateLine = [[UIView alloc] init];
        UIColor *separateColor = [[UIColor alloc] initWithRed:184/255.0 green:186/255.0 blue:189/255.0 alpha:1];
        toolContianViewBottomSeparateLine.backgroundColor = separateColor;
        [toolsContainView addSubview:toolContianViewBottomSeparateLine];
        [toolContianViewBottomSeparateLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(toolsContainView);
            make.left.equalTo(toolsContainView);
            make.right.equalTo(toolsContainView);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}

- (void)dealCancel{
    NSLog(@"点击了取消");
}


- (void)dealOK{
    NSLog(@"点击了OK");
}

//展示
- (void)toShow{
    
}

//隐藏
- (void)toDismiss{
    [self removeFromSuperview];
}


@end
