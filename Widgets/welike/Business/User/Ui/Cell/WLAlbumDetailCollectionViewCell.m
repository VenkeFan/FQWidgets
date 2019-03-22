//
//  WLAlbumDetailCollectionViewCell.m
//  welike
//
//  Created by fan qi on 2018/12/17.
//  Copyright © 2018 redefine. All rights reserved.
//

#import "WLAlbumDetailCollectionViewCell.h"
#import "WLAlbumPicModel.h"
#import "WLZoomScaleView.h"
#import "FLAnimatedImageView.h"
#import "WLAlertController.h"

@interface WLAlbumDetailCollectionViewCell () {
    BOOL _isPressed;
}

@property (nonatomic, strong) WLZoomScaleView *scaleView;
@property (nonatomic, strong) UILabel *txtLab;

@end

@implementation WLAlbumDetailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scaleView = [[WLZoomScaleView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_scaleView];
        
        _isPressed = NO;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self                                                                                   action:@selector(imgViewOnLongPressed)];
        [_scaleView addGestureRecognizer:longPress];
        
        _txtLab = [[UILabel alloc] init];
        _txtLab.textColor = [UIColor whiteColor];
        _txtLab.font = kRegularFont(kMediumNameFontSize);
        _txtLab.numberOfLines = 2;
        [self.contentView addSubview:_txtLab];
        [_txtLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView).offset(12);
            make.right.mas_equalTo(self.contentView).offset(-12);
            make.bottom.mas_equalTo(self.contentView).offset(-12 - kSafeAreaBottomY);
        }];
        
        _txtLab.userInteractionEnabled = YES;
        UITapGestureRecognizer *labTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(txtLabTapped)];
        [_txtLab addGestureRecognizer:labTap];
    }
    return self;
}

- (void)setCellModel:(WLAlbumPicModel *)cellModel {
    _cellModel = cellModel;
    
    [_scaleView setImageWithUrlString:cellModel.source
                          placeholder:cellModel.thumbImg
                            imageSize:CGSizeZero];
    _scaleView.userName = cellModel.userName;
    
    _txtLab.text = cellModel.postContent;
}

#pragma mark - Event

- (void)imgViewOnLongPressed {
    if (_isPressed) {
        return;
    }
    
    _isPressed = YES;
    
    WLAlertController *alert = [WLAlertController alertControllerWithTitle:[AppContext getStringForKey:@"picture_prompt" fileName:@"pic_sel"]
                                                                   message:[AppContext getStringForKey:@"picture_prompt_content" fileName:@"pic_sel"] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"picture_confirm" fileName:@"pic_sel"]
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                self->_isPressed = NO;
                                                [self.scaleView save];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:[AppContext getStringForKey:@"picture_cancel" fileName:@"pic_sel"]
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                self->_isPressed = NO;
                                            }]];
    
    [[AppContext currentViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)txtLabTapped {
    if ([self.delegate respondsToSelector:@selector(albumDetailCellDidTapped:)]) {
        [self.delegate albumDetailCellDidTapped:self];
    }
}

@end
