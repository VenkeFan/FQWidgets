//
//  EditSinglePhotoView.h
//  CuctvWeibo
//
//  Created by cuctv-gyb on 17/2/22.
//
//

#import <UIKit/UIKit.h>

@interface WLEditSinglePhotoView : UICollectionView

@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) UIImage *signalImage;
@property (copy, nonatomic) void(^pageNumBlock)(int pageNum);



@end
