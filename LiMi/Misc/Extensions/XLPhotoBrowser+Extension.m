//
//  XLPhotoBrowser+Extension.m
//  LiMi
//
//  Created by dev.liufeng on 2018/2/6.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "XLPhotoBrowser+Extension.h"

@implementation XLPhotoBrowser (Extension)
- (void)setActionSheeWithDelegate:(id<XLPhotoBrowserDelegate>)delegate{
    [self setActionSheetWithTitle:nil delegate:delegate cancelButtonTitle:@"取消" deleteButtonTitle:nil otherButtonTitles:@"保存", nil];
}
@end
