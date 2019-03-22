//
//  EditPhotoCollectionViewCell.h
//  CuctvWeibo
//
//  Created by cuctv-gyb on 17/2/23.
//
//

#import <UIKit/UIKit.h>
#import "WLAssetModel.h"

typedef void(^saveFinish)(WLAssetModel *asset);

@protocol WLEditPhotoCollectionViewCellDelegate <NSObject>

-(void)imageIsEditFinish;

@end


@interface WLEditPhotoCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) WLAssetModel *assetModel;
@property (strong, nonatomic) UIImage *signalImage;

@property (copy, nonatomic) void(^saveAndFinishEdit)(void);


@property (weak,nonatomic) id delegate;




- (void)cropImage;
- (void)adjustCutPhotoState;
- (void)adjustOriginPhotoState;

- (void)photoRotate;



-(void)saveAndFinish:(saveFinish)finishBlock;

@end
