//
//  MWL_AlbumViewController.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/13.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWL_AlbumModel.h"
@interface MWL_AlbumViewController : UIViewController

@property (assign, nonatomic) BOOL ifVideo;
@property (assign, nonatomic) NSInteger maxNum;

@end


@interface MWL_TableViewCell : UITableViewCell

@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) UIImage *photoImg;
@property (copy, nonatomic) NSString *photoName;
@property (assign, nonatomic) NSInteger photoNum;
@property (strong, nonatomic) MWL_AlbumModel *model;
@end