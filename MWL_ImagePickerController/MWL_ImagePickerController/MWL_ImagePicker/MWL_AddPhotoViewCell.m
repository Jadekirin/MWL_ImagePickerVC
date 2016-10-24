//
//  MWL_AddPhotoViewCell.m
//  MWL_ImagePickerController
//
//  Created by maweilong-PC on 16/9/13.
//  Copyright © 2016年 maweilong. All rights reserved.
//

#import "MWL_AddPhotoViewCell.h"
#import "MWL_AssetManager.h"

@interface MWL_AddPhotoViewCell ()
@property (weak, nonatomic) UIButton *deleteBtn;
@property (weak, nonatomic) UIImageView *videoIcon;
@property (weak, nonatomic) UILabel *videoTime;
@property (weak, nonatomic) UIView *videoBgView;
@property (weak, nonatomic) UILabel *label;

@end

@implementation MWL_AddPhotoViewCell
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
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = CGRectMake(0, 0, width, height);
    [self.contentView addSubview:imageView];
    _imageView = imageView;
    
    UIView *videoBgView = [[UIView alloc] init];
    videoBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    videoBgView.frame = CGRectMake(0, height - 20, width, 20);
    [self.contentView addSubview:videoBgView];
    _videoBgView = videoBgView;
    
    UIImageView *videoIcon = [[UIImageView alloc] init];
    videoIcon.image = [UIImage imageNamed:@"VideoSendIcon@2x.png"];
    videoIcon.frame = CGRectMake(5, 0, videoIcon.image.size.width, videoIcon.image.size.width);
    videoIcon.center = CGPointMake(videoIcon.center.x, 10);
    [videoBgView addSubview:videoIcon];
    _videoIcon = videoIcon;
    
    UILabel *videoTime = [[UILabel alloc] init];
    videoTime.textAlignment = NSTextAlignmentRight;
    videoTime.font = [UIFont systemFontOfSize:12];
    videoTime.textColor = [UIColor whiteColor];
    
    CGFloat videoIconMaxX = CGRectGetMaxX(videoIcon.frame);
    videoTime.frame = CGRectMake(videoIconMaxX, 0, width - videoIconMaxX - 5, 20);
    
    [videoBgView addSubview:videoTime];
    _videoTime = videoTime;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setBackgroundImage:[UIImage imageNamed:@"back_single@2x.png"] forState:UIControlStateNormal];
    deleteBtn.frame = CGRectMake(width - 27, 2, 25, 25);
    deleteBtn.hidden = YES;
    [deleteBtn addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:deleteBtn];
    _deleteBtn = deleteBtn;
    
    UILabel *label = [[UILabel alloc] init];
    
    label.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
    label.font = [UIFont systemFontOfSize:15];
    label.frame = CGRectMake(10, 0, 200, 20);
    label.center = CGPointMake(label.center.x, height / 2);
    [self.contentView addSubview:label];
    
    MWL_AssetManager *manger = [MWL_AssetManager sharedManager];
    
    if (manger.type == MWL_SelectPhoto) {
        label.text = @"添加照片";
    }else if (manger.type == MWL_SelectVideo) {
        label.text = @"添加视频";
    }else if (manger.type == MWL_SelectPhotoAndVideo) {
        label.text = @"添加照片、视频";
    }
    
    _label = label;
}

- (void)setType:(SelectType)type
{
    _type = type;
    if (type == 0) {
        _label.text = @"添加照片";
    }else if (type == 1) {
        _label.text = @"添加视频";
    }else if (type == 2) {
        _label.text = @"添加照片、视频";
    }
}

- (void)deleteClick:(UIButton *)button
{
    if (self.deleteBlock) {
        self.deleteBlock(self);
    }
}

- (void)setModel:(MWL_PhotoModel *)model
{
    _model = model;
    
    if (!model.image) {
        _label.hidden = NO;
        _videoBgView.hidden = YES;
        _imageView.hidden = YES;
        _deleteBtn.hidden = YES;
    }else {
        if (model.type == MWL_Video) {
            _videoBgView.hidden = NO;
            _deleteBtn.hidden = NO;
            _videoTime.text = model.videoTime;
        }else {
            _videoBgView.hidden = YES;
            _deleteBtn.hidden = !model.ifSelect;
        }
        _label.hidden = YES;
        _imageView.image = model.image;
        _imageView.hidden = NO;
    }
}
@end
