//
//  AliyunRecordParamTableViewCell.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AliyunRecordParamCellModel;
@interface AliyunRecordParamTableViewCell : UITableViewCell

- (void)configureCellModel:(AliyunRecordParamCellModel *)cellModel;
@end


@interface AliyunRecordParamCellModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, copy) NSString *reuseId;
@property (nonatomic, assign) CGFloat defaultValue;
@property (nonatomic, copy) void(^valueBlock)(int value);
@property (nonatomic, copy) void(^sizeBlock)(CGFloat videoWidth);
@property (nonatomic, copy) void(^ratioBack)(CGFloat videoRatio);
@property (nonatomic, copy) void(^switchBlock)(BOOL open);
@end
