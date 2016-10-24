//
//  MWL_PhotosFooterView.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/14.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWL_PhotosFooterView : UICollectionReusableView
@property (assign, nonatomic) NSInteger total;
@property (weak, nonatomic) UILabel *label;
@end
