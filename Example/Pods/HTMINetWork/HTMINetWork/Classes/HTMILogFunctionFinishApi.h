//
//  SecondTestApi.h
//  HTMINetworkDemo
//
//  Created by sharejoy_HTMI on 16-09-05.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMIBaseRequest.h"

#ifndef HTMILogFunctionType_h
#define HTMILogFunctionType_h
typedef NS_ENUM(NSInteger, HTMILogFunctionType) {
    HTMILogFunctionFailure = 0,            //功能失败.
    HTMILogFunctionSuccess = 1,            //功能成功
    HTMILogFunctionCancel = 2              //功能手动取消
    
};
#endif /* HTMILogFunctionType_h */

@interface HTMILogFunctionFinishApi : HTMIBaseRequest <HTMIBaseRequestDelegate, HTMIBaseRequestParamDelegate,HTMIBaseRequestHeaderDelegate>

/**
 设置参数
 
 @param functionCode 方法Code
 @param consumeMillis 耗时
 @param resultStatus 是否成功
 @param resultInfo 结果信息
 */
- (void)setParams:(NSString *)functionCode consumeMillis:(NSString *)consumeMillis resultStatus:(NSString *)resultStatus resultInfo:(NSString *)resultInfo functionLogId:(NSString *)functionLogId;


- (void)setHeader:(NSDictionary *)header;

@end
