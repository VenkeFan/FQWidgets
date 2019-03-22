//
//  WLLocationRequest.m
//  welike
//
//  Created by gyb on 2018/5/29.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLLocationManager.h"
#import "WLNearbyLocationsRequest.h"
#import "WLSearchLocationRequest.h"

@interface WLLocationManager ()

@property (nonatomic, strong) WLNearbyLocationsRequest *locationsRequest;
@property (nonatomic, copy) NSString *cursor;


@property (nonatomic, strong) WLSearchLocationRequest *searchLocationRequest;
@property (nonatomic, copy) NSString *searchCursor;

@end


@implementation WLLocationManager

-(void)listNearbyLocations:(CLLocationCoordinate2D)coordinate result:(listLocationsCompleted)complete
{
    if (self.locationsRequest != nil)
    {
        [self.locationsRequest cancel];
        self.locationsRequest = nil;
    }
    
    self.cursor = nil;
    
    __weak typeof(self) weakSelf = self;
    self.locationsRequest = [[WLNearbyLocationsRequest alloc] initNearbyLocations:coordinate];
    [self.locationsRequest nearbyLocationsWithCursor:self.cursor successed:^(NSArray *locations, NSString *cursor){
        
        weakSelf.locationsRequest = nil;
        self.cursor = cursor;
        BOOL last;
        if (cursor.length > 0)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(locations, last, ERROR_SUCCESS);
                
            }
        });
        
        
    } error:^(NSInteger errorCode) {
        
//        NSLog(@"====================================%d",errorCode);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, NO, errorCode);
            }
        });
    }];
}

-(void)listNearbyLocationsFromBottom:(CLLocationCoordinate2D)coordinate result:(listLocationsCompleted)complete
{
    if (self.locationsRequest != nil || self.cursor == nil) return;
    
    __weak typeof(self) weakSelf = self;
    self.locationsRequest = [[WLNearbyLocationsRequest alloc] initNearbyLocations:coordinate];
    [self.locationsRequest nearbyLocationsWithCursor:self.cursor successed:^(NSArray *locations, NSString *cursor){
        
        weakSelf.locationsRequest = nil;
        self.cursor = cursor;
        BOOL last;
        if (cursor.length > 0)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(locations, last, ERROR_SUCCESS);
                
            }
        });
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, NO, errorCode);
            }
        });
    }];
}


-(void)listSearchLocations:(CLLocationCoordinate2D)coordinate key:(NSString *)key result:(listLocationsCompleted)complete
{
    if (self.searchLocationRequest != nil)
    {
        [self.searchLocationRequest cancel];
        self.searchLocationRequest = nil;
    }
    
    self.searchCursor = nil;
    
    __weak typeof(self) weakSelf = self;
    self.searchLocationRequest = [[WLSearchLocationRequest alloc] initSearchLocations:coordinate keyStr:key];
    [self.searchLocationRequest SearchLocationsWithCursor:self.searchCursor successed:^(NSArray *locations, NSString *cursor){
        
        weakSelf.searchLocationRequest = nil;
        self.searchCursor = cursor;
        BOOL last;
        if (cursor.length > 0)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(locations, last, ERROR_SUCCESS);
                
            }
        });
        
        
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, NO, errorCode);
            }
        });
    }];
}

-(void)listSearchLocationsFromBottom:(CLLocationCoordinate2D)coordinate key:(NSString *)key result:(listLocationsCompleted)complete
{
    if (self.searchLocationRequest != nil || self.searchCursor == nil) return;
    
    __weak typeof(self) weakSelf = self;
    self.searchLocationRequest = [[WLSearchLocationRequest alloc] initSearchLocations:coordinate keyStr:key];
    [self.searchLocationRequest SearchLocationsWithCursor:self.searchCursor successed:^(NSArray *locations, NSString *cursor){
        
        weakSelf.searchLocationRequest = nil;
        self.searchCursor = cursor;
        BOOL last;
        if (cursor.length > 0)
        {
            last = NO;
        }
        else
        {
            last = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(locations, last, ERROR_SUCCESS);
                
            }
        });
    } error:^(NSInteger errorCode) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete)
            {
                complete(nil, NO, errorCode);
            }
        });
    }];
}


@end
