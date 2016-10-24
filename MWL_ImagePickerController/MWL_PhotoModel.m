//
//  MWL_PhotoModel.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/12.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MWL_PhotoModel.h"

@implementation MWL_PhotoModel

- (BOOL)ifSelect
{
    if (!_ifAdd) {
        return NO;
    }else {
        return YES;
    }
    return _ifSelect;
}

- (CGSize)imageSize
{
    if (_imageSize.width == 0 || _imageSize.height == 0) {
        _imageSize = [[_asset defaultRepresentation] dimensions];
    }
    return _imageSize;
}

- (NSString *)fileName
{
    if (!_fileName) {
        _fileName = [[_asset defaultRepresentation] filename];
    }
    return _fileName;
}

- (NSDictionary *)imageDic
{
    if (!_imageDic) {
        _imageDic = [[_asset defaultRepresentation] metadata];
    }
    return _imageDic;
}

- (NSString *)uti
{
    if (!_uti) {
        _uti = [[_asset defaultRepresentation] UTI];
    }
    return _uti;
}

- (NSURL *)url
{
    if (!_url) {
        _url = [[_asset defaultRepresentation] url];
    }
    return _url;
}

@end
