//
//  AliyunMusicPickTopView.h
//  qusdk
//
//  Created by Worthy on 2017/6/8.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AliyunMusicPickTopViewDelegate <NSObject>
-(void)cancelButtonClicked;
-(void)finishButtonClicked;
@end

@interface AliyunMusicPickTopView : UIView
@property (nonatomic, weak) id<AliyunMusicPickTopViewDelegate> delegate;

@property (nonatomic, strong) UILabel *nameLabel;
@end
