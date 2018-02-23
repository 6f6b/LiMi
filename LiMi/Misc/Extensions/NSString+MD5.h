//
//  NSString+MD5.h
//  LiMi
//
//  Created by dev.liufeng on 2018/2/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
//#import <XLPhotoBrowser_CoderXL/XLPhotoBrowser.h>

@interface NSString (MD5)
- (NSString *) md5;
@end
