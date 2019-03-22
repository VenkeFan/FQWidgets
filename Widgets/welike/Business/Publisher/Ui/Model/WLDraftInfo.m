//
//  WLDraftInfo.m
//  welike
//
//  Created by gyb on 2018/6/6.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLDraftInfo.h"
#import "WLDraft.h"
#import "WLHandledFeedModel.h"
#import "TYTextRender.h"

@implementation WLDraftInfo


-(void)setDraftBase:(WLDraftBase *)draftBase
{
    _draftBase = draftBase;
    
      if ([draftBase isKindOfClass:[WLPostDraft class]])
      {
          WLPostDraft *postDraft = (WLPostDraft *)draftBase;
          
          WLHandledFeedModel *richModel = [[WLHandledFeedModel alloc] init];
          richModel.isSummaryDisplay = YES;
          richModel.font = kRegularFont(14);
          richModel.renderWidth = kScreenWidth - 30 - 56 - 10;
          richModel.renderHeight = 40;
          richModel.lineBreakMode = NSLineBreakByTruncatingTail;
          richModel.maxLineNum = 0;
          richModel.textColor = kBodyFontColor;
          [richModel handleRichModel:postDraft.content];
      
          _handledFeedModel = richModel;
          
          if (postDraft.picDraftList > 0 || postDraft.video.asset.localIdentifier.length > 0)
          {
              _cellHeight = 130;
          }
          else
          {
              _cellHeight = 60;
          }
      }
    
     if ([draftBase isKindOfClass:[WLForwardDraft class]])
     {
         WLForwardDraft *postDraft = (WLForwardDraft *)draftBase;
         
         
         WLHandledFeedModel *richModel = [[WLHandledFeedModel alloc] init];
         richModel.isSummaryDisplay = YES;
         richModel.font = kRegularFont(14);
         richModel.renderWidth = kScreenWidth - 30 - 56 - 10;
         richModel.renderHeight = 40;
         richModel.lineBreakMode = NSLineBreakByTruncatingTail;
         richModel.maxLineNum = 0;
         richModel.textColor = kBodyFontColor;
         [richModel handleRichModel:postDraft.content];
         
         _handledFeedModel = richModel;
         
         _cellHeight = 130;
         
     }
    
    if ([draftBase isKindOfClass:[WLCommentDraft class]] ||
        [draftBase isKindOfClass:[WLReplyDraft class]]   ||
        [draftBase isKindOfClass:[WLReplyOfReplyDraft class]])
    {
        WLCommentDraft *postDraft = (WLCommentDraft *)draftBase;
        
        WLHandledFeedModel *richModel = [[WLHandledFeedModel alloc] init];
        richModel.isSummaryDisplay = YES;
        richModel.font = kRegularFont(14);
        richModel.renderWidth = kScreenWidth - 30 - 56 - 10;
          richModel.renderHeight = 40;
        richModel.lineBreakMode = NSLineBreakByTruncatingTail;
        richModel.maxLineNum = 0;
        richModel.textColor = kBodyFontColor;
        [richModel handleRichModel:postDraft.content];
        
        _handledFeedModel = richModel;
        
        _cellHeight = 60;
    }
}



@end
