//
//  WLLocationFeedsProvider.h
//  welike
//
//  Created by gyb on 2018/6/1.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPostsProviderBase.h"
#import "WLFeedsProvider.h"

@interface WLLocationHotFeedsProvider : WLPostsProviderBase <WLFeedsProvider>

@property (nonatomic, copy) NSString *placeId;

@end
