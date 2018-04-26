//
//  WLFeedCell.m
//  FQWidgets
//
//  Created by fan qi on 2018/4/18.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "WLFeedCell.h"
#import "CALayer+FQExtension.h"

CATextLayer * textLayerWithFont(UIFont *font) {
    CATextLayer *txtLayer = [CATextLayer layer];
    txtLayer.backgroundColor = [UIColor redColor].CGColor;
    txtLayer.contentsScale = [UIScreen mainScreen].scale;
    txtLayer.alignmentMode = kCAAlignmentJustified;
    txtLayer.truncationMode = kCATruncationEnd;
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    txtLayer.font = fontRef;
    txtLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    return txtLayer;
}

@implementation WLFeedToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, kScreenWidth, cellToolBarHeight)]) {
        CGFloat width = kScreenWidth / 3.0;
        
        CALayer *line = [CALayer layer];
        line.frame = CGRectMake(cellPaddingLeft, 0, cellContentWidth, cellLineHeight);
        line.backgroundColor = kUIColorFromRGB(0xDDDDDD).CGColor;
        [self.layer addSublayer:line];
        
        UIButton *transpondBtn = [self buttonWithImgName:@"feed_transpond"
                                                   title:@"6"
                                                       x:0
                                                  action:@selector(transpondBtnClicked)];
        transpondBtn.backgroundColor = [UIColor cyanColor];
        [self addSubview:transpondBtn];
        
        UIButton *commentBtn = [self buttonWithImgName:@"feed_comment"
                                                 title:@"12"
                                                     x:width
                                                action:@selector(commentBtnClicked)];
        [self addSubview:commentBtn];
        
        UIButton *likeBtn = [self buttonWithImgName:@"feed_like_normal"
                                              title:@"18"
                                                  x:width * 2
                                             action:@selector(likeBtnClicked)];
        likeBtn.backgroundColor = [UIColor cyanColor];
        [self addSubview:likeBtn];
    }
    return self;
}

- (UIButton *)buttonWithImgName:(NSString *)imgName
                          title:(NSString *)title
                              x:(CGFloat)x
                         action:(SEL)action {
    CGFloat width = kScreenWidth / 3.0;
    CGFloat height = cellToolBarHeight;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(x, cellLineHeight, width, height);
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kUIColorFromRGB(0xA6A7A8) forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
    btn.titleLabel.font = kMediumFont(kSizeScale(13));
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)transpondBtnClicked {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedTranspond:)]) {
        [_cell.delegate feedCell:_cell didClickedTranspond:_itemModel];
    }
}

- (void)commentBtnClicked {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedComment:)]) {
        [_cell.delegate feedCell:_cell didClickedComment:_itemModel];
    }
}

- (void)likeBtnClicked {
    if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedLike:)]) {
        [_cell.delegate feedCell:_cell didClickedLike:_itemModel];
    }
}

@end

@implementation WLFeedCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kUIColorFromRGB(0xF7F7F7);
        
        _coverLayer = [CALayer layer];
        _coverLayer.frame = CGRectMake(0, 0, cellCardHeight, cellCardHeight);
        _coverLayer.contentsGravity = kCAGravityResizeAspect;
        [self.layer addSublayer:_coverLayer];
        
        CGFloat x = CGRectGetMaxX(_coverLayer.frame) + kSizeScale(13), y = kSizeScale(9);
        CGFloat textWidth = CGRectGetWidth(self.bounds) - x;
        
        _titleLayer = textLayerWithFont(cellBodyFont);
        _titleLayer.frame = CGRectMake(x, y, textWidth, kSizeScale(20));
        _titleLayer.foregroundColor = kNameFontColor.CGColor;
        [self.layer addSublayer:_titleLayer];
        y += CGRectGetHeight(_titleLayer.frame) + kSizeScale(2);
        
        _descLayer = textLayerWithFont(cellDescFont);
        _descLayer.frame = CGRectMake(x, y, textWidth, kSizeScale(17));
        _descLayer.foregroundColor = kDescFontColor.CGColor;
        [self.layer addSublayer:_descLayer];
    }
    return self;
}

