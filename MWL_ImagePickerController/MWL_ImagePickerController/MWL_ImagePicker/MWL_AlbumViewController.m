//
//  MWL_AlbumViewController.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/13.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MWL_AlbumViewController.h"
#import "MWL_PhotoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MWL_AssetManager.h"
#import "MWL_AlbumModel.h"
#import "MBProgressHUD.h"
#import "MWL_VideoManager.h"
@interface MWL_AlbumViewController ()
<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) UITableView *tableView;
//全部相册数组
@property (strong, nonatomic) NSMutableArray *allAlbumArray;
//全部照片数组
@property (strong, nonatomic) NSMutableArray *allImagesAy;
@end

@implementation MWL_AlbumViewController
- (NSMutableArray *)allAlbumArray
{
    if (!_allAlbumArray) {
        _allAlbumArray = [NSMutableArray array];
    }
    return _allAlbumArray;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectPhotoAy:) name:@"HX_SelectPhotosNotica" object:nil];
    [self setup];
    [self loadPhotos];
}

- (void)changeSelectPhotoAy:(NSNotification *)info
{
    NSInteger tableViewIndex = [info.userInfo[@"tableViewIndex"] integerValue];
    NSInteger collectionViewIndex = [info.userInfo[@"collectionViewIndex"] integerValue];
    BOOL ifSelect = [info.userInfo[@"ifSelect"] boolValue];
    NSArray * ay = self.allImagesAy[tableViewIndex];
    MWL_PhotoModel *model = ay[collectionViewIndex];
    model.ifSelect = ifSelect;
    
    [self.tableView reloadData];
}

