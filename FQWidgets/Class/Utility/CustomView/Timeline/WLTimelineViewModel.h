//
//  WLTimelineViewModel.h
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLFeedModel.h"

@interface WLTimelineViewModel : NSObject

@property (nonatomic, strong, readonly) NSArray *dataArray;

- (void)fetchListWithFinished:(void(^)(BOOL succeed, BOOL hasMore))finished;
- (void)fetchMoreWithFinished:(void(^)(BOOL succeed, BOOL hasMore))finished;

@end
