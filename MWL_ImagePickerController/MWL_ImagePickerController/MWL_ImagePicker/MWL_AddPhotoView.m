//
//  MWL_AddPhotoView.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/12.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MWL_AddPhotoView.h"
#import "MBProgressHUD.h"
#import "MWL_AssetManager.h"
#import "MWL_PhotoModel.h"
#import "MWL_AddPhotoViewCell.h"
#import "MWL_VideoManager.h"
#import "MWL_AlbumViewController.h"
#import "MWL_AssetContainerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
@interface MWL_AddPhotoView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
//相片数组
@property (strong, nonatomic) NSMutableArray *photosAy;
@property (assign, nonatomic) NSInteger maxNum;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (assign, nonatomic) SelectType type;
@property (assign, nonatomic) BOOL ifVideo;
@property (strong, nonatomic) UIImagePickerController* imagePickerController;
@end


@implementation MWL_AddPhotoView

- (UICollectionViewFlowLayout *)flowLayout{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    return  _flowLayout;
}

- (instancetype)initWithMaxPhotoNum:(NSInteger)num WithSelectType:(SelectType)type{
    if (self = [super init]) {
        self.maxNum = num;
        self.type = type;
        MWL_AssetManager *manager = [MWL_AssetManager sharedManager];
        if (type == SelectPhoto) {
            manager.type = MWL_SelectPhoto;
        }else if (type == SelectVideo){
            self.maxNum = 1;
            self.ifVideo = 1;
            manager.type = MWL_SelectVideo;
        }else if (type == SelectPhotoAndVideo){
            manager.type = MWL_SelectPhotoAndVideo;
        }
        [self setup];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sureSelcetPhotos:) name:@"MWL_SureSelectPhotosNotice" object:nil];
    }
    return self;
}
- (NSMutableArray *)photosAy{
    if (!_photosAy) {
        _photosAy = [NSMutableArray array];
    }
    return _photosAy;
}

