//
//  WLRegisterSelectLanguageViewController.h
//  welike
//
//  Created by 刘斌 on 2018/4/14.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseViewController.h"

@interface WLRegisterSelectLanguageViewController : RDBaseViewController

@end



@interface WLRegisterProtocolLinkView : UITextView

@property (nonatomic, readonly) CGFloat protocolWidth;

- (id)initWithWidth:(CGFloat)width;

@end
