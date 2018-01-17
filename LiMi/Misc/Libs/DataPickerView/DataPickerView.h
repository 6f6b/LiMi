//
//  DataPickerView.h
//  XingYuan
//
//  Created by YunKuai on 2017/10/14.
//  Copyright © 2017年 Vicki. All rights reserved.
//

#import "PickerView.h"
#import <Masonry/Masonry.h>

@interface DataPickerView : PickerView
@property (nonatomic,weak) UIPickerView *pickerView;

/**
 easy way to get a DataPickerView instance

 @param dataArray pickerView的数据源
 @param row 初始选定行
 @param block 点击确定的回调事件
 @return 返回一个DataPickerView实例
 */
+ (instancetype)pickerViewWithDataArray:(NSArray *)dataArray initialSelectRow:(NSInteger)row dataPickerBlock:(void (^)(NSString *))block;

+ (instancetype)pickerViewWithDataArray:(NSArray *)dataArray initialValue:(id)value dataPickerBlock:(void (^)(NSString *))block;
@end
