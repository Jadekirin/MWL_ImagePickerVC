//
//  MWL_PhotoViewController.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/13.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MWL_PhotoViewController.h"
#import "MWL_AssetContainerController.h"
#import <Photos/Photos.h>
#import "MWL_PhotoPreviewViewCell.h"
#import "MWL_AssetContainerViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MWL_AssetManager.h"
//#import "MWL_VideoContainerVC.h"
#import "MBProgressHUD.h"
#import "MWL_PhotosFooterView.h"

@interface MWL_PhotoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UIButton *previewBtn;//预览
@property (weak, nonatomic) UIButton *originalBtn;//原图
@property (weak, nonatomic) UIButton *confirmBtn;//确定
@end
static NSString *cellId = @"photoPreviewCell";
static NSString *cellFooterId = @"photoCellFooterId";

@implementation MWL_PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(closeAsset)];
    
    [self setup];
    
    // 改变选中状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectPhotoAy:) name:@"MWL_SelectPhotosNotica" object:nil];
}
#pragma mark - < 取消按钮 删除改变过的选择 >
- (void)closeAsset
{

    MWL_AssetManager *manager = [MWL_AssetManager sharedManager];
    if (!_ifVideo) {
        manager.ifOriginal = manager.recordOriginal;
        for (int i = 0; i < manager.selectedPhotos.count; i++) {
            MWL_PhotoModel *model = manager.selectedPhotos[i];
            model.ifAdd = NO;
            model.ifSelect = NO;
            model.index = i;
        }
        [manager.selectedPhotos removeAllObjects];
        
        for (int i = 0; i < manager.recordPhotos.count; i++) {
            MWL_PhotoModel *model = manager.recordPhotos[i];
            model.ifAdd = NO;
            model.ifSelect = NO;
        }
        [manager.recordPhotos removeAllObjects];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)setup{
    CGFloat width = self.view.frame.size.width;
    CGFloat heght = self.view.frame.size.height;
    
    NSInteger count = [MWL_AssetManager sharedManager].selectedPhotos.count;
    
    CGFloat CVwidth = (width - 15 ) / 4;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(CVwidth, CVwidth);
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.footerReferenceSize = CGSizeMake(width, 40);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 5, width, heght - 50) collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    [collectionView registerClass:[MWL_PhotoPreviewViewCell class] forCellWithReuseIdentifier:cellId];
    
    [collectionView registerClass:[MWL_PhotosFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:cellFooterId];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, heght - 45, width, 45)];
    
    [self.view addSubview:bottomView];
    
    UIButton *previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [previewBtn setTitleColor:[UIColor colorWithRed:18/255.0 green:183/255.0 blue:245/255.0 alpha:1] forState:UIControlStateNormal];
    [previewBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [previewBtn addTarget:self action:@selector(didPreviewClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:previewBtn];
    previewBtn.frame = CGRectMake(5, 0, 60, 45);
    _previewBtn = previewBtn;
    
    UIButton *originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [originalBtn setTitle:@"原图" forState:UIControlStateNormal];
    originalBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [originalBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [originalBtn setTitleColor:[UIColor colorWithRed:18/255.0 green:183/255.0 blue:245/255.0 alpha:1] forState:UIControlStateNormal];
    [originalBtn setImage:[UIImage imageNamed:@"activate_friends_not_seleted@2x.png"] forState:UIControlStateNormal];
    [originalBtn setImage:[UIImage imageNamed:@"activate_friends_seleted@2x.png"] forState:UIControlStateSelected];
    originalBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    [originalBtn addTarget:self action:@selector(didOriginalClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:originalBtn];
    originalBtn.frame = CGRectMake(65, 0, 200, 45);
    _originalBtn = originalBtn;
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [confirmBtn addTarget:self action:@selector(sureClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"login_bg@2x.png"] forState:UIControlStateDisabled];
    [confirmBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_blue_nor@2x.png"] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = 3;
    
    [bottomView addSubview:confirmBtn];
    confirmBtn.frame = CGRectMake(width - 70, 0, 60, 30);
    confirmBtn.center = CGPointMake(confirmBtn.center.x, 22.5);
    _confirmBtn = confirmBtn;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0.5)];
    line.backgroundColor = [UIColor lightGrayColor];
    [bottomView addSubview:line];
    if ([MWL_AssetManager sharedManager].type == MWL_SelectVideo) {
        bottomView.hidden = YES;
        collectionView.frame = CGRectMake(0, 5, width, heght - 10);
    }
    
    NSInteger row = _allPhotosArray.count / 4 + 1;
    
    CGFloat maxY = (row - 1) * 5 + row * CVwidth + 40;
    //滑动到最底部
    [collectionView setContentOffset:CGPointMake(0, maxY) animated:NO];
    //判断是否选的是视频
    if (!self.ifVideo) {
        for (int i = 0; i < [MWL_AssetManager sharedManager].selectedPhotos.count; i ++) {
            MWL_PhotoModel *modelPH = [MWL_AssetManager sharedManager].selectedPhotos[i];
            
            if (modelPH.tableViewIndex == _cellIndex) {
               // [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:modelPH.collectionViewIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                break;
            }
        }
    }else {
        bottomView.hidden = YES;
        collectionView.frame = CGRectMake(0, 5, width, heght - 10);
    }
    BOOL bl = count == 0 ? NO : YES;
    
    _previewBtn.enabled = bl;
    _originalBtn.enabled = bl;
    _confirmBtn.enabled = bl;
    if (count > 0) {
        [_confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",count] forState:UIControlStateNormal];
        _originalBtn.selected = [MWL_AssetManager sharedManager].ifOriginal;
        if ([MWL_AssetManager sharedManager].ifOriginal) {
            [_originalBtn setTitle:[NSString stringWithFormat:@"原图（%@）",[MWL_AssetManager sharedManager].totalBytes] forState:UIControlStateNormal];
        }
    }else {
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        _originalBtn.enabled = NO;
        _originalBtn.selected = NO;
    }

}

#pragma mark - < 确定 >
- (void)sureClick:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MWL_SureSelectPhotosNotice" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - < 是否原图 >
- (void)didOriginalClick:(UIButton *)button
{
    button.selected = !button.selected;
    [MWL_AssetManager sharedManager].ifOriginal = button.selected;
    
    if (button.selected) {
        [_originalBtn setTitle:[NSString stringWithFormat:@"原图(%@)",[MWL_AssetManager sharedManager].totalBytes] forState:UIControlStateNormal];
    }else{
        [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
    }
}
#pragma mark - < 预览 >
- (void)didPreviewClick:(UIButton *)button
{
    MWL_AssetContainerController *vc = [[MWL_AssetContainerController alloc] init];
    vc.ifPreview = NO;
    vc.photoAy = [MWL_AssetManager sharedManager].selectedPhotos;
    vc.maxNum = self.maxNum;
    [self.navigationController pushViewController:vc animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [vc setDidOriginalBlock:^{
        [self didOriginalClick:weakSelf.originalBtn];
    }];
}


#pragma mark - < 改变选中状态的通知 >
- (void)changeSelectPhotoAy:(NSNotification *)info
{
    MWL_AssetManager *manager = [MWL_AssetManager sharedManager];
    NSInteger index = [info.userInfo[@"index"] integerValue];
    BOOL ifSelect = [info.userInfo[@"ifSelect"] boolValue];
    
    if (!ifSelect) {
        if (index < manager.selectedPhotos.count) {
            [self.collectionView reloadData];
        }
    }
    //获取选择的图片数组
    NSArray *ay = manager.selectedPhotos;
    NSInteger count = ay.count;
    // 判断数组里面有没有内容
    BOOL bl = count == 0 ? NO : YES;
    
    _previewBtn.enabled = bl;
    _originalBtn.enabled = bl;
    _confirmBtn.enabled = bl;
    
    if (count > 0) {
        // 如果有内容就需要给底部的按钮重新复制
        [_confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",count] forState:UIControlStateNormal];
        
        
        _originalBtn.selected = manager.ifOriginal;
        
        // 判断是否点击了原图按钮
        if (manager.ifOriginal) {
            [_originalBtn setTitle:[NSString stringWithFormat:@"原图（%@）",[MWL_AssetManager sharedManager].totalBytes] forState:UIControlStateNormal];
        }
    }else {
        // 没有内容就初始化
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        _originalBtn.enabled = NO;
        _originalBtn.selected = NO;
    }
    
}


#pragma mark - CollectionDelagate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.allPhotosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MWL_PhotoPreviewViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.model = self.allPhotosArray[indexPath.row];
   // MWL_PhotoModel *Mode = [self.allPhotosArray lastObject];
    
    cell.maxNum = self.maxNum;
    cell.index = indexPath.row;
    
    __weak typeof(self) weakSelf = self;
    [cell setDidPHBlock:^(UICollectionViewCell *cell) {
        NSIndexPath *indexPt = [collectionView indexPathForCell:cell];
        
        MWL_PhotoModel *model = weakSelf.allPhotosArray[indexPt.row];
        
        
        if (model.type == MWL_Video) {
            
            
        }else {
            MWL_AssetContainerController *vc = [[MWL_AssetContainerController alloc] init];
            vc.photoAy = weakSelf.allPhotosArray;
            vc.currentIndex = indexPt.item;
            vc.maxNum = weakSelf.maxNum;
            
            [vc setDidOriginalBlock:^() {
                [weakSelf didOriginalClick:weakSelf.originalBtn];
            }];
            
            [vc setDidRgihtBtnBlock:^(NSInteger index) {
                [weakSelf.collectionView reloadData];
            }];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    }];
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        MWL_PhotosFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:cellFooterId forIndexPath:indexPath];
        footerView.total = self.allPhotosArray.count;
        return footerView;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
