//
//  MWL_AssetManager.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/12.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MWL_AssetManager.h"
#import "MWL_AlbumModel.h"

#define VERSION [[UIDevice currentDevice].systemVersion doubleValue]

@interface MWL_AssetManager ()
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSMutableArray *allAlbumAy;
@property (strong, nonatomic) NSMutableArray *allGroup;
@property (assign, nonatomic) BOOL ifTakingPictures;
@property (strong, nonatomic) MWL_PhotoModel *picturesModel;

@end

static MWL_AssetManager *sharedManager = nil;
static BOOL ifOne = YES;

@implementation MWL_AssetManager

+ (instancetype)sharedManager
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}
- (NSMutableArray *)selectedPhotos
{
    if (!_selectedPhotos) {
        _selectedPhotos = [NSMutableArray array];
    }
    
    return _selectedPhotos;
}

- (NSMutableArray *)recordPhotos
{
    if (!_recordPhotos) {
        _recordPhotos = [NSMutableArray array];
    }
    return _recordPhotos;
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}
#pragma mark - < 所有相册封面信息 >
- (NSMutableArray *)allAlbumAy
{
    if (!_allAlbumAy) {
        _allAlbumAy = [NSMutableArray array];
    }
    return _allAlbumAy;
}
#pragma mark - < 所有相册里的所有图片信息 >
- (NSMutableArray *)allGroup
{
    if (!_allGroup) {
        _allGroup = [NSMutableArray array];
    }
    return _allGroup;
}

#pragma mark - < 是否重新加载图片 >
- (void)setIfRefresh:(BOOL)ifRefresh
{
    _ifRefresh = ifRefresh;
    
    ifOne = ifRefresh;
}

