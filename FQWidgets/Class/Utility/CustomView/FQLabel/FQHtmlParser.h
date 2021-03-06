//
//  FQHtmlParser.h
//  FQWidgets
//
//  Created by fan qi on 2019/3/5.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString * const FQHtmlDelegateAttributeName;
UIKIT_EXTERN NSString * const FQHtmlImageAttributeName;
UIKIT_EXTERN NSString * const FQHtmlUrlAttributeName;
UIKIT_EXTERN NSString * const FQHtmlEmojiAttributeName;

@class FQHtmlParser;

@protocol FQHtmlParserDelegate <NSObject>

- (void)htmlParserAttributedTextChanged:(FQHtmlParser *)parser;

@end

@interface FQHtmlParser : NSObject

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *typingAttributes;
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *linkTextAttributes;
@property (nonatomic, copy, readonly) NSString *html;
@property (nonatomic, copy, readonly) NSAttributedString *attributedText;
@property (nonatomic, strong, readonly) NSArray *highlightArray;
@property (nonatomic, strong, readonly) NSArray *renderViewArray;
@property (nonatomic, assign) CGFloat contentWidth;

@property (nonatomic, weak) id<FQHtmlParserDelegate> delegate;

- (void)parseHtmlStr:(NSString *)htmlStr finished:(void(^)(NSAttributedString *attributedTxt))finished;

@end
