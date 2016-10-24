//
//  MWL_AddPhotoView.h
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/12.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    SelectPhoto,
    SelectVideo,
    SelectPhotoAndVideo
}SelectType;

@protocol MWL_AddPhotoViewDelegate <NSObject>

@optional
- (void)updateViewFrame:(CGRect)frame WithView:(UIView *)view;

@end

@interface MWL_AddPhotoView : UIView
@property (assign, nonatomic) NSInteger lineNum;
@property (assign, nonatomic) NSInteger selectNum;
@property (copy, nonatomic) void(^selectPhotos)(NSArray *array,BOOL ifOriginal);
@property (copy, nonatomic) void(^selectVideo)(NSArray *array);

@property (weak, nonatomic) id <MWL_AddPhotoViewDelegate> delegate;

/**
 *  num : 最大限制
 *  type: 选择的类型
 */
- (instancetype)initWithMaxPhotoNum:(NSInteger)num WithSelectType:(SelectType)type;

@end
