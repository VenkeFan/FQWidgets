//
//  WLPostAttachmentUploadTransDelegate.h
//  welike
//
//  Created by 刘斌 on 2018/5/9.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLPostAttachmentUploadTransDelegate <NSObject>

- (void)onPostAttachment:(NSString *)attachmentId process:(CGFloat)process;
- (void)onPostAttachmentCompleted:(NSString *)attachmentId;
- (void)onPostAttachmentFailed:(NSString *)attachmentId;

@end
