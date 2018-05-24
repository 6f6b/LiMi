//
//  AliyunPublishTopView.h
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AliyunPublishTopViewDelegate <NSObject>
-(void)cancelButtonClicked;
-(void)finishButtonClicked;
@end
@interface AliyunPublishTopView : UIView
@property (nonatomic, weak) id<AliyunPublishTopViewDelegate> delegate;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *finishButton;
@end
