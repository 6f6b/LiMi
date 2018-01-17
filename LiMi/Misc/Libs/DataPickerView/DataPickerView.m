//
//  DataPickerView.m
//  XingYuan
//
//  Created by YunKuai on 2017/10/14.
//  Copyright © 2017年 Vicki. All rights reserved.
//

#import "DataPickerView.h"

@interface DataPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) void(^dataPickerBlock)(NSString *value);
@end

@implementation DataPickerView

+ (instancetype)pickerViewWithDataArray:(NSArray *)dataArray initialSelectRow:(NSInteger)row dataPickerBlock:(void (^)(NSString *value))block{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    DataPickerView *dataPickerView = [[DataPickerView alloc] initWithFrame:screenRect dataArray:dataArray initialSelectRow:row dataPickerBlock:block];
    return dataPickerView;
}

+ (instancetype)pickerViewWithDataArray:(NSArray *)dataArray initialValue:(id)value dataPickerBlock:(void (^)(NSString *))block{
    int initialRow = 0;
    for(int i=0;i<dataArray.count;i++){
        if([dataArray[i] isEqual:value]){
            initialRow = i;
            break;
        }
    }
    return [DataPickerView pickerViewWithDataArray:dataArray initialSelectRow:initialRow dataPickerBlock:block];
}


- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)dataArray initialSelectRow:(NSInteger)row dataPickerBlock:(void(^)(NSString *))block{
    if([super initWithFrame:frame]){
        self.dataArray = dataArray;
        
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:pickerView];
        [pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.pickerContainView);
            make.right.equalTo(self.pickerContainView);
            make.bottom.equalTo(self.pickerContainView);
            make.top.equalTo(self.pickerContainView);
        }];
        self.pickerView = pickerView;
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.dataPickerBlock = block;
        [self.pickerView selectRow:row inComponent:0 animated:true];
    }
    return self;
}

- (void)dealCancel{
    [super dealCancel];
    [self toDismiss];
}

- (void)dealOK{
    [super dealOK];
    if(self.dataPickerBlock != nil){
        self.dataPickerBlock(self.dataArray[[self.pickerView selectedRowInComponent:0]]);
    }
    [self toDismiss];
}

- (void)toDismiss{
    [self removeFromSuperview];
}

- (void)toShow{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

- (void)dealloc{
    
}

#pragma mark --UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.dataArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

@end
