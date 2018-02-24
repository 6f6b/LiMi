//
//  NTESSessionListViewController.h
//  NIMDemo
//
//  Created by chris on 15/2/2.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NIMSessionListViewController.h"

@interface NTESSessionListViewController : NIMSessionListViewController

@property (nonatomic,strong) UILabel *emptyTipLabel;
//Edit by LiuFeng   (NIM) 2018/2/24
@property (nonatomic,strong) UIImageView *emptyTipImageView;
@end