- (void)setup{
    if (self.lineNum == 0) {
        self.lineNum = 4;
    }
    MWL_PhotoModel *model = [[MWL_PhotoModel alloc] init];
    model.image = [UIImage imageNamed:@"tianjiatupian@2x.png"];
    model.ifSelect = NO;
    model.ifAdd = NO;
    model.type =MWL_Unknown;
    [self.photosAy addObject:model];
    
    MWL_PhotoModel *model2 = [[MWL_PhotoModel alloc] init];
    model2.type = MWL_Unknown;
    model2.ifAdd = NO;
    model2.ifSelect = NO;
    [self.photosAy addObject:model2];
    
    self.flowLayout.minimumLineSpacing = 5;
    self.flowLayout.minimumInteritemSpacing = 5;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 5, 0, 0) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = self.backgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self addSubview:self.collectionView];
    //_collectionView = collectionView;
    
    [self.collectionView registerClass:[MWL_AddPhotoViewCell class] forCellWithReuseIdentifier:@"cell"];
    
}
//展示图片
- (void)sureSelectPhotos:(NSNotification *)info{
    [self.photosAy removeAllObjects];
    MWL_AssetManager *assetmanager = [MWL_AssetManager sharedManager];
    MWL_VideoManager *videomanager = [MWL_VideoManager sharedManager];
    
    if (!self.ifVideo) {
        self.photosAy = [NSMutableArray arrayWithArray:assetmanager.selectedPhotos.mutableCopy];
        self.selectNum = assetmanager.selectedPhotos.count;
        NSMutableArray *array = [NSMutableArray new];
        //enumerateObjectsUsingBlock 相当于for in 循环
        [self.photosAy enumerateObjectsUsingBlock:^(MWL_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:model.asset];
        }];
        if (self.selectPhotos) {
            self.selectPhotos(array.mutableCopy,[MWL_AssetManager sharedManager].ifOriginal);
        }
        
    }else{
        self.photosAy = [NSMutableArray arrayWithArray:videomanager.selectedPhotos.mutableCopy];
        self.selectNum = videomanager.selectedPhotos.count;
        NSMutableArray *array = [NSMutableArray new];
        [self.photosAy enumerateObjectsUsingBlock:^(MWL_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [array addObject:model.asset];
        }];
        if (self.selectVideo) {
            self.selectVideo(array.mutableCopy);
        }
    }
    
    NSInteger count = self.photosAy.count;
    MWL_PhotoModel *model = self.photosAy.firstObject;
    if (model.type == MWL_Video) {
        ///
    }else{
        if (self.photosAy.count != self.maxNum) {
            MWL_PhotoModel *model = [[MWL_PhotoModel alloc] init];
            model.image = [UIImage imageNamed:@"tinajiatupian@2x.png"];
            model.ifSelect = NO;
            model.type = MWL_Unknown;
            [self.photosAy addObject:model];
        }
        if (count == 0) {
            MWL_PhotoModel *model2 = [[MWL_PhotoModel alloc] init];
            model.type = MWL_Unknown;
            [self.photosAy addObject:model2];
        }
    }
    [self setupNewFrame];
    [self.collectionView reloadData];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photosAy.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
         
    MWL_AddPhotoViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.model = self.photosAy[indexPath.item];
    cell.type = self.type;

    __weak typeof(self) weakSelf = self;
    [cell setDeleteBlock:^(UICollectionViewCell *cell) {
        MWL_AssetManager *assetmanager = [MWL_AssetManager sharedManager];
        MWL_VideoManager *videomanager = [MWL_VideoManager sharedManager];
        
        NSIndexPath *IndexP = [collectionView indexPathForCell:cell];
        [weakSelf.photosAy removeObjectAtIndex:IndexP.item];
        
        if (!_ifVideo) {
            if (assetmanager.selectedPhotos.count == 0) {
                return;
            }
            MWL_PhotoModel *model = assetmanager.selectedPhotos[IndexP.item];
            model.ifAdd = NO;
            model.ifSelect = NO;
            [assetmanager.selectedPhotos removeObjectAtIndex:IndexP.item];
            weakSelf.selectNum = assetmanager.selectedPhotos.count;
            
            if (assetmanager.selectedPhotos.count == 0) {
                assetmanager.ifOriginal = NO;
            }
            
            for (int i = 0; i < assetmanager.selectedPhotos.count; i++) {
                MWL_PhotoModel *model = assetmanager.selectedPhotos[i];
                model.index = i;
            }
            
            NSMutableArray *array = [NSMutableArray new];
            [assetmanager.selectedPhotos enumerateObjectsUsingBlock:^(MWL_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                [array addObject:model.asset];
            }];
            
            if (weakSelf.selectPhotos) {
                weakSelf.selectPhotos(array.mutableCopy,[MWL_AssetManager sharedManager].ifOriginal);
            }
            
        }else {
            [videomanager.selectedPhotos removeObjectAtIndex:IndexP.item];
            weakSelf.selectNum = videomanager.selectedPhotos.count;
            
            NSMutableArray *array = [NSMutableArray array];
            [videomanager.selectedPhotos enumerateObjectsUsingBlock:^(MWL_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                [array addObject:model.asset];
            }];
            if (weakSelf.selectVideo) {
                weakSelf.selectVideo(array.mutableCopy);
            }
        }
        
        [collectionView deleteItemsAtIndexPaths:@[IndexP]];
        
        if (!weakSelf.ifVideo) {
            NSInteger count = assetmanager.selectedPhotos.count;
            BOOL ifAdd = NO;
            for (int i = 0; i < weakSelf.photosAy.count; i ++) {
                MWL_PhotoModel *modeli = weakSelf.photosAy[i];
                if (!modeli.ifSelect) {
                    ifAdd = YES;
                }
            }
            
            if (weakSelf.photosAy.count != weakSelf.maxNum && !ifAdd) {
                MWL_PhotoModel *model1 = [[MWL_PhotoModel alloc] init];
                model1.image = [UIImage imageNamed:@"tianjiatupian@2x.png"];
                model1.ifSelect = NO;
                model1.ifAdd = NO;
                model1.type = MWL_Unknown;
                [weakSelf.photosAy addObject:model1];
            }
            
            if (count == 0) {
                MWL_PhotoModel *model2 = [[MWL_PhotoModel alloc] init];
                model2.ifSelect = NO;
                model2.ifAdd = NO;
                model2.type = MWL_Unknown;
                [weakSelf.photosAy addObject:model2];
            }
            [weakSelf setupNewFrame];
            [weakSelf.collectionView reloadData];
        }else {
            NSInteger count = videomanager.selectedPhotos.count;
            
            if (weakSelf.photosAy.count != weakSelf.maxNum) {
                MWL_PhotoModel *model1 = [[MWL_PhotoModel alloc] init];
                model1.image = [UIImage imageNamed:@"tianjiatupian@2x.png"];
                model1.ifSelect = NO;
                model1.ifAdd = NO;
                model1.type = MWL_Unknown;
                [weakSelf.photosAy addObject:model1];
            }
            
            if (count == 0) {
                MWL_PhotoModel *model2 = [[MWL_PhotoModel alloc] init];
                model2.ifSelect = NO;
                model2.ifAdd = NO;
                model2.type = MWL_Unknown;
                [weakSelf.photosAy addObject:model2];
            }
            [weakSelf setupNewFrame];
            [weakSelf.collectionView reloadData];
            
        }
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.photosAy.count == 0) {
        return;
    }
    MWL_PhotoModel *model = self.photosAy[indexPath.row];
    if (!self.ifVideo) {
        //如果不是纯视频
        if (model.type == MWL_Video) {
            //视频
        }
        if (model.type == MWL_Photo) {
            //查看相片
            MWL_AssetContainerController *vc = [[MWL_AssetContainerController alloc] init];
            vc.ifLookPic = YES;
            vc.photoAy = [MWL_AssetManager sharedManager].selectedPhotos;
            vc.currentIndex = indexPath.item;
            vc.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
            vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [[self viewController:self] presentViewController:vc animated:YES completion:nil];
            return;
        }
        //继续添加相片
        NSInteger count = [MWL_AssetManager sharedManager].selectedPhotos.count;
        if (self.photosAy.count == 2 && indexPath.item == 0 && count == 0) {
            [self SelectActionSheet];
            return;
        }
        if (self.photosAy.count <= self.maxNum && indexPath.item == self.photosAy.count - 1) {
            if (count == self.maxNum) return;
            [self SelectActionSheet];
        }
        
    }else{
        //是纯视频
        if (model.type == MWL_Video) {
            
        }
        NSInteger count = [MWL_VideoManager sharedManager].selectedPhotos.count;
        if (self.photosAy.count == 2 && indexPath.item == 0 && count == 0) {
            [self SelectActionSheet];
            return;
        }
    }
}

