//
//  WLContactsManager.h
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLUser.h"

typedef void(^listAllContactsCompleted) (NSArray *contact);
typedef void(^listNewContactsCompleted) (NSArray *contact, NSInteger errCode);
typedef void(^listMoreContactsCompleted) (NSArray *contact, BOOL last, NSInteger errCode);

@interface WLContact : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, assign) WELIKE_USER_GENDER gender;
@property (nonatomic, assign) long long create;
@property (nonatomic, assign) long long atTime;
@property (nonatomic, assign) NSInteger vip;

@end

@interface WLContactsOnlineSearcher : NSObject

- (void)searchWithKeyword:(NSString *)keyword completed:(listMoreContactsCompleted)completed;
- (void)moreCompleted:(listMoreContactsCompleted)completed;

@end

@interface WLContactsManager : NSObject

- (void)prepare;
- (void)refreshAll;
- (void)refreshFromCursor:(NSString *)cursorStr;//在继续请求联系人时使用
- (void)listAllContacts:(listAllContactsCompleted)completed;
- (void)atContact:(WLContact *)contact;
- (void)addContact:(WLContact *)contact;
- (void)removeContactWithUid:(NSString *)uid;
- (WLContactsOnlineSearcher *)provideOnlineSearcher;

@end
