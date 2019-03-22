//
//  WLArticalCell.h
//  welike
//
//  Created by gyb on 2019/2/23.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WLArticalCellDelegate <NSObject>

@optional
- (void)didClickedLink:(NSString *)urlStr;
- (void)didClickedPic:(NSString *)urlStr;
- (void)didClickedVideo:(NSString *)urlStr;

@end


@interface WLArticalCell : UITableViewCell

@property (nonatomic, weak) id<WLArticalCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