#pragma mark - 选择方式
- (void)SelectActionSheet{
    UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"从相册中选取", nil];
    [alert showInView:self];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
            // 判断是否支持相机
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS8Later) {
                // 无权限
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
                [alert show];
            } else {
                if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    // 跳转到相机或相册页面
                    self.imagePickerController = [[UIImagePickerController alloc] init];
                    self.imagePickerController.delegate = (id)self;
                    self.imagePickerController.allowsEditing = NO;
                    NSString *requiredMediaType = ( NSString *)kUTTypeImage;
                   // NSString *requiredMediaType1 = ( NSString *)kUTTypeMovie;
                    NSArray *arrMediaTypes;
                    if (self.type == SelectPhoto) {
                        arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType,nil];
                    }
                    [self.imagePickerController setMediaTypes:arrMediaTypes];
                    
                    
                    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    self.imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
                    
                    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
                        
                        self.imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
                        
                    }
                    
                    [[self viewController:self] presentViewController:self.imagePickerController animated:YES completion:NULL];
                }else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"模拟器不支持相机功能,请使用真机调试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    return;
                }
            }
    }else{
        [self goAddPhotoVC];
    }
}

#pragma mark - 相机回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.labelText = @"正在保存";
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        __weak typeof(self) weakSelf = self;
        [[MWL_AssetManager sharedManager] savePhotoWithImage:image completion:^{
            
            [[MWL_AssetManager sharedManager] getJustTakePhotosWithCompletion:^(NSArray *array) {
                MWL_PhotoModel *model = array.lastObject;
                model.ifAdd = YES;
                model.ifSelect = YES;
                model.type = MWL_Photo;
                model.image = image;
                model.tableViewIndex = [MWL_AssetManager sharedManager].GroupCount-1;
                [[MWL_AssetManager sharedManager].selectedPhotos addObject:model];
                [weakSelf sureSelcetPhotos:nil];
                UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                hud.customView = imageView;
                hud.labelText = @"保存成功";
                hud.mode = MBProgressHUDModeCustomView;
                [hud hide:YES afterDelay:1.f];
            }];
            
        } WithError:^{
            hud.labelFont = [UIFont systemFontOfSize:15.0];
            hud.labelText = @"保存失败";
            [hud hide:YES afterDelay:3.f];
        }];
        
    }
    
}

