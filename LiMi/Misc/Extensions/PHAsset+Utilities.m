//
//  PHAsset+Utilities.m
//  LiMi
//
//  Created by dev.liufeng on 2018/3/20.
//  Copyright © 2018年 dev.liufeng. All rights reserved.
//

#import "PHAsset+Utilities.h"
@implementation PHAsset (Utilities)
- (void)getImageComplete:(Result)result {
    __block NSData *data;
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:self] firstObject];
    if (self.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:self
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             data = [NSData dataWithData:imageData];
         }];
    }
    
    if (result) {
        if (data.length <= 0) {
            result(nil, nil);
        } else {
            result(data, resource.originalFilename);
        }
    }
}

- (void)getVideoComplete:(Result)result{
    
}
@end
