//
//  WLPostViewController.h
//  welike
//
//  Created by gyb on 2018/4/24.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNavBarBaseViewController.h"
#import "WLBasePostViewController.h"
#import <CoreLocation/CoreLocation.h>

@class WLTopicInfoModel;
@class WLLocationInfo;
@interface WLPostViewController : WLBasePostViewController<CLLocationManagerDelegate>
//{
//    UIButton *sendBtn;
//    UIButton *draftBtn;
//}

@property (strong,nonatomic) WLTopicInfoModel *topicInfo;

@property (strong,nonatomic) WLLocationInfo *locationInfo;


@end
