//
//  WLLargeBtnDataSourceItem.h
//  welike
//
//  Created by 刘斌 on 2018/4/23.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WLLargeBtnDataSourceItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign, readonly) CGFloat cellHeight;

@end
