//
//  MWL_PhotoPreviewViewCell.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/13.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@class MWL_PhotoModel;

@interface MWL_PhotoPreviewViewCell : UICollectionViewCell

@property (strong, nonatomic) MWL_PhotoModel *model;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) NSInteger index;
@property (copy, nonatomic) void(^didPHBlock)(UICollectionViewCell *cell);
@property (assign, nonatomic) NSInteger maxNum;
@end
