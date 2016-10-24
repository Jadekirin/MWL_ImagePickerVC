//
//  MWL_AssetContainerController.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/19.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWL_AssetContainerController : UIViewController

@property (copy, nonatomic) NSArray *photoAy;
@property (assign, nonatomic) NSInteger currentIndex;
@property (assign, nonatomic) NSInteger maxNum;
@property (assign, nonatomic) BOOL ifPreview;

@property (copy, nonatomic) void(^didRgihtBtnBlock)(NSInteger index);
@property (copy, nonatomic) void(^didOriginalBlock)();
@property (assign, nonatomic) BOOL ifLookPic;//判断是查看还是预览

@end
