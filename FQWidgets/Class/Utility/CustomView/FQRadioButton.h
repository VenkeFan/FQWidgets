//
//  FQRadioButton.h
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FQRadioButton : UIButton

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
+ (instancetype)buttonWithType:(UIButtonType)buttonType UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGroupName:(NSString *)groupName;

@property (nonatomic, copy, readonly) NSString *groupName;

+ (void)clearRadioGroup;

@end
