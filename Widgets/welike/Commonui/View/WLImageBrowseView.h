//
//  WLImageBrowseView.h
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WLPicInfo;

@interface FQImageBrowseItemModel : NSObject

@property (nonatomic, weak) UIImageView *thumbView;
@property (nonatomic, strong) WLPicInfo *imageInfo;
@property (nonatomic, copy) NSString *userName;

@end

@interface WLImageBrowseView : UIView

- (instancetype)init __attribute__((unavailable("Use -initWithItemArray:instead")));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Use -initWithItemArray:instead")));
+ (instancetype)new __attribute__((unavailable("Use -initWithItemArray:instead")));

@property (nonatomic, assign) BOOL useCache;

- (instancetype)initWithItemArray:(NSArray<FQImageBrowseItemModel *> *)itemArry;

- (void)displayWithFromView:(UIImageView *)fromView toView:(UIView *)toView;

- (void)displayWithFromBtn:(UIButton *)fromView toView:(UIView *)toView;


@end
