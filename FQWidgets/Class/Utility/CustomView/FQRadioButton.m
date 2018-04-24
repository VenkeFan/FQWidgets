//
//  FQRadioButton.m
//  WeLike
//
//  Created by fan qi on 2018/4/2.
//  Copyright © 2018年 fan qi. All rights reserved.
//

#import "FQRadioButton.h"

static NSMutableDictionary *_groupRadioDic = nil;

@interface FQRadioButton ()

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

@end

@implementation FQRadioButton

#pragma mark - LifeCycle

- (instancetype)initWithGroupName:(NSString *)groupName {
    if (self = [super init]) {
        self.exclusiveTouch = YES;
        [self addButtonToRadioGroup:groupName];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"FQRadioButton dealloc");
}

#pragma mark - Public

+ (void)clearRadioGroup {
    if (!_groupRadioDic || _groupRadioDic.allKeys.count == 0) {
        return;
    }
    
    [_groupRadioDic removeAllObjects];
}

#pragma mark - Override

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    _target = target;
    _action = action;
    
    __weak typeof(self) wealSelf = self;
    [super addTarget:wealSelf action:@selector(radio_Action) forControlEvents:controlEvents];
}

#pragma mark - Private

- (void)radio_Action {
    [self radioButtonClicked];
    
    if (_target && [_target respondsToSelector:_action]) {
        IMP imp = [_target methodForSelector:_action];
        void (*fun)(id, SEL, UIButton *) = (void *)imp;
        fun(_target, _action, self);
    }
}

- (void)addButtonToRadioGroup:(NSString *)groupName {
    if (!groupName || groupName.length == 0) {
        return;
    }
    _groupName = groupName;
    
    if (!_groupRadioDic) {
        _groupRadioDic = [NSMutableDictionary dictionary];
    }
    
    NSMutableArray *array = [_groupRadioDic objectForKey:groupName];
    if (!array) {
        array = [NSMutableArray array];
    }
    __weak typeof(self) weakSelf = self;
    [array addObject:weakSelf];
    [_groupRadioDic setObject:array forKey:groupName];
}

- (void)radioButtonClicked {
    if (self.isSelected) {
        return;
    }
    
    self.selected = !self.isSelected;
    
    NSMutableArray *array = [_groupRadioDic objectForKey:_groupName];
    for (UIButton *btn in array) {
        if ([btn isEqual:self]) {
            continue;
        }
        btn.selected = NO;
    }
}

@end
