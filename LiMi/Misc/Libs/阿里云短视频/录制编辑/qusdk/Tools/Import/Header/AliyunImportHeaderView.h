//
//  AliyunImportHeaderView.h
//  AliyunVideo
//
//  Created by Worthy on 2017/3/8.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunImportHeaderViewDelegate <NSObject>
- (void)headerViewDidSelect;
- (void)headerViewDidCancel;
@end

@interface AliyunImportHeaderView : UIView

@property (nonatomic, weak) id<AliyunImportHeaderViewDelegate> delegate;
@property (nonatomic, strong) NSString *title;

@end
