//
//  MWL_AddPhotoViewCell.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/13.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWL_PhotoModel.h"
#import "MWL_AddPhotoView.h"
@interface MWL_AddPhotoViewCell : UICollectionViewCell

@property (weak, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) MWL_PhotoModel *model;
@property (copy, nonatomic) void(^deleteBlock)(UICollectionViewCell *cell);
@property (assign, nonatomic) SelectType type;
@end
