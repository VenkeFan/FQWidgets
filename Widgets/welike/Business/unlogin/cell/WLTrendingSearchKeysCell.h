//
//  WLTrendingSearchKeysCell.h
//  welike
//
//  Created by gyb on 2018/8/28.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultButtonCount                 4

@protocol WLTrendingSearchKeysCellDelegate <NSObject>

- (void)didClickKey:(NSString *)searchKey;

@end

@class WLTopicSearchSectionView;
@interface WLTrendingSearchKeysCell : UITableViewCell
{
    WLTopicSearchSectionView *sectionView;
}

@property (nonatomic, copy) NSArray *dataArray;

@property (nonatomic, weak) id<WLTrendingSearchKeysCellDelegate> delegate;

@end
