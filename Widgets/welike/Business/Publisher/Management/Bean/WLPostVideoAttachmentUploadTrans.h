//
//  WLPostVideoAttachmentUploadTrans.h
//  welike
//
//  Created by 刘斌 on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLDraft.h"
#import "WLPostAttachmentUploadTransDelegate.h"

@interface WLPostVideoAttachmentUploadTrans : NSObject

@property (nonatomic, weak) id<WLPostAttachmentUploadTransDelegate> delegate;

- (id)initWithDraft:(WLAttachmentDraft *)attachmentDraft fileName:(NSString *)fileName;
- (void)start;

@end
