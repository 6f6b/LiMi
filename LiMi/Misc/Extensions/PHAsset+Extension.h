//
//  PHAsset+Extension.h
//  LiMi
//
//  Created by dev.liufeng on 2018/1/31.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import <Photos/Photos.h>
typedef void(^Result)(NSData *fileData, NSString *fileName);

@interface PHAsset (Extension)
-  (void)getVideoComplete:(Result)result ;
@end
