//
//  MWL_VideoManager.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/13.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWL_VideoManager : NSObject

@property (assign, nonatomic) BOOL ifRefresh;

/**  已经添加的图片数组  */
@property (strong, nonatomic) NSMutableArray *selectedPhotos;

@property (copy, nonatomic) NSString *totalBytes;

+ (instancetype)sharedManager;

/**  获取所有相册信息  */
- (void)getAllAlbumWithStart:(void(^)())start WithEnd:(void(^)(NSArray *allAlbum,NSArray *photosAy))album WithFailure:(void(^)(NSError *error))failure;
@end
