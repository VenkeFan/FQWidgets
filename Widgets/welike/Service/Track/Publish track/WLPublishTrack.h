//
//  WLPublishTrack.h
//  welike
//
//  Created by gyb on 2018/12/6.
//  Copyright © 2018 redefine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLPublishModel.h"

@interface WLPublishTrack : NSObject

//1.发布器界面展示
+(void)publishPageAppear:(WLTrackerPostClickedFromSource)source
             main_source:(WLTrackerPostClickedFromMain_Source)mainSource
               page_type:(WLTrackerPublishPage_type)pageType;

//2.相机相册录像按钮点击
+(void)cameraBtnClicked:(WLTrackerPostClickedFromSource)source
            main_source:(WLTrackerPostClickedFromMain_Source)mainSource;

//3.@按钮点击
+(void)mentionBtnClicked:(WLTrackerPostClickedFromSource)source
             main_source:(WLTrackerPostClickedFromMain_Source)mainSource
               page_type:(WLTrackerPublishPage_type)pageType;

//4.链接按钮点击
+(void)linkBtnClicked:(WLTrackerPostClickedFromSource)source
          main_source:(WLTrackerPostClickedFromMain_Source)mainSource
            page_type:(WLTrackerPublishPage_type)pageType;

//5.location按钮点击
+(void)locationBtnClicked:(WLTrackerPostClickedFromSource)source
              main_source:(WLTrackerPostClickedFromMain_Source)mainSource;

//6.人搜索页展示
+(void)contactPageAppear:(WLTrackerPostClickedFromSource)source
             main_source:(WLTrackerPostClickedFromMain_Source)mainSource
               page_type:(WLTrackerPublishPage_type)pageType;

//7.@人有输入
+(void)contactPageInput:(WLTrackerPostClickedFromSource)source
            main_source:(WLTrackerPostClickedFromMain_Source)mainSource
              page_type:(WLTrackerPublishPage_type)pageType;

//8.@人Search online
+(void)contactPageSearchOnline:(WLTrackerPostClickedFromSource)source
                   main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                     page_type:(WLTrackerPublishPage_type)pageType;//8

//9.@人结果点击
+(void)contactPageSelectPersons:(WLTrackerPostClickedFromSource)source
                    main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                      page_type:(WLTrackerPublishPage_type)pageType;;//9

//10.表情按钮点击
+(void)publishEmojiBtnClicked:(WLTrackerPostClickedFromSource)source
                  main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                    page_type:(WLTrackerPublishPage_type)pageType;;//10

//11.链接按钮点击-链接输入框展示
+(void)publishLinkBtnDisplayed:(WLTrackerPostClickedFromSource)source
                 main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                   page_type:(WLTrackerPublishPage_type)pageType;//11

//12.链接输入框点击确认
+(void)publishLinkTInputViewClick:(WLTrackerPostClickedFromSource)source
                      main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                        page_type:(WLTrackerPublishPage_type)pageType;

//13.点击SEND按钮发布
+(void)publishSendBtnClicked:(WLPublishModel *)publishModel;

//14.发布器界面退出
+(void)publishControllerClose:(WLPublishModel *)publishModel;

//15.点击Send按钮发布并返回成功结果
+(void)publishSendBtnClickedAndSuccess:(WLPublishModel *)publishModel;

//16.投票按钮点击
+(void)voteBtnClicked:(WLTrackerPostClickedFromSource)source
          main_source:(WLTrackerPostClickedFromMain_Source)mainSource
            page_type:(WLTrackerPublishPage_type)pageType;

//17.Add Hashtag点击  //TODO:目前还没有
+(void)addHashtagBtnClicked:(WLTrackerPostClickedFromSource)source
                main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                  page_type:(WLTrackerPublishPage_type)pageType;

//18.话题搜索页展示
+(void)searchTopicControllerAppear:(WLTrackerPostClickedFromSource)source
                       main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                         page_type:(WLTrackerPublishPage_type)pageType;

//19.话题有输入
+(void)inputTopicInSearchBar:(WLTrackerPostClickedFromSource)source
                 main_source:(WLTrackerPostClickedFromMain_Source)mainSource
                   page_type:(WLTrackerPublishPage_type)pageType;

//20.话题点击,除了add topic下面那个话题
+(void)topicSelect:(WLTrackerPostClickedFromSource)source
      main_source:(WLTrackerPostClickedFromMain_Source)mainSource
        page_type:(WLTrackerPublishPage_type)pageType
     topic_source:(WLTopic_source)topic_source
         topic_id:(NSString *)topic_id;

//21.Add topic下侧的话题点击
+(void)addTopicClicked:(WLTrackerPostClickedFromSource)source
           main_source:(WLTrackerPostClickedFromMain_Source)mainSource
             page_type:(WLTrackerPublishPage_type)pageType;

//22.点击Send按钮发布并返回失败结果
+(void)publishSendBtnClickedAndFail:(WLPublishModel *)publishModel;


@end

