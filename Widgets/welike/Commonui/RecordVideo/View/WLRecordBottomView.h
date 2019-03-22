//
//  WLRecordBottomView.h
//  welike
//
//  Created by gyb on 2019/1/7.
//  Copyright © 2019 redefine. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class QUProgressView;
@interface WLRecordBottomView : UIView
{
    UIButton *recordBtn;
    UIButton *filterBtn;
    UIButton *pasterBtn;
    UIButton *deleteButton;
    UIButton *finishRecordBtn;
    
    
    QUProgressView *progressView;
}
@end

NS_ASSUME_NONNULL_END
