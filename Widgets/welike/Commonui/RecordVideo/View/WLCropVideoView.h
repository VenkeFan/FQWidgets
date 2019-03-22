//
//  WLCropVideoView.h
//  welike
//
//  Created by gyb on 2019/1/8.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLCropVideoView : UIView
{
    NSMutableArray *imagesArray;
    
    UICollectionView *collectionView;
    
    UILabel *durationLabel;
    
    UIImageView *imageViewLeft;
    UIImageView *imageViewRight;
    
    //剪切时长
//     UILabel *durationLabel;
}

@end

NS_ASSUME_NONNULL_END
