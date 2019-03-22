//
//  LuuLogger.h
//  Luuphone
//
//  Created by liubin on 13-3-25.
//  Copyright (c) 2013年 Luuphone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LuuLogger : NSObject
{
    BOOL _enable;
    BOOL _fileMode;
    NSString *_fileName;
}

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) BOOL fileMode;
@property (nonatomic, strong) NSString *fileName;

- (void)appendTag:(NSString *)tag;
- (void)log:(NSString *)log tag:(NSString *)tag;

// singleton methods
+ (LuuLogger *)share;

@end
