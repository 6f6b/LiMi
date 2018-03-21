//
//  PHAsset+Utilities.h
//  LiMi
//
//  Created by dev.liufeng on 2018/3/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (Utilities)
typedef void(^Result)(NSData *fileData, NSString *fileName);
- (void)getImageComplete:(Result)result;
- (void)getVideoComplete:(Result)result;
@end
