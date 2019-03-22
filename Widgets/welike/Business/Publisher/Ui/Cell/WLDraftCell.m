//
//  WLDraftCell.m
//  welike
//
//  Created by gyb on 2018/6/5.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDraftCell.h"
#import "WLDraftInfo.h"
#import "WLDraft.h"
#import "TYLabel.h"
#import "WLHandledFeedModel.h"
#import "WLPublishCardView.h"
#import "WLImageHelper.h"
#import "WLPublishTaskManager.h"

@implementation WLDraftCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        richLabel = [[TYLabel alloc] initWithFrame:CGRectMake(15, 5, kScreenWidth - 30 - 10 - 56, 0)];
        richLabel.textColor = kDraftRichTextColor;
        richLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//        richLabel.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:richLabel];
        
        thumbView = [[UIImageView alloc] initWithFrame:CGRectZero];
        thumbView.backgroundColor = kDefaultThumbBgColor;
        thumbView.contentMode =  UIViewContentModeScaleAspectFill;
        thumbView.clipsToBounds =  YES;
        [self.contentView addSubview:thumbView];
        
        playFlag = [[UIImageView alloc] initWithFrame:CGRectZero];
        playFlag.image = [AppContext getImageForKey:@"common_play"];
        [thumbView addSubview:playFlag];
        
        
        publishCardView = [[WLPublishCardView alloc] initWithFrame:CGRectZero];
        publishCardView.backgroundColor = [UIColor whiteColor];
        publishCardView.layer.borderColor = postCardFrameColor.CGColor;
        publishCardView.layer.borderWidth = 0.5;
        publishCardView.layer.cornerRadius = 3;
        publishCardView.clipsToBounds = YES;
        [self.contentView addSubview:publishCardView];
        publishCardView.hidden = YES;
        
        
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.textColor = kDateTimeFontColor;
        timeLabel.numberOfLines = 1;
        timeLabel.font = kRegularFont(12);
        timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:timeLabel];
        
        resendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        resendBtn.frame =  CGRectMake(kScreenWidth - 15 - 56, 6, 56, 24);
        resendBtn.showsTouchWhenHighlighted = YES;
        [resendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [resendBtn setTitle:[AppContext getStringForKey:@"editor_resend_btn" fileName:@"publish"] forState:UIControlStateNormal];
        resendBtn.backgroundColor = kMainColor;
        resendBtn.titleLabel.font = kBoldFont(12);
        resendBtn.layer.cornerRadius = 12;
        [resendBtn addTarget:self action:@selector(sendBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        resendBtn.adjustsImageWhenDisabled = NO;
        [self addSubview:resendBtn];
        
        lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.backgroundColor = kSeparateLineColor;
        [self addSubview:lineView];
        
    }
    return self;
}



-(void)setDraftInfo:(WLDraftInfo *)draftInfo
{
    _draftInfo = draftInfo;
    

   lineView.frame = CGRectMake(13, _draftInfo.cellHeight - 0.5, kScreenWidth - 13, 0.5);
    
    if (_draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_POST)
    {
        WLPostDraft *postDraft = (WLPostDraft *)_draftInfo.draftBase;

        richLabel.height = _draftInfo.handledFeedModel.textRender.textBound.size.height;
        timeLabel.text = [NSDate feedTimeStringFromTimestamp:postDraft.time];
      
        timeLabel.frame = CGRectMake(kScreenWidth - 15 - 120, _draftInfo.cellHeight - 7 - 14, 120, 14);
        
        if (postDraft.picDraftList > 0 || postDraft.video.asset.localIdentifier.length > 0)
        {
            thumbView.frame = CGRectMake(richLabel.left, 40 + 5, 64, 64);
          
            publishCardView.frame = CGRectZero;
            publishCardView.hidden = YES;

            if (postDraft.video.asset.localIdentifier.length > 0)
            {
                playFlag.frame = CGRectMake(0, 0, 24, 24);
                playFlag.center = CGPointMake(32, 32);
            }
            else
            {
                playFlag.frame = CGRectZero;
            }

            if (postDraft.picDraftList > 0)
            {
                WLAttachmentDraft *attachmentDraft = postDraft.picDraftList.firstObject;

                [WLImageHelper imageFromAsset:attachmentDraft.asset size:CGSizeMake(thumbView.width*6, thumbView.height*6) result:^(UIImage *thumbImage) {
                    self->thumbView.image = thumbImage;
                }];
            }


            if (postDraft.video.asset.localIdentifier.length > 0)
            {
                [WLImageHelper imageFromAsset:postDraft.video.asset size:CGSizeMake(thumbView.width*6, thumbView.height*6) result:^(UIImage *thumbImage) {
                    self->thumbView.image = thumbImage;
                }];
            }
        }
        else
        {
            publishCardView.frame = CGRectZero;
            publishCardView.hidden = YES;
            thumbView.frame = CGRectZero;
        }
    }

    if (_draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_FORWARD_POST ||
        _draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
    {
        WLForwardDraft *postDraft = (WLForwardDraft *)_draftInfo.draftBase;
        richLabel.height = _draftInfo.handledFeedModel.textRender.textBound.size.height;
        timeLabel.text = [NSDate feedTimeStringFromTimestamp:postDraft.time];

        playFlag.frame = CGRectZero;

        thumbView.frame = CGRectZero;

        publishCardView.frame = CGRectMake(15, 40 + 2, kScreenWidth - 30, 64);

        [publishCardView setPostBase:postDraft.parentPost];
        publishCardView.hidden = NO;

        
        timeLabel.frame = CGRectMake(kScreenWidth - 15 - 120, _draftInfo.cellHeight - 7 - 14, 120, 14);
    }

    if (_draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_COMMENT ||
        _draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_REPLY   ||
        _draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
    {
        richLabel.height = _draftInfo.handledFeedModel.textRender.textBound.size.height;
        timeLabel.text = [NSDate feedTimeStringFromTimestamp:_draftInfo.draftBase.time];

        playFlag.frame = CGRectZero;

        thumbView.frame = CGRectZero;

        publishCardView.frame = CGRectZero;
        publishCardView.hidden = YES;

        timeLabel.frame = CGRectMake(kScreenWidth - 15 - 120, _draftInfo.cellHeight - 7 - 14, 120, 14);
    }
}


-(void)drawCell
{
    //显示
    [richLabel setTextRender:_draftInfo.handledFeedModel.textRender];
}

-(void)sendBtnPressed
{
    if (_draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_POST)
    {
        WLPostDraft *postDraft = (WLPostDraft *)_draftInfo.draftBase;
        
        NSMutableArray *attachArray = [[NSMutableArray alloc] initWithCapacity:0];
        for(WLAttachmentDraft *attachmentDraft in postDraft.picDraftList)
        {
            //在这里检查看文件是否已经上传过
           // WLAttachmentDraft *attachmentDraft = [[WLAttachmentDraft alloc] initWithPHAsset:assetModel.asset];
            
            NSString *fileJsonStr = [WLUploadRecord getUploadImageUrlWithidertifer:attachmentDraft.asset.localIdentifier];
            if (fileJsonStr.length > 0)
            {
                NSDictionary *fileJsonDic = [NSDictionary stringToDictionnary:fileJsonStr];
                NSString *fileUrlStr = fileJsonDic[@"fileUrl"];
                if (fileUrlStr.length > 0)
                {
                    attachmentDraft.url = fileUrlStr;
                    attachmentDraft.tmpImgWidth = [fileJsonDic[@"width"] floatValue];
                    attachmentDraft.tmpImgHeight = [fileJsonDic[@"height"] floatValue];
                }
            }
            
            [attachArray addObject:attachmentDraft];
        }
        
        postDraft.picDraftList = attachArray;
        
        [[AppContext getInstance].publishTaskManager postTask:postDraft];
    }
    
    if (_draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_FORWARD_POST ||
        _draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_FORWARD_COMMENT)
    {
        WLForwardDraft *postDraft = (WLForwardDraft *)_draftInfo.draftBase;
        
        [[AppContext getInstance].publishTaskManager postTask:postDraft];
    }
    
    if (_draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_COMMENT)
    {
         WLCommentDraft *postDraft = (WLCommentDraft *)_draftInfo.draftBase;
          [[AppContext getInstance].publishTaskManager postTask:postDraft];
    }
    
    if (_draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_REPLY)
    {
          WLReplyDraft *postDraft = (WLReplyDraft *)_draftInfo.draftBase;
          [[AppContext getInstance].publishTaskManager postTask:postDraft];
    }
    
    if (_draftInfo.draftBase.type == WELIKE_DRAFT_TYPE_REPLY_OF_REPLY)
    {
          WLReplyOfReplyDraft *postDraft = (WLReplyOfReplyDraft *)_draftInfo.draftBase;
          [[AppContext getInstance].publishTaskManager postTask:postDraft];
    }
    [_delegate resendDidTaped:_draftInfo];
}



@end
