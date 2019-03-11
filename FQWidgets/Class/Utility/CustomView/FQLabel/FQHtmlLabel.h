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

@property (nonatomic, weak) id<FQHtmlLabelDelegate> htmlDelegate;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;
//@property (nonatomic, assign) NSInteger numberOfLines;

@end
