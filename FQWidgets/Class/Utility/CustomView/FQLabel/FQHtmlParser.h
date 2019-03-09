//
//  FQHtmlParser.h
//  FQWidgets
//
//  Created by fan qi on 2019/3/5.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString * const FQCustomImageAttributeName;
UIKIT_EXTERN NSString * const FQCustomURLAttributeName;
UIKIT_EXTERN NSString * const MyCustomEmojiAttributeName;

@class FQHtmlParser;

@protocol FQHtmlParserDelegate <NSObject>

- (void)htmlParserAttributedTextChanged:(FQHtmlParser *)parser;

@end

@interface FQHtmlParser : NSObject

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *typingAttributes;
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *linkTextAttributes;
@property (nonatomic, strong, readonly) NSString *html;
@property (nonatomic, strong, readonly) NSAttributedString *attributedText;
@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, strong, readonly) NSArray *highlightArray;

@property (nonatomic, weak) id<FQHtmlParserDelegate> delegate;

- (NSAttributedString *)attributedTextWithHtml:(NSString *)html;

@end
