//
//  MWL_AlbumModel.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/12.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface MWL_AlbumModel : NSObject
/**  封面图  */
@property (strong, nonatomic) UIImage *coverImage;
/**  相册名称  */
@property (copy, nonatomic) NSString *albumName;
/**  相册内容数量  */
@property (assign, nonatomic) NSInteger photosNum;

@property (strong, nonatomic) ALAssetsGroup *group;
@end
