//
//  FQHtmlLabel.h
//  FQWidgets
//
//  Created by fan qi on 2019/3/6.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQHtmlHighlight.h"

@class FQHtmlLabel;

@protocol FQHtmlLabelDelegate <NSObject>

- (void)htmlLabel:(FQHtmlLabel *)htmlLabel didHighlight:(FQHtmlHighlight *)highlight;

@end

@interface FQHtmlLabel : UIScrollView

@property (nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *typingAttributes;
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey,id> *linkTextAttributes;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;
//@property (nonatomic, assign) NSInteger numberOfLines;

@property (nonatomic, weak) id<FQHtmlLabelDelegate> htmlDelegate;

@end
