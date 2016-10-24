//
//  MWL_AssetContainerViewCell.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/19.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWL_PhotoModel.h"
#import <MediaPlayer/MediaPlayer.h>
@interface MWL_AssetContainerViewCell : UICollectionViewCell

@property (weak, nonatomic) UIButton *playBtn;

@property (strong, nonatomic) MPMoviePlayerController *player;
@property (strong,nonatomic) MWL_PhotoModel *model;
@property (nonatomic,copy) void(^didImgBlock)();

@end
