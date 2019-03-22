//
//  WLCreatePostRequest.h
//  welike
//
//  Created by 刘斌 on 2018/5/4.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "RDBaseRequest.h"

@class WLRichContent;
@class RDLocation;

@interface WLRequestPostAttachment : NSObject

@property (nonatomic, copy) NSString *attId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *targetAttId;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

@end

@interface WLRequestPostPollAttachment : NSObject

@property (nonatomic, strong) WLRequestPostAttachment *requestPostAttachment;
@property (nonatomic, copy) NSString *choiceName;
@property (nonatomic, assign) long long time;


@end




typedef void(^createPostSuccessed)(NSDictionary *dic);

@interface WLCreatePostRequest : RDBaseRequest

- (id)initCreatePostRequestWithUid:(NSString *)uid;
- (void)createPostWithContent:(WLRichContent *)content location:(RDLocation *)location attachments:(NSArray *)attachments successed:(createPostSuccessed)successed error:(failedBlock)error;

@end
