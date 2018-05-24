//
//  AliyunMusicPickHeaderView.h
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AliyunMusicPickHeaderView;
@protocol AliyunMusicPickHeaderViewDelegate <NSObject>
- (void)didSelectHeader:(AliyunMusicPickHeaderView *)view;
@end

@interface AliyunMusicPickHeaderView : UITableViewHeaderFooterView
@property (nonatomic, weak) id<AliyunMusicPickHeaderViewDelegate> delegate;
@property (nonatomic, strong) UIButton   *button;
@property (nonatomic, strong) UIView     *line;
@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) UILabel    *artistLabel;
@property (nonatomic, strong) UIImageView *imageView;
- (void)shouldExpand:(BOOL)expand;
@end
