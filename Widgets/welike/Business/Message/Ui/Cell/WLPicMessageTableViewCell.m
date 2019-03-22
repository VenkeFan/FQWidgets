//
//  WLPicMessageTableViewCell.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLPicMessageTableViewCell.h"
#import "WLAccountManager.h"
#import "UIImageView+WebCache.h"

@implementation WLPicMessageTableViewCell

- (void)bindBubbleImage
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    WLIMPicMessage *picMessage = (WLIMPicMessage *)self.message;
    NSURL *picUrl = nil;
    if (picMessage.localFileName.length > 0) {
        picUrl = [NSURL fileURLWithPath:picMessage.localFileName];
    } else {
        picUrl = [NSURL URLWithString:picMessage.picUri];
    }
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bubbleImageView.clipsToBounds = YES;
    if ([self.message.senderUid isEqualToString:account.uid] == YES) {
        [self.bubbleImageView sd_setImageWithURL:picUrl placeholderImage:[[AppContext getImageForKey:@"msg_send_bubble"] stretchableImageWithLeftCapWidth:10 topCapHeight:19] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image != nil) {
                [self.message.userInfo setObject:image forKey:MessageImageCacheKey];
            }
        }];
        [self changeImageView:self.bubbleImageView cornerStyle:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft];
    } else {
        [self.bubbleImageView sd_setImageWithURL:picUrl placeholderImage:[[AppContext getImageForKey:@"msg_receive_bubble"] stretchableImageWithLeftCapWidth:10 topCapHeight:19] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image != nil) {
                [self.message.userInfo setObject:image forKey:MessageImageCacheKey];
            }
        }];
        [self changeImageView:self.bubbleImageView cornerStyle:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight];
    }
}

- (void)layoutOtherView
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    if ([self.message.senderUid isEqualToString:account.uid] == YES) {
        [self changeImageView:self.bubbleImageView cornerStyle:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft];
    } else {
        [self changeImageView:self.bubbleImageView cornerStyle:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomRight];
    }
}

- (void)changeImageView:(UIView *)imageView cornerStyle:(UIRectCorner)style
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:imageView.bounds byRoundingCorners:style cornerRadii:CGSizeMake(14, 14)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = imageView.bounds;
    maskLayer.path = maskPath.CGPath;
    imageView.layer.mask = maskLayer;
}

@end