- (void)loadPhotos{
    
    MWL_AssetManager *assetManager = [MWL_AssetManager sharedManager];
    MWL_VideoManager *videoManager = [MWL_VideoManager sharedManager];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    __weak typeof(self) weakSelf = self;
    if (!_ifVideo) {
        [assetManager getAllAlbumWithStart:^{
            
        } WithEnd:^(NSArray *allAlbum, NSArray *photosAy) {
            
            assetManager.recordOriginal = assetManager.ifOriginal;
            [assetManager.recordPhotos removeAllObjects];
            for (int i = 0; i < assetManager.selectedPhotos.count; i++) {
                MWL_PhotoModel *model = assetManager.selectedPhotos[i];
                [assetManager.recordPhotos addObject:model];
            }
            weakSelf.allAlbumArray = [NSMutableArray arrayWithArray:allAlbum];
            weakSelf.allImagesAy = [NSMutableArray arrayWithArray:photosAy];
            [weakSelf.tableView reloadData];
            
            if (assetManager.selectedPhotos.count == 0) {
                if (weakSelf.allImagesAy.count != 0) {
                    MWL_AlbumModel *model = [weakSelf.allAlbumArray lastObject];
                    MWL_PhotoViewController *vc = [[MWL_PhotoViewController alloc]init];
                    vc.allPhotosArray = [weakSelf.allImagesAy lastObject];
                    vc.maxNum = weakSelf.maxNum;
                    vc.cellIndex = weakSelf.allAlbumArray.count - 1;
                    vc.ifVideo = weakSelf.ifVideo;
                    vc.title = model.albumName;
                    [weakSelf.navigationController pushViewController:vc animated:NO];
                }
            }else{
                MWL_PhotoModel *model = assetManager.selectedPhotos.lastObject;
                MWL_AlbumModel *albumModel = weakSelf.allAlbumArray[model.tableViewIndex];
                MWL_PhotoViewController *vc = [[MWL_PhotoViewController alloc] init];
                vc.ifVideo = weakSelf.ifVideo;
                vc.title = albumModel.albumName;
                vc.allPhotosArray = weakSelf.allImagesAy[model.tableViewIndex];
                vc.maxNum = weakSelf.maxNum;
                vc.cellIndex = model.tableViewIndex;
                [weakSelf.navigationController pushViewController:vc animated:NO];
            }
            [hud hide:YES];
        } WithFailure:^(NSError *error) {
            hud.labelText = @"加载失败";
            [hud hide:YES afterDelay:0.25];
        }];
    }else{
    
        [videoManager getAllAlbumWithStart:^{
            
        } WithEnd:^(NSArray *allAlbum, NSArray *photosAy) {
            weakSelf.allAlbumArray = [NSMutableArray arrayWithArray:allAlbum];
            weakSelf.allImagesAy = [NSMutableArray arrayWithArray:photosAy];
            [weakSelf.tableView reloadData];
            
            if (videoManager.selectedPhotos.count == 0) {
                if (weakSelf.allImagesAy.count != 0) {
                    MWL_AlbumModel *model = [weakSelf.allAlbumArray lastObject];
                    MWL_PhotoViewController *vc = [[MWL_PhotoViewController alloc] init];
                    vc.ifVideo = self.ifVideo;
                    vc.title = model.albumName;
                    vc.allPhotosArray = [weakSelf.allImagesAy lastObject];
                    vc.maxNum = weakSelf.maxNum;
                    vc.cellIndex = weakSelf.allImagesAy.count - 1;
                    [weakSelf.navigationController pushViewController:vc animated:NO];
                }
            }else {
                MWL_PhotoModel *model = videoManager.selectedPhotos.lastObject;
                MWL_AlbumModel *albumModel = weakSelf.allAlbumArray[model.tableViewIndex];
                MWL_PhotoViewController *vc = [[MWL_PhotoViewController alloc] init];
                vc.ifVideo = self.ifVideo;
                vc.title = albumModel.albumName;
                vc.allPhotosArray = weakSelf.allImagesAy[model.tableViewIndex];
                vc.maxNum = weakSelf.maxNum;
                vc.cellIndex = model.tableViewIndex;
                [weakSelf.navigationController pushViewController:vc animated:NO];
            }
            [hud hide:YES];
        } WithFailure:^(NSError *error) {
            hud.labelText = @"加载失败";
            [hud hide:YES afterDelay:0.25];
        }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
    self.title = @"相册";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeVC)];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:18/255.0 green:183/255.0 blue:245/255.0 alpha:1]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    _tableView = tableView;
    [tableView registerClass:[MWL_TableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allAlbumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MWL_TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    MWL_AlbumModel *model = self.allAlbumArray[indexPath.row];
    
    cell.model = model;
    
    NSArray *ay = [MWL_AssetManager sharedManager].selectedPhotos;
    
    NSInteger count = 0;
    for (int i = 0; i < ay.count; i++) {
        MWL_PhotoModel *model = ay[i];
        if (model.tableViewIndex == indexPath.row) {
            count++;
        }
    }
    cell.count = count;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MWL_AlbumModel *model = self.allAlbumArray[indexPath.row];
    MWL_PhotoViewController *vc = [[MWL_PhotoViewController alloc] init];
    vc.title = model.albumName;
    vc.allPhotosArray = self.allImagesAy[indexPath.row];
    vc.maxNum = self.maxNum;
    vc.cellIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - < 关闭按钮 清空选中数组中的内容 >
- (void)closeVC
{
    MWL_AssetManager *manager = [MWL_AssetManager sharedManager];
    
    manager.ifOriginal = manager.recordOriginal;
    
    for (int i = 0 ; i < manager.selectedPhotos.count; i++) {
        MWL_PhotoModel *model = manager.selectedPhotos[i];
        model.ifAdd = NO;
        model.ifSelect = NO;
    }
    [manager.selectedPhotos removeAllObjects];
    
    for (int i = 0 ; i < manager.recordPhotos.count; i++) {
        MWL_PhotoModel *model = manager.recordPhotos[i];
        model.ifAdd = YES;
        model.ifSelect = YES;
        [manager.selectedPhotos addObject:model];
    }
    [manager.recordPhotos removeAllObjects];
    
    for (int i = 0 ; i < manager.selectedPhotos.count; i++) {
        MWL_PhotoModel *model = manager.selectedPhotos[i];
        model.index = i;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface MWL_TableViewCell ()
@property (weak, nonatomic) UIImageView *photoView;
@property (weak, nonatomic) UILabel *photoNameLb;
@property (weak, nonatomic) UILabel *photoNumLb;
@property (weak, nonatomic) UIButton *selectIcon;
@end


@implementation MWL_TableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat height = 62;
    CGFloat width = self.frame.size.width;
    
    UIImageView *photoView = [[UIImageView alloc] init];
    photoView.frame = CGRectMake(15, 1.5, 60, 60);
    photoView.contentMode = UIViewContentModeScaleAspectFill;
    photoView.clipsToBounds = YES;
    [self.contentView addSubview:photoView];
    _photoView = photoView;
    
    UILabel *photoNameLb = [[UILabel alloc] init];
    photoNameLb.textColor = [UIColor blackColor];
    photoNameLb.font = [UIFont boldSystemFontOfSize:15];
    [self.contentView addSubview:photoNameLb];
    _photoNameLb = photoNameLb;
    
    UILabel *photoNumLb = [[UILabel alloc] init];
    photoNumLb.textColor = [UIColor lightGrayColor];
    photoNumLb.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:photoNumLb];
    _photoNumLb = photoNumLb;
    
    UIButton *selectIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectIcon setBackgroundImage:[UIImage imageNamed:@"album_checkbox_blue@2x.png"] forState:UIControlStateNormal];
    selectIcon.titleLabel.font = [UIFont systemFontOfSize:14];
    selectIcon.frame = CGRectMake(width, 0, selectIcon.currentBackgroundImage.size.width, selectIcon.currentBackgroundImage.size.height);
    selectIcon.center = CGPointMake(selectIcon.center.x, 31);
    [self.contentView addSubview:selectIcon];
    _selectIcon = selectIcon;
    
    UILabel *line = [[UILabel alloc] init];
    line.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
    [self.contentView addSubview:line];
    line.frame = CGRectMake(85, height - 0.5, width, 0.5);
}

-(void)setModel:(MWL_AlbumModel *)model
{
    _model = model;
    
    CGFloat height = 62;
    
    NSString *photoName = model.albumName;
    
    CGFloat width = [photoName boundingRectWithSize:CGSizeMake(200, 20) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : _photoNameLb.font} context:nil].size.width;
    
    _photoNameLb.text = photoName;
    
    _photoNameLb.frame = CGRectMake(85, 0, width, 20);
    
    _photoNameLb.center = CGPointMake(_photoNameLb.center.x, height / 2);
    
    CGFloat photoNameMaxX = CGRectGetMaxX(_photoNameLb.frame);
    
    _photoNumLb.text = [NSString stringWithFormat:@"(%ld)",(long)model.photosNum];
    _photoNumLb.frame = CGRectMake(photoNameMaxX + 10, 0, 100, 20);
    _photoNumLb.center = CGPointMake(_photoNumLb.center.x, height / 2);
    
    _photoView.image = model.coverImage;
}

- (void)setCount:(NSInteger)count
{
    _count = count;
    
    if (count == 0) {
        _selectIcon.hidden = YES;
    }else {
        _selectIcon.hidden = NO;
        [_selectIcon setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
    }
}


@end
