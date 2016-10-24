//
//  MWL_AssetManager.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/12.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "MWL_PhotoModel.h"

typedef enum{
    MWL_SelectPhoto,
    MWL_SelectVideo,
    MWL_SelectPhotoAndVideo
}MWL_SelectType;
@interface MWL_AssetManager : NSObject


@property (assign, nonatomic) BOOL ifRefresh;

/**  用于记录的数组  */
@property (strong, nonatomic) NSMutableArray *recordPhotos;
@property (assign, nonatomic) BOOL recordOriginal;

@property (assign, nonatomic) MWL_SelectType type;

/**  已经添加的图片数组  */
@property (strong, nonatomic) NSMutableArray *selectedPhotos;

@property (assign, nonatomic) BOOL ifOriginal;

@property (copy, nonatomic) NSString *totalBytes;

@property (assign, nonatomic) NSInteger GroupCount;

+ (instancetype)sharedManager;
/**  获取所有相册信息  */
- (void)getAllAlbumWithStart:(void(^)())start WithEnd:(void(^)(NSArray *allAlbum,NSArray *photosAy))album WithFailure:(void(^)(NSError *error))failure;

- (void)savePhotoWithImage:(UIImage *)image completion:(void(^)()) completion WithError:(void(^)())error;
- (void)getJustTakePhotosWithCompletion:(void (^)(NSArray *array))completion;
@end
