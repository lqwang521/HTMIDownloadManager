//
//  SecondTestApi.h
//  HTMINetworkDemo
//
//  Created by sharejoy_HTMI on 16-09-05.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMIBaseRequest.h"

#import "HTMILogFunctionFinishApi.h"

@interface HTMILogFunctionStartApi : HTMIBaseRequest <HTMIBaseRequestDelegate, HTMIBaseRequestParamDelegate,HTMIBaseRequestHeaderDelegate,HTMIBaseRequestCallBackDelegate>

/**
 接口的开始时间，毫秒级别的
 */
@property (nonatomic,assign,readonly)double startTime;

/**
 中间接口的结束时间，毫秒级别的
 */
@property (nonatomic,assign,readonly)double functionFinishTime;

/**
 日志方法id
 */
@property (nonatomic,copy,readonly)NSString *functionLogId;

/**
 方法Code
 */
@property (nonatomic,copy,readonly)NSString *functionCode;

/**
 设置参数
 
 @param functionCode 方法Code
 */
- (void)setParams:(NSString *)functionCode;


/**
 获取消耗的时间差 毫秒级别的
 
 @return 时间差
 */
- (NSString *)getConsumeMillis;


/**
 调用日志结束接口
 
 @param type 是成功后调用还是失败后调用
 */
- (void)logFunctionFinish:(HTMILogFunctionType)type;


- (instancetype)initWithRequest:(HTMIBaseRequest *)request;


@end
