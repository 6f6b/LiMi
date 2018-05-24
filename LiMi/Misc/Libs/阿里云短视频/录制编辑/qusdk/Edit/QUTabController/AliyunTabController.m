//
//  AliyunTabController.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTabController.h"
#import "AliyunColorItemView.h"
#import "AliyunFontItemView.h"
#import "AliyunEffectFontInfo.h"

@interface AliyunTabController ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *containerHeaderView;
@property (nonatomic, strong) AliyunColorItemView *colorItemView;
@property (nonatomic, strong) AliyunFontItemView *fontItemView;

@end

@implementation AliyunTabController

- (void)presentTabContainerViewInSuperView:(UIView *)superView height:(CGFloat)height duration:(CGFloat)duration
{
    if (!self.containerView) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height)];
        [superView addSubview:self.containerView];
    }
    
    [self setupContainerViewsSubViews];
    [UIView animateWithDuration:duration delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.frame = CGRectMake(0, ScreenHeight - height - 40, ScreenWidth, height);
    } completion:nil];
}

- (void)dismissPresentTabContainerView
{
    CGRect frame = self.containerView.frame;
    frame.origin.y = ScreenHeight;
    
    [UIView animateWithDuration:.2 animations:^{
        self.containerView.frame = frame;
    } completion:^(BOOL finished) {
        [self.containerView removeFromSuperview];
        self.containerView = nil;
        self.colorItemView = nil;
        self.fontItemView = nil;
        self.containerHeaderView = nil;
    }];
}

- (void)setupContainerViewsSubViews {
    if (self.containerHeaderView) {
        return;
    }
    
    self.containerHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    self.containerHeaderView.backgroundColor = [UIColor colorWithRed:35.0/255 green:42.0/255 blue:66.0/255 alpha:1];
    [self.containerView addSubview:self.containerHeaderView];
    
    UIButton *completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completeBtn.frame = CGRectMake(ScreenWidth - 70, 0, 70, 40);
    [completeBtn addTarget:self action:@selector(completeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    completeBtn.backgroundColor = [UIColor colorWithRed:239.0/255 green:75.0/255 blue:129.0/255 alpha:1];

    [self.containerHeaderView addSubview:completeBtn];
    
    NSArray *btnImageNames = @[@"QPSDK.bundle/edit_tab_keyboard",@"QPSDK.bundle/edit_tab_font",@"QPSDK.bundle/edit_tab_color"];
    NSArray *btnActions = @[@"keyboardButtonClicked:",@"fontButtonClicked:",@"colorButtonClicked:"];
    

    CGFloat dlt = SizeWidth(50 + 24);
    for (int idx = 0; idx < [btnImageNames count]; idx++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, SizeWidth(24), SizeWidth(24));
        [self.containerHeaderView addSubview:btn];
        btn.center = CGPointMake( SizeWidth(30) + dlt * idx + btn.frame.size.width / 2 , 20);
        
        [btn setImage:[UIImage imageNamed:[btnImageNames objectAtIndex:idx]] forState:UIControlStateNormal];
        [btn addTarget:self action:NSSelectorFromString([btnActions objectAtIndex:idx]) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Actions -
- (void)completeButtonClicked:(id)sender {
    [self dismissPresentTabContainerView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(completeButtonClicked)]) {
        [self.delegate completeButtonClicked];
    }
}

- (void)colorButtonClicked:(id)sender {
    [self.delegate keyboardShouldHidden];
    
    [UIView animateWithDuration:.2 animations:^{
        
        self.fontItemView.frame = CGRectMake(0, CGRectGetHeight(self.containerView.bounds) + 40, ScreenWidth, CGRectGetHeight(self.containerView.bounds) - 40);
        self.colorItemView.frame = CGRectMake(0, 40, ScreenWidth, CGRectGetHeight(self.containerView.bounds) - 40);
    }];
    
    [self.containerView addSubview:self.colorItemView];
}

- (void)fontButtonClicked:(id)sender {
    [self.delegate keyboardShouldHidden];
    
    [UIView animateWithDuration:.2 animations:^{
        self.colorItemView.frame = CGRectMake(0, CGRectGetHeight(self.containerView.bounds) , ScreenWidth, CGRectGetHeight(self.containerView.bounds) - 40);
        self.fontItemView.frame = CGRectMake(0, 40, ScreenWidth, CGRectGetHeight(self.containerView.bounds) - 40);
    }];
    [self.containerView addSubview:self.fontItemView];
}

- (void)keyboardButtonClicked:(id)sender {
    [self.delegate keyboardShouldAppear];
}
#pragma mark - AliyunColorItemViewDelegate -

- (void)textColorChanged:(AliyunColor *)color
{
    [self.delegate textColorChanged:color];
}

#pragma mark - AliyunFontItemViewDelegate -

- (void)onSelectFontWithFontInfo:(AliyunEffectFontInfo *)fontInfo {
    
    [self.delegate textFontChanged:fontInfo.fontName];
}

#pragma mark - Setter -

- (AliyunColorItemView *)colorItemView {
    if (!_colorItemView) {
        _colorItemView = [[AliyunColorItemView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.containerView.bounds) , ScreenWidth, CGRectGetHeight(self.containerView.bounds) - 40)];
        _colorItemView.delegate = (id)self;
    }
    return _colorItemView;
}

- (AliyunFontItemView *)fontItemView {
    if (!_fontItemView) {
        _fontItemView = [[AliyunFontItemView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.containerView.bounds) , ScreenWidth, CGRectGetHeight(self.containerView.bounds) - 40)];
        _fontItemView.delegate = (id)self;
    }
    return _fontItemView;
}


@end
