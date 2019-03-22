//
//  WLInterestLabelModel.h
//  welike
//
//  Created by luxing on 2018/6/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kInterestLabelLeftPadding                  8.0
#define kInterestLabelHeight                       32.0
#define kInterestLabelCorners                      16.0
#define kInterestLabelTitleFontSize                14.0
#define kInterestLabelSelectImageSize              16.0
#define kInterestLabelSelectPading                 12.0

#define kInterestLabelGroupLeftPading              12.0
#define kInterestLabelGroupTopPading               16.0
#define kInterestLabelViewPading                   8.0

#define kInterestLabelTitleColor                   kUIColorFromRGB(0x3B6393)
#define kInterestLabelFillColor                    kUIColorFromRGB(0xF2F5F8)

#define kInterestLabelIdKey                        @"id"
#define kInterestLabelTitleKey                     @"name"
#define kInterestLabelImageUrlKey                  @"icon"
#define kInterestLabelSelectedKey                  @"isDefault"
#define kInterestLabelSubLabelsKey                 @"subset"

@interface WLInterestLabelModel : NSObject

@property (nonatomic, copy) NSString *interestId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL folded;

@property (nonatomic, assign) CGRect labelFrame;
@property (nonatomic, assign) CGPoint nextOrigin;

- (void)refreshFrameWithOrigin:(CGPoint)origin width:(CGFloat)width;

- (void)refreshModelWithItem:(NSDictionary *)item;

+ (instancetype)modelWithItem:(NSDictionary *)item;

@end
