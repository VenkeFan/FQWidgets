//
//  FQImageBrowseView.h
//  WeLike
//
//  Created by fan qi on 2018/3/28.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQImageBrowseItemModel : NSObject

@property (nonatomic, weak) UIView *thumbView;
@property (nonatomic, copy) NSString *imgURL;

@end

@interface FQImageBrowseView : UIView

- (instancetype)initWithItemArray:(NSArray<FQImageBrowseItemModel *> *)itemArry;
- (instancetype)init __attribute__((unavailable("Use -initWithItemArray:instead")));
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Use -initWithItemArray:instead")));
+ (instancetype)new __attribute__((unavailable("Use -initWithItemArray:instead")));

- (void)displayWithFromView:(UIImageView *)fromView toView:(UIView *)toView;

@property (nonatomic, copy, readonly) NSArray<FQImageBrowseItemModel *> *itemArray;

@end
