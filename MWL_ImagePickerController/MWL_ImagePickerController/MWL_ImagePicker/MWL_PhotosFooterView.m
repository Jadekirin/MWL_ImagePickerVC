//
//  MWL_PhotosFooterView.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/14.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MWL_PhotosFooterView.h"
#import "MWL_AssetManager.h"
@implementation MWL_PhotosFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, 0, width, height);
    [self addSubview:label];
    _label = label;
}

- (void)setTotal:(NSInteger)total
{
    _total = total;
    
    NSString *str;
    if ([MWL_AssetManager sharedManager].type == MWL_SelectPhoto) {
        str = [NSString stringWithFormat:@"共%ld张图片",total];
    }else if ([MWL_AssetManager sharedManager].type == MWL_SelectVideo) {
        str = [NSString stringWithFormat:@"共%ld个视频",total];
    }else if ([MWL_AssetManager sharedManager].type == MWL_SelectPhotoAndVideo) {
        str = [NSString stringWithFormat:@"共%ld张图片、视频",total];
    }
    _label.text = str;
}


@end