- (void)setItemModel:(WLFeedModel *)itemModel {
    _itemModel = itemModel;
    
    [_coverLayer fq_setImageWithURLString:itemModel.pageInfo.pagePic.absoluteString];
    _titleLayer.string = itemModel.pageInfo.pageTitle;
    _descLayer.string = itemModel.pageInfo.pageDesc;
}

@end

@implementation WLFeedProfileView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor greenColor];
        _avatarLayer = [CALayer layer];
        _avatarLayer.frame = CGRectMake(0, 0, cellAvatarSize, cellAvatarSize);
        _avatarLayer.contentsGravity = kCAGravityResizeAspect;
        [self.layer addSublayer:_avatarLayer];
        
        _nameLayer = textLayerWithFont(cellNameFont); // [self textLayerWithFont:cellNameFont];
        _nameLayer.foregroundColor = kNameFontColor.CGColor;
        [self.layer addSublayer:_nameLayer];
        
        _timeLayer = textLayerWithFont(cellDateTimeFont); // [self textLayerWithFont:cellDateTimeFont];
        _timeLayer.foregroundColor = kDateTimeFontColor.CGColor;
        [self.layer addSublayer:_timeLayer];
    }
    return self;
}

- (void)setItemModel:(WLFeedModel *)itemModel {
    _itemModel = itemModel;
    
    self.frame = CGRectMake(0, 0, cellContentWidth, itemModel.layout.profileHeight);
    _nameLayer.frame = itemModel.layout.nameFrame;
    _timeLayer.frame = itemModel.layout.timeFrame;
    
    [_avatarLayer fq_setImageWithURLString:itemModel.user.avatarLarge.absoluteString cornerRadius:cellAvatarSize * 0.5];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _nameLayer.string = itemModel.user.screenName;
    _timeLayer.string = itemModel.source;
    [CATransaction commit];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_avatarLayer.frame, point) || CGRectContainsPoint(_nameLayer.frame, point)) {
        if ([_cell.delegate respondsToSelector:@selector(feedCell:didClickedUser:)]) {
            [_cell.delegate feedCell:_cell didClickedUser:_itemModel.user];
        }
    }
}

@end

@implementation WLFeedContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(cellPaddingLeft,
                                                                cellPaddingTop,
                                                                cellContentWidth,
                                                                0)];
        _contentView.backgroundColor = [UIColor yellowColor];
        [self addSubview:_contentView];
        
        // profile
        _profileView = [[WLFeedProfileView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.bounds), 0)];
        [_contentView addSubview:_profileView];
        
        // text
        _feedLabel = [[WLLabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.bounds), 0)];
        _feedLabel.backgroundColor = [UIColor magentaColor];
        [_contentView addSubview:_feedLabel];
        
        // retweet
        _retweetedView = [[UIView alloc] initWithFrame:CGRectMake(-cellPaddingLeft, 0, kScreenWidth, 0)];
        _retweetedView.backgroundColor = [UIColor lightGrayColor]; // kUIColorFromRGB(0xF7F7F7);
        [_contentView addSubview:_retweetedView];
        
        _retweetedLabel = [[WLLabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.bounds), 0)];
        _retweetedLabel.backgroundColor = [UIColor cyanColor];
        [_contentView addSubview:_retweetedLabel];
        
        // pictures
        _thumbView = [[FQThumbnailView alloc] initWithFrame:CGRectZero];
        [_contentView addSubview:_thumbView];
        
        // card
        _cardView = [[WLFeedCardView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contentView.bounds), cellCardHeight)];
        _cardView.hidden = YES;
        [_contentView addSubview:_cardView];
        
        // toolbar
        _toolBar = [[WLFeedToolBar alloc] init];
        [self addSubview:_toolBar];
    }
    return self;
}

