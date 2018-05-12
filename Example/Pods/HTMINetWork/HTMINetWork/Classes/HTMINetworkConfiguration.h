//
//  HTMINetworkConfiguration.h
//  LXProject
//
//  Created by sharejoy_lx on 16-10-18.
//  Copyright © 2016年 wlx. All rights reserved.
//

#ifndef HTMINetworkConfiguration_h
#define HTMINetworkConfiguration_h

typedef NS_ENUM(NSUInteger, HTMIResponseStatus)
{
    HTMIResponseStatusSuccess,  //服务器请求成功即设置为此状态,内容是否错误由各子类验证
    HTMIResponseStatusTimeout,
    HTMIResponseStatusNoNetwork  // 默认除了超时以外的错误都是无网络错误。
};


static NSString *HTMIDeleteCacheNotification = @"HTMIDeleteCacheNotification";
static NSString *HTMIDeleteCacheKey = @"HTMIDeleteCacheKey";


//网络请求超时时间,默认设置为20秒
static NSTimeInterval kHTMINTimeoutSeconds = 10.0f;
// 是否需要缓存的标志,默认为YES
static BOOL kHTMINNeedCache = YES;
// cache过期时间 设置为30秒
static NSTimeInterval kHTMINCacheOverdueSeconds = 30;
// cache容量限制,最多100条
static NSUInteger kHTMINCacheCountLimit = 100;

#endif /* HTMINetworkConfiguration_h */
