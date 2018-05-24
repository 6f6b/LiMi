//
//  AliyunCopyrightInfoViewController.m
//  AliyunVideo
//
//  Created by TripleL on 17/4/27.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCopyrightInfoViewController.h"

@interface AliyunCopyrightInfoViewController ()

@end

@implementation AliyunCopyrightInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubViews];
}


- (void)setupSubViews {
    
    self.view.backgroundColor = RGBToColor(35, 42, 66);
    UIView *topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 20, ScreenWidth, SizeHeight(44));
    topView.backgroundColor = RGBToColor(35, 42, 66);
    [self.view addSubview:topView];
    
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backButton.frame = CGRectMake(0, 0, SizeWidth(28 + 12 + 12), CGRectGetHeight(topView.frame));
    [backButton setImage:[AliyunImage imageNamed:@"back"] forState:(UIControlStateNormal)];
    [backButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    backButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:backButton];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.frame = CGRectMake(SizeWidth(132), SizeHeight(12), SizeWidth(56), SizeHeight(20));
    nameLabel.font = [UIFont systemFontOfSize:14.f];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"版权信息";
    [topView addSubview:nameLabel];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, CGRectGetMaxY(topView.frame), ScreenWidth, ScreenHeight);
    scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    [self.view addSubview:scrollView];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(scrollView.frame));
    contentLabel.font = [UIFont systemFontOfSize:14.f];
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.numberOfLines = 0;
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"版权信息" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    contentLabel.text = content;
    [contentLabel sizeToFit];
    scrollView.contentSize = CGSizeMake(ScreenWidth, contentLabel.frame.size.height + 50);
    [scrollView addSubview:contentLabel];
    
}

- (void)backButtonAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