- (void)setCell:(WLFeedCell *)cell {
    _cell = cell;
    
    _profileView.cell = cell;
    _cardView.cell = cell;
    _toolBar.cell = cell;
}

- (void)setItemModel:(WLFeedModel *)itemModel {
    _itemModel = itemModel;
    
    {
        CGRect contentFrame = _contentView.frame;
        contentFrame.size.height = itemModel.layout.contentHeight;
        _contentView.frame = contentFrame;
    }
    
    {
        [_profileView setItemModel:itemModel];
    }
    
    {
        CGRect textFrame = _feedLabel.frame;
        textFrame.origin.y = itemModel.layout.textTop;
        textFrame.size.height = itemModel.layout.textHeight;
        _feedLabel.frame = textFrame;
        _feedLabel.text = itemModel.text;
    }
    
    {
        if (itemModel.retweetedStatus) {
            _retweetedView.hidden = NO;
            _retweetedLabel.hidden = NO;
            
            CGRect retweetedFrame = _retweetedView.frame;
            retweetedFrame.origin.y = itemModel.layout.retweetedViewTop;
            retweetedFrame.size.height = itemModel.layout.retweetedViewHeight;
            _retweetedView.frame = retweetedFrame;
            
            CGRect retweetedLabFrame = _retweetedLabel.frame;
            retweetedLabFrame.origin.y = itemModel.retweetedStatus.layout.retweetedTextTop;
            retweetedLabFrame.size.height = itemModel.retweetedStatus.layout.retweetedTextHeight;
            _retweetedLabel.frame = retweetedLabFrame;
            _retweetedLabel.attributedText = itemModel.retweetedStatus.layout.retweetedText;
            
            if (itemModel.retweetedStatus.pics.count > 0) {
                [self p_setThumbView:itemModel.retweetedStatus];
                
            } else {
                [self p_setCardView:itemModel.retweetedStatus];
            }
            
        } else if (itemModel.pics.count > 0) {
            _retweetedView.hidden = YES;
            _retweetedLabel.hidden = YES;
            
            [self p_setThumbView:itemModel];
            
        } else {
            _retweetedView.hidden = YES;
            _retweetedLabel.hidden = YES;
            
            [self p_setCardView:itemModel];
        }
    }
    
    {
        _toolBar.frame = CGRectMake(0, CGRectGetMaxY(_contentView.frame), kScreenWidth, cellToolBarHeight);
    }
    
    {
        self.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetMaxY(_toolBar.frame));
    }
}

- (void)p_setThumbView:(WLFeedModel *)itemModel {
    _thumbView.hidden = NO;
    _cardView.hidden = YES;
    
    [_thumbView setImages:itemModel.pics
                 imgWidth:itemModel.layout.picSize.width
                imgHeight:itemModel.layout.picSize.height
                  spacing:cellPicSpacing];
    
    CGRect thumbFrame = _thumbView.frame;
    thumbFrame.origin.y = itemModel.layout.picGroupTop;
    thumbFrame.size = itemModel.layout.picGroupSize;
    _thumbView.frame = thumbFrame;
}

- (void)p_setCardView:(WLFeedModel *)itemModel {
    _thumbView.hidden = YES;
    
    if (itemModel.pageInfo) {
        _cardView.hidden = NO;
        [_cardView setItemModel:itemModel];
        
        CGRect cardFrame = _cardView.frame;
        cardFrame.origin.y = itemModel.layout.cardTop;
        _cardView.frame = cardFrame;
    } else {
        _cardView.hidden = YES;
    }
}

@end

@implementation WLFeedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _feedView = [[WLFeedContentView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        [self.contentView addSubview:_feedView];
    }
    return self;
}

- (void)setItemModel:(WLFeedModel *)itemModel {
    _feedView.cell = self;
    [_feedView setItemModel:itemModel];
}

@end
