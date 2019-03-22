//
//  WLCommentLayout.m
//  welike
//
//  Created by fan qi on 2018/5/11.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLCommentLayout.h"
#import "WLRichTextHelper.h"
#import "NSDate+LuuBase.h"

@implementation WLCommentLayout

- (instancetype)initWithComment:(WLComment *)comment {
    if (self = [super init]) {
        _commentModel = comment;
        
        [self handleRichComment:comment];
        [self p_layoutComment:comment];
    }
    return self;
}

- (void)handleRichComment:(WLComment *)comment {
    if (comment.content != nil) {
        self.handledFeedModel = [[WLHandledFeedModel alloc] init];
         self.handledFeedModel.font = commentBodyFont;
         self.handledFeedModel.renderWidth = commentContentWidth - commentPaddingX * 2;
         self.handledFeedModel.lineBreakMode = NSLineBreakByCharWrapping;
        self.handledFeedModel.maxLineNum = 2;
        self.handledFeedModel.textColor = kBodyFontColor;
        [ self.handledFeedModel handleRichModel:comment.content];
        
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:comment.children.count];
    for (int i = 0; i < comment.children.count; i++) {
        WLComment *child = comment.children[i];
        WLRichContent *newContent = [WLRichTextHelper mergeContentWithName:child.nickName content:child.content];
        
        WLHandledFeedModel *handleModel = [[WLHandledFeedModel alloc] init];
        handleModel.font = commentChildBodyFont;
        handleModel.renderWidth = commentContentWidth - commentPaddingX * 2;
        handleModel.lineBreakMode = NSLineBreakByCharWrapping;
        handleModel.rangeOfSpecial = NSMakeRange(0, child.nickName.length);
        handleModel.textColor = kBodyFontColor;
        [handleModel handleRichModel:newContent];
      
        [array addObject:handleModel];
    }
    self.childrenHandledFeedModels = array;
}

#pragma mark - Layout

- (void)p_layoutComment:(WLComment *)comment {
    CGFloat x = commentPaddingLeft;
    CGFloat y = commentPaddingTop;
    
    self.avatarFrame = CGRectMake(commentPaddingLeft, commentPaddingTop, commentAvatarSize, commentAvatarSize);
    x += (commentAvatarSize + commentPaddingX);
    y += 2;
    
    CGFloat nameHeight = [comment.nickName boundingRectWithSize:CGSizeMake(commentContentWidth, commentAvatarSize)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName: commentNameFont}
                                                        context:nil].size.height;
    CGRect nameFrame = CGRectMake(x, y, commentContentWidth, nameHeight);
    self.nameFrame = nameFrame;
    y += (nameHeight + 2);
    
    self.textFrame = CGRectMake(x, y, commentContentWidth, self.handledFeedModel.richTextHeight);
    y += (self.textFrame.size.height + commentPaddingY);
    
    if (comment.children.count > 0) {
        CGFloat childrenContentHeight = [self p_layoutChildrenContentHeight:comment.children];
        self.childContentFrame = CGRectMake(x, y, commentContentWidth, childrenContentHeight);
        y += (childrenContentHeight + commentPaddingY);
    }
    
    self.toolBarTop = y;
    y += commentToolBarHeight;
    
    self.timeString = [NSDate commentTimeStringFromTimestamp:comment.time];
    
    y += commentLineHeight;
    
    self.cellHeight = y;
}

- (CGFloat)p_layoutChildrenContentHeight:(NSArray *)children {
    CGFloat height = 0;
    
    for (int i = 0; i < children.count; i++) {
        if (i >= self.childrenHandledFeedModels.count) {
            break;
        }
        WLHandledFeedModel *childHandleModel = self.childrenHandledFeedModels[i];
        height += (commentPaddingY + childHandleModel.richTextHeight);
    }
    height > 0 ? height += commentPaddingY : 0;
    
    return height;
}

@end
