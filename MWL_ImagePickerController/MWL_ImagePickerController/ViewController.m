//
//  ViewController.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/12.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "ViewController.h"

#import "MWL_AddPhotoView.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()<MWL_AddPhotoViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    self.view.backgroundColor = [UIColor brownColor];
    
    // 只选择照片
    MWL_AddPhotoView *addPhotoView = [[MWL_AddPhotoView alloc] initWithMaxPhotoNum:9 WithSelectType:SelectPhoto];
    addPhotoView.lineNum = 3;
    addPhotoView.delegate = self;
    addPhotoView.backgroundColor = [UIColor whiteColor];
    addPhotoView.frame = CGRectMake(5, 150, width - 10, 0);
    [self.view addSubview:addPhotoView];
    
    /**  当前选择的个数  */
    addPhotoView.selectNum;
    
    [addPhotoView setSelectPhotos:^(NSArray *photos, BOOL iforiginal) {
        NSLog(@"photo - %@",photos);
        [photos enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // 缩略图
                UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
            
            // 原图
                CGImageRef fullImage = [[asset defaultRepresentation] fullResolutionImage];
            
            // url
                NSURL *url = [[asset defaultRepresentation] url];
            
        }];
        
    }];
}
- (void)updateViewFrame:(CGRect)frame WithView:(UIView *)view
{
    [self.view layoutSubviews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
