//
//  WLPostStatusBar.h
//  welike
//
//  Created by gyb on 2018/11/14.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WLPostStatusBarDelegate <NSObject>

-(void)emojiBtnPressed;
-(void)photoBtnPressed;
-(void)downloadBtnPressed;
-(void)sendBtnPressed;
@end

@interface WLPostStatusBar : UIView
{
    UIButton *emojiBtn;
    UIButton *photoBtn;
    UIButton *downloadBtn;
    
    UIButton *sendBtn;
}

@property (nonatomic, weak) id delegate;

-(void)enableSendeBtn;
-(void)disableSendBtn;

@end
