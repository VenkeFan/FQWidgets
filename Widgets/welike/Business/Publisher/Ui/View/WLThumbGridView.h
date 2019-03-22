//
//  ThumbGridView.h
//  CuctvWeibo
//
//  Created by GYB on 14-6-4.
//
//


@protocol ThumbGridViewDelegate   <NSObject>

-(void)removeThumbAtIndex:(NSInteger)index;

-(void)browseThumbAtIndex:(NSInteger)index;


-(void)addPhoto;

@end

@interface WLThumbGridView : UIView

@property(strong,nonatomic) NSMutableArray *imageArray;
@property(weak,nonatomic) id target;
@property(weak,nonatomic) id<ThumbGridViewDelegate> delegate;


- (id)initWithFrame:(CGRect)frame withTarget:(id)_target;

@end

