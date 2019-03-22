//
//  WLDraftInfo.h
//  welike
//
//  Created by gyb on 2018/6/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLDraftBase;
@class WLHandledFeedModel;
@interface WLDraftInfo : NSObject

@property (strong,nonatomic) WLDraftBase *draftBase;
@property (strong,nonatomic) WLHandledFeedModel *handledFeedModel;
@property (assign,nonatomic) CGFloat cellHeight;



@end
