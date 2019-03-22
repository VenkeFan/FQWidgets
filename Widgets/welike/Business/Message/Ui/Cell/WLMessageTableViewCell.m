//
//  WLMessageTableViewCell.m
//  welike
//
//  Created by luxing on 2018/5/16.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLMessageTableViewCell.h"
#import "WLAccountManager.h"
#import "NSDate+LuuBase.h"

@interface WLMessageTableViewCell () <WLHeadViewDelegate>

@property (nonatomic, strong) WLHeadView *avatarView; //头像
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *stateButton;
@property (nonatomic, strong) UIActivityIndicatorView *sendingActivity;

@end

@implementation WLMessageTableViewCell

#pragma mark - init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initMessageCell];
    }
    return self;
}

- (void)initMessageCell
{
    _avatarView = [[WLHeadView alloc] initWithDefaultImageId:@"head_default"];
    _avatarView.delegate = self;
    [self.contentView addSubview:_avatarView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = kNameFontColor;
    _nameLabel.font = [UIFont systemFontOfSize:kNameFontSize];
    _nameLabel.numberOfLines = 1;
    [self.contentView addSubview:_nameLabel];
    
    _bubbleImageView = [[UIImageView alloc] init];
    _bubbleImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_bubbleImageView];
    
    _stateButton = [[UIButton alloc] init];
    [_stateButton addTarget:self action:@selector(stateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_stateButton];
    
    _sendingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.contentView addSubview:_sendingActivity];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(messageCellLongPressed:)];
    [self addGestureRecognizer:longPress];
    [self addGestureRecognizerForBubbleView];
}

- (void)addGestureRecognizerForBubbleView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapped:)];
    [_bubbleImageView addGestureRecognizer:tap];
}

#pragma mark -

- (void)stateButtonClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(message:didTouchStateView:)]) {
        [self.delegate message:self.message didTouchStateView:self];
    }
}

- (void)messageCellLongPressed:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint avatarPoint = [longPress locationInView:self.avatarView];
        CGPoint bubblePoint = [longPress locationInView:self.bubbleImageView];
        if (CGRectContainsPoint(self.avatarView.bounds, avatarPoint)) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(message:avatarViewLongPressed:)]) {
                [self.delegate message:self.message avatarViewLongPressed:longPress];
            }
        } else if (CGRectContainsPoint(self.bubbleImageView.bounds, bubblePoint)) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:longPressed:)]) {
                [self.delegate messageCell:self longPressed:longPress];
            }
        }
    } else if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:longPressed:)]) {
            [self.delegate messageCell:self longPressed:longPress];
        }
    }
}

- (void)bubbleViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(message:didTouchBubbleImageView:)]) {
        [self.delegate message:self.message didTouchBubbleImageView:self];
    }
}

#pragma mark - reusableCell

+ (instancetype)reusableCellOfTableView:(UITableView *)tableView
{
    NSString *reuseIdentifier = NSStringFromClass(self);
    id cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
    {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

#pragma mark - bind message

- (void)bindMessage:(WLIMMessage *)message
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    self.message = message;
    self.avatarView.headUrl = self.message.senderHead;
    if ([self.message.senderUid isEqualToString:account.uid] == YES) {
        self.nameLabel.hidden = YES;
        if (self.message.status == WLIMMessageStatusSending) {
            self.stateButton.hidden = YES;
            self.sendingActivity.hidden = NO;
            [self.sendingActivity startAnimating];
        } else {
            if (self.message.status == WLIMMessageStatusSendFailed) {
                self.stateButton.hidden = NO;
                [self.stateButton setImage:[AppContext getImageForKey:@"msg_resend"] forState:UIControlStateNormal];
            } else {
                self.stateButton.hidden = YES;
            }
            self.sendingActivity.hidden = YES;
            [self.sendingActivity stopAnimating];
        }
    } else {
        if (self.message.sessionType == WLIMSessionTypeGroup || self.message.sessionType ==  WLIMSessionTypeStranger) {
            self.nameLabel.hidden = NO;
            self.nameLabel.text = self.message.senderNickName;
        } else {
            self.nameLabel.hidden = YES;
        }
        self.stateButton.hidden = YES;
        self.sendingActivity.hidden = YES;
        [self.sendingActivity stopAnimating];
    }
    [self bindBubbleImage];
    [self bindOtherView];
}

- (void)bindBubbleImage
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    if ([self.message.senderUid isEqualToString:account.uid] == YES) {
        self.bubbleImageView.image = [[AppContext getImageForKey:@"msg_send_bubble"] stretchableImageWithLeftCapWidth:10 topCapHeight:19];
    } else {
        self.bubbleImageView.image = [[AppContext getImageForKey:@"msg_receive_bubble"] stretchableImageWithLeftCapWidth:10 topCapHeight:19];
    }
}

