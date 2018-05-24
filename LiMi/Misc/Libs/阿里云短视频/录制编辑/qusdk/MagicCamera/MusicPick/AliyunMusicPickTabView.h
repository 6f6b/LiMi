//
//  AliyunMusicPickTabView.h
//  qusdk
//
//  Created by Worthy on 2017/6/26.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunMusicPickTabViewDelegate <NSObject>

- (void)didSelectTab:(NSInteger)tab;

@end

@interface AliyunMusicPickTabView : UIView
@property (nonatomic, weak) id<AliyunMusicPickTabViewDelegate> delegate;

@end
