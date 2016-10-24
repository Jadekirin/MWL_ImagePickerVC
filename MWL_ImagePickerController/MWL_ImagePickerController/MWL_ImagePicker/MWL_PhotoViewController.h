//
//  MWL_PhotoViewController.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/13.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWL_PhotoViewController : UIViewController

@property (assign, nonatomic) BOOL ifVideo;
@property (strong, nonatomic) NSMutableArray *allPhotosArray;
@property (assign, nonatomic) NSInteger cellIndex;
@property (assign, nonatomic) NSInteger maxNum;
@end
