//
//  WLAppInfoManager.h
//  welike
//
//  Created by gyb on 2018/10/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^appInfoCompleted) (NSDictionary *infoDic, NSInteger errCode);


@interface WLAppInfoManager : NSObject

-(void)appInfo:(appInfoCompleted)complete;

@end
