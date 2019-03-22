//
//  CKAlertViewController.h
//  自定义警告框
//
//  Created by 陈凯 on 16/8/24.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKAlertAction : NSObject

+ (instancetype)actionWithDeepColorTitle:(NSString *)title handler:(void (^)(CKAlertAction *action))handler;
+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(CKAlertAction *action))handler;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) BOOL isDeepColor;

@end


@interface CKAlertViewController : UIViewController

@property (nonatomic, readonly) NSArray<CKAlertAction *> *actions;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) NSTextAlignment messageAlignment;
@property (nonatomic, copy) NSMutableAttributedString *messageAttributedString;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSMutableAttributedString *)messageStr;

- (void)addAction:(CKAlertAction *)action;

-(void)show;

@end
