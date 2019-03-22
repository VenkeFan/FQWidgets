//
//  WLSearchTopicViewController.h
//  welike
//
//  Created by gyb on 2018/5/22.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseViewController.h"

@class WLTopicInfoModel;
@interface WLSearchTopicViewController : RDBaseViewController


@property (strong,nonatomic) NSString  *legalSearchKey;

@property (nonatomic,copy) void(^select)(WLTopicInfoModel *topicInfo);


-(void)research;

@end
