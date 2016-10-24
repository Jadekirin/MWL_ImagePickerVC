//
//  MWL_AlbumModel.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/12.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MWL_AlbumModel.h"
#import "MWL_AssetManager.h"
@implementation MWL_AlbumModel


- (NSInteger)photosNum{
    if (_photosNum == 0) {
        _photosNum = [_group numberOfAssets];
    }
    return _photosNum;
}

- (NSString *)albumName{
    if (!_albumName) {
        _albumName = [_group valueForProperty:ALAssetsGroupPropertyName];
        if ([_albumName isEqualToString:@"All Photos"]) {
            if ([MWL_AssetManager sharedManager].type == MWL_SelectVideo) {
                _albumName = @"所有视频";
            }else {
                _albumName = @"所有照片";
            }
        }else if ([_albumName isEqualToString:@"Camera Roll"]){
            _albumName = @"相机胶卷";
        }else if ([_albumName isEqualToString:@"My Photo Stream"]){
            _albumName = @"我的照片流";
        }
    }
    return _albumName;

}


@end
