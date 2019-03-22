//
//  AFHttpMacros.h
//  AppFramework
//
//  Created by liubin on 13-1-9.
//  Copyright (c) 2013年 renren. All rights reserved.
//

#ifndef AppFramework_AFHttpMacros_h
#define AppFramework_AFHttpMacros_h

#import <UIKit/UIKit.h>

#define kAFHttpRequestTimeOut           15.f
#define kAFHttpRequestUploadTimeOut     60.f

typedef enum
{
    AFHttpOperationTypeNormal = 0,
    AFHttpOperationTypeUpload,
	AFHttpOperationTypeDownload
} AFHttpOperationType;

typedef enum
{
    AFHttpOperationStateReady = 0,
    AFHttpOperationStateExecuting,
    AFHttpOperationStateFinish
} AFHttpOperationState;

#endif