#pragma mark - < 是否原图 >
- (BOOL)ifOriginal
{
    if (self.selectedPhotos.count == 0) {
        return NO;
    }
    return _ifOriginal;
}
/** 获取所有相册信息 */
- (void)getAllAlbumWithStart:(void (^)())start WithEnd:(void (^)(NSArray *, NSArray *))album WithFailure:(void (^)(NSError *))failure{
    if (start) {
        start();
    }
    if (ifOne) {
        [self.allAlbumAy removeAllObjects];
        [self.allGroup removeAllObjects];
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                if (self.type == MWL_SelectPhoto) {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                }else if (self.type == MWL_SelectVideo) {
                    [group setAssetsFilter:[ALAssetsFilter allVideos]];
                }else if (self.type == MWL_SelectPhotoAndVideo) {
                    [group setAssetsFilter:[ALAssetsFilter allAssets]];
                }
                
                if ([group numberOfAssets] != 0) {
                    MWL_AlbumModel *album = [[MWL_AlbumModel alloc] init];
                    album.coverImage = [UIImage imageWithCGImage:[group posterImage]];
                    album.group =group;
                    [self.allAlbumAy addObject:album];
                    NSMutableArray *ay = [NSMutableArray new];
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            MWL_PhotoModel *model = [[MWL_PhotoModel alloc] init];
                            model.tableViewIndex = self.allAlbumAy.count - 1;
                            
                            if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                                model.type = MWL_Photo;
                            }else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]){
                                model.type = MWL_Video;
                                NSTimeInterval duration = [[result valueForProperty:ALAssetPropertyDuration] integerValue];
                                NSString *timeLength = [NSString stringWithFormat:@"%0.0f",duration];
                                model.videoTime = [self getNewTimeFromDurationSecond:timeLength.integerValue];
                            }else if ([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeUnknown]) {
                                model.type = MWL_Unknown;
                            }
                            model.asset = result;
                            
                            [ay addObject:model];
                        }
                    }];
                     [self.allGroup addObject:ay];
                }
                for (int i = 0; i < self.allAlbumAy.count; i++) {
                    MWL_AlbumModel *model = self.allAlbumAy[i];
                    if ([model.albumName isEqualToString:@"相机胶卷"]) {
                        [self.allAlbumAy exchangeObjectAtIndex:i withObjectAtIndex:self.allAlbumAy.count - 1];
                        [self.allGroup exchangeObjectAtIndex:i withObjectAtIndex:self.allAlbumAy.count - 1];
                        
                    }
                }
                for (int i = 0; i < self.allGroup.count; i++) {
                    for (int k = 0; k < [self.allGroup[i] count]; k ++) {
                        MWL_PhotoModel *model = self.allGroup[i][k];
                        model.tableViewIndex = i;
                    }
                }
                self.GroupCount = self.allAlbumAy.count;
            }else{
                if (self.allAlbumAy.count > 0) {
                    if (album) {
                        album(self.allAlbumAy,self.allGroup);
                        ifOne = NO;
                    }
                }
            }
        } failureBlock:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
    }else {
        if (album) {
            album(self.allAlbumAy,self.allGroup);
        }
    }
}
#pragma mark - < 获取视频的大小 >
- (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"00:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"00:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

#pragma mark - < 图片大小 >
- (NSString *)totalBytes{
    return [self getPhotosBytesWithArray:self.selectedPhotos];
}
#pragma mark - < 获取一组图片的大小 >
- (NSString *)getPhotosBytesWithArray:(NSArray *)photos{
    __block NSInteger dataLength = 0;
    for (NSInteger i = 0; i < photos.count; i++) {
        MWL_PhotoModel *model = photos[i];
        ALAsset *asset = model.asset;
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        dataLength += (NSInteger)representation.size;
        if (i >= photos.count - 1) {
            
            NSString *bytes =[self getBytesFromDataLength:dataLength];
            return bytes;
        }
    }
    return @"";
}

#pragma mark - < 换算图片的大小 >
- (NSString *)getBytesFromDataLength:(NSInteger)length {
    if(length<1024)
        return [NSString stringWithFormat:@"%ldB",(long)length];
    else if(length>=1024&&length<1024*1024)
        return [NSString stringWithFormat:@"%.0fK",(float)length/1024];
    else if(length >=1024*1024&&length<1024*1024*1024)
        return [NSString stringWithFormat:@"%.1fM",(float)length/(1024*1024)];
    else
        return [NSString stringWithFormat:@"%.1fG",(float)length/(1024*1024*1024)];
}

- (void)savePhotoWithImage:(UIImage *)image completion:(void(^)()) completion WithError:(void(^)())error{
    [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error1) {
        if (error1) {
            if (error) {
                error();
            }
        }else{
            if (completion) {
                completion();
            }
        }
    }];
}

- (void)getJustTakePhotosWithCompletion:(void (^)(NSArray *array))completion
{
    _ifTakingPictures = YES;
    __block NSInteger tag = 0;
    NSMutableArray *array = [NSMutableArray array];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (self.type == MWL_SelectPhoto) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        }else if (self.type == MWL_SelectVideo) {
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
        }else if (self.type == MWL_SelectPhotoAndVideo) {
            [group setAssetsFilter:[ALAssetsFilter allAssets]];
        }
        if ([group numberOfAssets] > 0) {
            NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
            
            tag++;
            if ([name isEqualToString:@"Camera Roll"] || [name isEqualToString:@"相机胶卷"] || [name isEqualToString:@"所有照片"] || [name isEqualToString:@"All Photos"]) {
                
                MWL_AlbumModel *albumModel = self.allAlbumAy.lastObject;
                albumModel.photosNum = [group numberOfAssets];
                
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        MWL_PhotoModel *model = [[MWL_PhotoModel alloc] init];
                        model.collectionViewIndex = index;
                        model.asset = result;
                        model.tableViewIndex = tag -1;
                        [array addObject:model];
                    }
                }];
                self.picturesModel = array.lastObject;
                if (completion) completion(array);
                *stop = YES;
            }
        }
        
    } failureBlock:nil];
}
@end
