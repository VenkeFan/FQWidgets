//
//  WLEmoticonCell.h
//  welike
//
//  Created by gyb on 2018/5/2.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLEmoticonCell : UICollectionViewCell

@property (nonatomic, copy) NSString *emoticonStr;
@property (nonatomic, assign) BOOL isDelete;
@property (nonatomic, strong) UIImageView *imageView;

@end
