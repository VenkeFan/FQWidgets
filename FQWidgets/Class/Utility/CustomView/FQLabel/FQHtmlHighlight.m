//
//  FQHtmlHighlight.m
//  FQWidgets
//
//  Created by fan qi on 2019/3/9.
//  Copyright © 2019 fan qi. All rights reserved.
//

#import "FQHtmlHighlight.h"

@implementation FQHtmlHighlight

- (void)setLinkUrl:(NSString *)linkUrl {
    _linkUrl = [linkUrl copy];
    
    if (_linkUrl.length > 0) {
        _type = FQHtmlHighlightType_Link;
    }
}

- (void)setImgUrl:(NSString *)imgUrl {
    _imgUrl = [imgUrl copy];
    
    if (_linkUrl.length == 0 && _imgUrl.length > 0) {
        _type = FQHtmlHighlightType_Image;
    }
}

@end