#pragma mark - 进入相册的展示
- (void)goAddPhotoVC{
    NSString *tipTextWhenNoPhotosAuthorization;//提示语
    //获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationAtatus = [ALAssetsLibrary authorizationStatus];
    //如果没有回去访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启
    if (authorizationAtatus == ALAuthorizationStatusRestricted || authorizationAtatus == ALAuthorizationStatusDenied) {
        tipTextWhenNoPhotosAuthorization = @"请在设备的\"设置-隐私-照片\"选项中，允许访问你的手机相册";
        //展示提示语
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        UIView *view = [[UIView alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_ar_failed@2x.png"]];
        [view addSubview:imageView];
        
        view.frame = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height + 10);
        
        hud.customView = view;
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = tipTextWhenNoPhotosAuthorization;
        hud.labelFont = [UIFont systemFontOfSize:12];
        hud.margin = 10.f;
    }
    
    MWL_AlbumViewController *photo = [[MWL_AlbumViewController alloc]init];
    photo.maxNum = self.maxNum;
    photo.ifVideo = self.ifVideo;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:photo];
    [[self viewController:self] presentViewController:nav animated:YES completion:nil];
    
}
// uiview 转化为 controller
- (UIViewController*)viewController:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)setupNewFrame{
    CGFloat width = self.frame.size.width;
    CGFloat x     = self.frame.origin.x;
    CGFloat y     = self.frame.origin.y;
    
    CGFloat itemW = ((width - 10)- 5*(self.lineNum - 1)) / self.lineNum;
    
    self.flowLayout.itemSize = CGSizeMake(itemW, itemW);
   // static NSInteger numofLinesOld = 1;
    NSInteger numOfLinesNews = (_photosAy.count/self.lineNum) + 1;
    if (_photosAy.count % _lineNum == 0) {
        numOfLinesNews -= 1;
    }
    
    if (numOfLinesNews == 1) {
        self.flowLayout.minimumLineSpacing = 0;
    }else{
        self.flowLayout.minimumLineSpacing = 5;
    }
    //if (numOfLinesNews != numofLinesOld) {
        CGFloat newHeight = numOfLinesNews * itemW + 5 *numOfLinesNews + 5;
        self.frame = CGRectMake(x, y, width, newHeight);
        if ([self.delegate respondsToSelector:@selector(updateViewFrame:WithView:)]) {
            [self.delegate updateViewFrame:self.frame WithView:self];
        }
    //}
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupNewFrame];
    
    if (self.photosAy.count == 2) {
        CGFloat width = self.frame.size.width;
        CGFloat itemW = ((width - 10) - 5 * (self.lineNum - 1)) / self.lineNum;
        self.bounds = CGRectMake(0, 0, width, itemW + 10);
    }
    NSInteger numOfLinesNew = (_photosAy.count / _lineNum) + 1;
    if (_photosAy.count % _lineNum == 0) {
        numOfLinesNew -= 1;
    }
    _collectionView.frame = CGRectMake(5, 5, self.frame.size.width - 10, self.frame.size.height - 10);
    
}

#pragma Mark 确定通知回调
-(void)sureSelcetPhotos:(NSNotification *)info{
    [self.photosAy removeAllObjects];
    MWL_AssetManager *assetManager = [MWL_AssetManager sharedManager];
    MWL_VideoManager *videoManager = [MWL_VideoManager sharedManager];
    
    if (!self.ifVideo) {
        self.photosAy = [NSMutableArray arrayWithArray:assetManager.selectedPhotos.mutableCopy];
        self.selectNum = assetManager.selectedPhotos.count;
        NSMutableArray *array = [NSMutableArray new];
        [self.photosAy enumerateObjectsUsingBlock:^(MWL_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:model.asset];
        }];
        if (self.selectPhotos) {
            self.selectPhotos(array.mutableCopy,[MWL_AssetManager sharedManager].ifOriginal);
        }
    }else{
        self.photosAy = [NSMutableArray arrayWithArray:videoManager.selectedPhotos.mutableCopy];
        self.selectNum = videoManager.selectedPhotos.count;
        
        NSMutableArray *array = [NSMutableArray array];
        [self.photosAy enumerateObjectsUsingBlock:^(MWL_PhotoModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [array addObject:model.asset];
        }];
        if (self.selectVideo) {
            self.selectVideo(array.mutableCopy);
        }
    }
    
    NSInteger count = self.photosAy.count;
    MWL_PhotoModel *model = self.photosAy.firstObject;
    
    if (model.type == MWL_Video) {
        
    }else{
        if (self.photosAy.count != self.maxNum) {
            MWL_PhotoModel *model = [[MWL_PhotoModel alloc] init];
            model.image = [UIImage imageNamed:@"tianjiatupian@2x.png"];
            model.ifSelect = NO;
            model.type = MWL_Unknown;
            [self.photosAy addObject:model];
        }
        
        if (count == 0) {
            MWL_PhotoModel *model2 =[[MWL_PhotoModel alloc] init];
            model.type = MWL_Unknown;
            [self.photosAy addObject:model2];
        }
    }
    [self setupNewFrame];
    [self.collectionView reloadData];
}

@end
