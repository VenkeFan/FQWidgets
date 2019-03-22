//
//  WLErrorHelper.m
//  welike
//
//  Created by 刘斌 on 2018/4/26.
//  Copyright © 2018年 redefine. All rights reserved.
//

#import "WLErrorHelper.h"

@implementation WLErrorHelper

+ (NSString *)getErrCodeTextForErrCode:(NSInteger)errCode
{
    switch (errCode)
    {
        case ERROR_NETWORK_INVALID:
        {
            return [AppContext getStringForKey:@"error_network_poor" fileName:@"error"];
        }
        case ERROR_NETWORK_RESP_INVALID:
        case ERROR_NETWORK_UNKNOWN:
        case ERROR_NETWORK_INTERNAL:
        case ERROR_NETWORK_INVALID_API:
        case ERROR_NETWORK_COMMON_PARAMS:
        {
            return [AppContext getStringForKey:@"error_not_support_service" fileName:@"error"];
        }
        case ERROR_NETWORK_UPLOAD_FAILED:
        {
            return [AppContext getStringForKey:@"error_upLoad_failed" fileName:@"error"];
        }
        case ERROR_NETWORK_TOKEN_INVALID:
        {
            return [AppContext getStringForKey:@"error_authorization_invalid" fileName:@"error"];
        }
        case ERROR_NETWORK_SMSCODE_REPEATEDLY:
        {
            return [AppContext getStringForKey:@"error_regist_verification_application_frequently" fileName:@"error"];
        }
        case ERROR_NETWORK_AUTH_PASSWORD:
        case ERROR_NETWORK_SMS_CODE:
        {
            return [AppContext getStringForKey:@"error_regist_verification_incorrect" fileName:@"error"];
        }
        case ERROR_NETWORK_AUTH_NOT_MATCH:
        case ERROR_NETWORK_AUTH_TOKEN_INVALID:
        case ERROR_LOGIN_FAILED:
        {
            return [AppContext getStringForKey:@"error_regist_Login_failed" fileName:@"error"];
        }
        case ERROR_NETWORK_APP_FORCE_UPDATE:
        {
            return [AppContext getStringForKey:@"error_api_force_update" fileName:@"error"];
        }
        case ERROR_NETWORK_APP_NOT_EXIST:
        {
            return [AppContext getStringForKey:@"error_api_version_not_exist" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_CONFLICT:
        {
            return [AppContext getStringForKey:@"error_can_not_follow_yourself" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_NICKNAME_INVALID:
        {
            return [AppContext getStringForKey:@"error_nickname_invalid" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_NICKNAME_REFUSED:
        {
            return [AppContext getStringForKey:@"error_nickname_cannot_used" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_NICKNAME_USED:
        {
            return [AppContext getStringForKey:@"error_nickname_already_exists" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_SEX_M_OUT:
        {
            return [AppContext getStringForKey:@"error_sex_modify_count_out" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_NICKNAME_M_OUT:
        {
            return [AppContext getStringForKey:@"error_nickname_modify_count_out" fileName:@"error"];
        }
        case ERROR_IM_SEND_MSG_RESOURCE_INVALID:
        {
            return [AppContext getStringForKey:@"error_message_attachment_invalid" fileName:@"error"];
        }
        case ERROR_USERINFO_NICKNAME_TOO_SHORT:
        {
            return [AppContext getStringForKey:@"error_nickname_too_short" fileName:@"error"];
        }
        case ERROR_USERINFO_NICKNAME_TOO_LONG:
        {
            return [AppContext getStringForKey:@"error_nickname_too_long" fileName:@"error"];
        }
        case ERROR_USERINFO_NICKNAME_EMPTY:
        {
            return [AppContext getStringForKey:@"error_nickname_cannot_empty" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_INTRODUCTION:
        {
            return [AppContext getStringForKey:@"error_introduction_format" fileName:@"error"];
        }
        case ERROR_POST_NOT_FOUND:
        {
            return [AppContext getStringForKey:@"error_post_deleted" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_BLOCK_ME:
        {
            return [AppContext getStringForKey:@"error_user_block_me" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_BLOCK_USER:
        {
            return [AppContext getStringForKey:@"error_user_block_user" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_DEACTIVATE:
        {
            return [AppContext getStringForKey:@"user_deactivate_message_info" fileName:@"error"];
        }
        case ERROR_NETWORK_USER_BLOCKED:
        {
            return [AppContext getStringForKey:@"user_deactivate_message_info" fileName:@"error"];
        }
        case ERROR_NETWORK_PIN_POST_MAX:
        {
            return [AppContext getStringForKey:@"pin_max" fileName:@"user"];
        }
        default:
            return nil;
    }
}

@end
