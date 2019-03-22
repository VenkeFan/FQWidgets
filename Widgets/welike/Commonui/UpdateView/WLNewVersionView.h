//
//  WLNewVersionView.h
//  welike
//
//  Created by gyb on 2018/10/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WLNewVersionInfo;
@interface WLNewVersionView : UIView
{
    UIButton *cancelBtn;
    UIButton *confirmBtn;
    UITextView *infoTextView;
    UIImageView *dialogBg;
    
    UILabel *versionLabel;
}


@property (strong ,nonatomic) WLNewVersionInfo *versionInfo;

@end


