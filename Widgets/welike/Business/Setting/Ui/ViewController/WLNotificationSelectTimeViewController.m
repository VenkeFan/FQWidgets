//
//  WLNotificationSelectTimeViewController.m
//  welike
//
//  Created by luxing on 2018/5/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLNotificationSelectTimeViewController.h"

#define kSelectTimeButtonHeight             48.0
#define kSelectTimePickerPading             8.0
#define kSelectTimePickerWidth              190.0
#define kSelectTimePickerHeight             220.0
#define kSelectTimePickerRowHeight          30.0

#define kSelectTimeButtonFillColor              kUIColorFromRGB(0xF6F6F6)

typedef NS_ENUM(NSUInteger, WLTimeSelectButtonIndex) {
    WLTimeSelectButtonIndexFrom = 0,
    WLTimeSelectButtonIndexTo,
};

@interface WLNotificationSelectTimeViewController ()

@property (nonatomic,strong) UIButton *fromButton;

@property (nonatomic,strong) UIButton *toButton;

@property (nonatomic,strong) UIDatePicker *datePicker;

@property (nonatomic, assign) WLTimeSelectButtonIndex selectIndex;

@property (nonatomic,strong) WLTimeSelectViewModel *timeSelectModel;

@property (nonatomic, assign) BOOL needRefresh;

@end

@implementation WLNotificationSelectTimeViewController

- (instancetype)initWithTimeSelectModel:(WLTimeSelectViewModel *)model
{
    self = [super init];
    if (self) {
        self.timeSelectModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.title = [AppContext getStringForKey:@"Quiet_Hours" fileName:@"user"];
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = CGRectGetWidth(self.view.frame);
    
    self.fromButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fromButton.frame = CGRectMake(0, kNavBarHeight, width, kSelectTimeButtonHeight);
    [self.fromButton.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.fromButton setTitleColor:kNotificationSettingTimeColor forState:UIControlStateNormal];
    [self.fromButton addTarget:self action:@selector(fromButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.fromButton setTitle:[NSString stringWithFormat:@"%@ %02ld:%02ld",self.timeSelectModel.fromTitle ,(long)self.timeSelectModel.fromHours,(long)self.timeSelectModel.fromMinute] forState:UIControlStateNormal];
    [self.view addSubview:self.fromButton];
    
    self.toButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toButton.frame = CGRectMake(0, CGRectGetMaxY(self.fromButton.frame), width, kSelectTimeButtonHeight);
    [self.toButton.titleLabel setFont:[UIFont boldSystemFontOfSize:kNameFontSize]];
    [self.toButton setTitleColor:kNotificationSettingTimeColor forState:UIControlStateNormal];
    [self.toButton addTarget:self action:@selector(toButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toButton setTitle:[NSString stringWithFormat:@"%@ %02ld:%02ld",self.timeSelectModel.toTitle ,(long)self.timeSelectModel.toHours,(long)self.timeSelectModel.toMinute] forState:UIControlStateNormal];
    [self.view addSubview:self.toButton];
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake((width-kSelectTimePickerWidth)/2.0,CGRectGetMaxY(self.toButton.frame)+kSelectTimePickerPading, kSelectTimePickerWidth, kSelectTimePickerHeight)];
    self.datePicker.locale = [NSLocale systemLocale];
    self.datePicker.calendar = [NSCalendar currentCalendar];
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker.minuteInterval = 1;
    [self.datePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.datePicker];
    [self didTimeSelectButtonAtIndex:0];
}

- (void)datePickerDateChanged:(UIDatePicker *)picker
{
    self.needRefresh = YES;
    NSDateComponents *components = [self.datePicker.calendar components: NSCalendarUnitHour|NSCalendarUnitMinute fromDate:picker.date];
    if (self.selectIndex == WLTimeSelectButtonIndexFrom) {
        self.timeSelectModel.fromHours = components.hour;
        self.timeSelectModel.fromMinute = components.minute;
        [self.fromButton setTitle:[NSString stringWithFormat:@"%@ %02ld:%02ld",self.timeSelectModel.fromTitle ,(long)self.timeSelectModel.fromHours,(long)self.timeSelectModel.fromMinute] forState:UIControlStateNormal];
    } else {
        self.timeSelectModel.toHours = components.hour;
        self.timeSelectModel.toMinute = components.minute;
        [self.toButton setTitle:[NSString stringWithFormat:@"%@ %02ld:%02ld",self.timeSelectModel.toTitle ,(long)self.timeSelectModel.toHours,(long)self.timeSelectModel.toMinute] forState:UIControlStateNormal];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.needRefresh) {
        self.needRefresh = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshNotificationSelectTime:)]){
            [self.delegate refreshNotificationSelectTime:self.timeSelectModel];
        }
    }
}

- (void)didTimeSelectButtonAtIndex:(WLTimeSelectButtonIndex)index
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    self.selectIndex = index;
    if (self.selectIndex == WLTimeSelectButtonIndexFrom) {
        components.hour = self.timeSelectModel.fromHours;
        components.minute = self.timeSelectModel.fromMinute;
        [self.fromButton setBackgroundColor:kSelectTimeButtonFillColor];
        [self.toButton setBackgroundColor:[UIColor whiteColor]];
    } else {
        components.hour = self.timeSelectModel.toHours;
        components.minute = self.timeSelectModel.toMinute;
        [self.fromButton setBackgroundColor:[UIColor whiteColor]];
        [self.toButton setBackgroundColor:kSelectTimeButtonFillColor];
    }
    NSDate *newDate = [self.datePicker.calendar dateFromComponents:components];
    self.datePicker.date = newDate;
}

- (void)fromButtonClicked:(UIButton *)sender
{
    [self didTimeSelectButtonAtIndex:WLTimeSelectButtonIndexFrom];
}

- (void)toButtonClicked:(UIButton *)sender
{
    [self didTimeSelectButtonAtIndex:WLTimeSelectButtonIndexTo];
}

@end