- (void)bindOtherView
{
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutMessageCell];
    [self layoutOtherView];
}

- (void)layoutMessageCell
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    CGSize bubbleSize = [self bubbleSize];
    if ([self.message.senderUid isEqualToString:account.uid] == YES) {
        self.avatarView.frame = CGRectMake(CGRectGetWidth(self.frame)-kMessageCellLeftMargin-kMessageCellAvatarSize, CGRectGetHeight(self.frame)-kMessageCellAvatarSize, kMessageCellAvatarSize, kMessageCellAvatarSize);
        self.bubbleImageView.frame = CGRectMake(CGRectGetMinX(self.avatarView.frame)-kMessageBubblePading-bubbleSize.width, CGRectGetHeight(self.frame)-bubbleSize.height, bubbleSize.width, bubbleSize.height);
        CGRect frame = CGRectMake(CGRectGetMinX(self.bubbleImageView.frame)-kMessageBubblePading-kMessageStateButtonSize, CGRectGetMidY(self.bubbleImageView.frame)-kMessageStateButtonSize/2, kMessageStateButtonSize, kMessageStateButtonSize);
        if (self.message.status == WLIMMessageStatusSending) {
            self.sendingActivity.frame = frame;
        } else if (self.message.status == WLIMMessageStatusSendFailed) {
            self.stateButton.frame = frame;
        }
    } else {
        self.avatarView.frame = CGRectMake(kMessageCellLeftMargin, CGRectGetHeight(self.frame)-kMessageCellAvatarSize, kMessageCellAvatarSize, kMessageCellAvatarSize);
        self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame)+kMessageCellNameLablePading, kMessageCellTopMargin, self.frame.size.width - 2*(kMessageCellLeftMargin+kMessageCellAvatarSize+kMessageCellNameLablePading), kMessageCellNameLableHeight);
        self.bubbleImageView.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame)+kMessageBubblePading, CGRectGetHeight(self.frame)-bubbleSize.height, bubbleSize.width, bubbleSize.height);
    }
}

- (void)layoutOtherView
{
}

- (CGSize)bubbleSize
{
    WLAccount *account = [[AppContext getInstance].accountManager myAccount];
    CGFloat height = 0;
    if ([self.message.senderUid isEqualToString:account.uid] == NO && (self.message.sessionType == WLIMSessionTypeGroup || self.message.sessionType ==  WLIMSessionTypeStranger)) {
        height += (kMessageCellNameLablePading+kMessageCellNameLableHeight);
    }
    return CGSizeMake(kMessageBubbleMaxWidth, MAX((CGRectGetHeight(self.frame)-kMessageCellTopMargin-height),0));
}

#pragma mark - WLHeadViewDelegate

- (void)onClick:(WLHeadView *)headView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(message:avatarViewPressed:)]) {
        [self.delegate message:self.message avatarViewPressed:headView];
    }
}

@end

@interface WLMessageSectionHeaderView ()

@property (nonatomic,strong) UILabel *timeLabel;

@end

@implementation WLMessageSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.frame = CGRectMake(0, CGRectGetHeight(frame)-kMessageSectionHeadTimeHeight, CGRectGetWidth(frame),kMessageSectionHeadTimeHeight);
        _timeLabel.textColor = kDateTimeFontColor;
        _timeLabel.font = [UIFont systemFontOfSize:kMessageSectionHeadTimeFontSize];
        _timeLabel.numberOfLines = 1;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_timeLabel];
    }
    return self;
}

- (void)setSetionTimeStamp:(NSTimeInterval)timeStamp
{
    self.timeLabel.text = [NSDate commentTimeStringFromTimestamp:timeStamp];
}

@end
