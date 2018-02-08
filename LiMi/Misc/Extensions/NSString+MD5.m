//
//  NSString+MD5.m
//  LiMi
//
//  Created by dev.liufeng on 2018/2/5.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "NSString+MD5.h"

@implementation NSString (MD5)
- (NSString *) md5{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}
@end
