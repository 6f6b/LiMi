//
//  AliyunVisibleChooseController.m
//  LiMi
//
//  Created by dev.liufeng on 2018/5/27.
//  Copyright © 2018年 Chengdu you Hong Science & Technology Co., Ltd. All rights reserved.
//

#import "AliyunVisibleChooseController.h"

@interface AliyunVisibleChooseController ()
@property (weak, nonatomic) IBOutlet UIView *allVisiableContainView;
@property (weak, nonatomic) IBOutlet UIButton *allVisiableButton;
@property (weak, nonatomic) IBOutlet UIView *allFollowersContainView;
@property (weak, nonatomic) IBOutlet UIButton *allFollowersButton;
@property (weak, nonatomic) IBOutlet UIView *onlySelfContainView;
@property (weak, nonatomic) IBOutlet UIButton *onlySelfButton;
@end

@implementation AliyunVisibleChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapAll = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAllVisibleContainView)];
    [self.allVisiableContainView addGestureRecognizer:tapAll];
    
    UITapGestureRecognizer *tapFollowers = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAllFollowersContainView)];
    [self.allVisiableContainView addGestureRecognizer:tapFollowers];
    
    UITapGestureRecognizer *tapOnlySelf = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnlySelfContainView)];
    [self.allVisiableContainView addGestureRecognizer:tapOnlySelf];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

- (void)tapAllVisibleContainView{
    [self setVisibleType:VisibleChooseTypeAll];
    self.chooseTypeBlock(VisibleChooseTypeAll);
}

- (void)tapAllFollowersContainView{
    [self setVisibleType:VisibleChooseTypeFollowers];
    self.chooseTypeBlock(VisibleChooseTypeFollowers);
}

- (void)tapOnlySelfContainView{
    [self setVisibleType:VisibleChooseTypeOnlySelf];
    self.chooseTypeBlock(VisibleChooseTypeOnlySelf);
}

- (void)setVisibleType:(VisibleChooseType)visibleType{
    _visibleType = visibleType;
    [self refreshUIWith:visibleType];
}

- (void)refreshUIWith:(VisibleChooseType)visibleType{
    [self.allVisiableButton setSelected:NO];
    [self.allFollowersButton setSelected:NO];
    [self.onlySelfButton setSelected:NO];

    if(visibleType == VisibleChooseTypeAll){
        [self.allVisiableButton setSelected:YES];
    }
    if(visibleType == VisibleChooseTypeFollowers){
        [self.allFollowersButton setSelected:YES];
    }
    if(visibleType == VisibleChooseTypeOnlySelf){
        [self.onlySelfButton setSelected:YES];
    }
}
@end
