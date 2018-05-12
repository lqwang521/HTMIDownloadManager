//
//  SecondTestApi.m
//  HTMINetworkDemo
//
//  Created by sharejoy_HTMI on 16-09-05.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMILogFunctionFinishApi.h"
#import "HTMIAccessTokenApi.h"
//#import "HTMIUserdefaultHelper.h"
//#import "NSObject+JudgeNull.h"
//#import "SVProgressHUD.h"
//#import "HTMISettingManager.h"
//#import "NSString+Extention.h"
#import "HTMINormalRequestProxy.h"
//#import "HTMIKeychainTool.h"


@interface HTMILogFunctionFinishApi()<HTMIBaseRequestCallBackDelegate>

/**
 应用id数组
 */
@property (nonatomic,copy)NSArray *appIds;

/**
 获取Token的API
 */
@property (nonatomic,copy)HTMIAccessTokenApi *accessTokenApi;

@end

@implementation HTMILogFunctionFinishApi

static const BOOL kJavaApiFlag = YES;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.paramSource = self;
        self.headerSource = self;
        
        self.httpHeaderDic = @{}.mutableCopy;
    }
    return self;
}

- (HTMIBaseRequestType)requestType {
    return HTMIBaseRequestTypePost;
}

- (BOOL)shouldCache {
    return NO;
}

- (NSString *)requestUrl{
    
    NSString *urlPath = @"";
    
    if (kJavaApiFlag) {
        urlPath = [NSString stringWithFormat:@"%@/gateway/logcrabController/transmit/LogFunctionFinish",[HTMINormalRequestProxy sharedInstance].baseUrl];
    }
    else {
//        urlPath = [NSString stringWithFormat:@"http://%@/%@/api/AppPortLogin/LogFunctionFinish",kAPI_URL,kAPI_DIR];
    }
    
    return urlPath;
}

//伪代码， 本接口不需要header， 演示一下
- (NSDictionary *)headersForRequest:(HTMIBaseRequest *)request {
    
    NSMutableDictionary *mDic = [self.httpHeaderDic mutableCopy];
    NSString *accessToken =   [[HTMINormalRequestProxy sharedInstance] defaultLoadAccessToken];//[HTMIUserdefaultHelper defaultLoadAccessToken];
    NSString *refreshToken =  [[HTMINormalRequestProxy sharedInstance] defaultLoadRefreshToken];//[HTMIUserdefaultHelper defaultLoadRefreshToken];
    [mDic setValue:accessToken forKey:@"accessToken"];
    [mDic setValue:refreshToken forKey:@"refreshToken"];
    if ([HTMINormalRequestProxy sharedInstance].deviceId) {
        [mDic setValue:[HTMINormalRequestProxy sharedInstance].deviceId forKey:@"deviceSn"];
    }

    self.httpHeaderDic = mDic;
    return self.httpHeaderDic;
}

- (id)paramsForRequest:(HTMIBaseRequest *)request {
    
    return self.parameterDic;
}

- (void)beforePerformSuccessWithResponse:(HTMIResponse *)response {
    
    if (kJavaApiFlag) {
        if ([response.content isKindOfClass:[NSDictionary class]]) {
            
            NSString * code = [NSString stringWithFormat:@"%@",[response.content objectForKey:@"code"]];
            
            if ([code isEqualToString:@"200"]) {
                //NSDictionary * resultDic = [response.content objectForKey:@"result"];
                //                if ([resultDic isKindOfClass:[NSDictionary class]]) {
                //                    response.finialResult = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"functionLogId"]];
                
                self.Success = YES;
                //                }
                //                else{
                //                    self.Success = NO;
                //                }
            }
            else if([code isEqualToString:@"900"]){//token失效
                
                [self.accessTokenApi loadData];//刷新Token
            }
            else{
                self.Success = NO;
            }
        }
        else{
            self.Success = NO;
        }
    }
    else {
        __weak typeof(self) weakSelf = self;
        __weak typeof(response) weakResponse = response;
        self.dotNetResponseinterpreter = [[HTMIDotNetResponseinterpreter alloc] initWithResopnseSuccessBlock:^(HTMIBaseRequest *api) {
            
            NSDictionary * resultDic = [weakResponse.content objectForKey:@"Result"];
            
            if ([resultDic isKindOfClass:[NSDictionary class]]) {
                
                weakResponse.finialResult = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"functionLogId"]];
                
                weakSelf.Success = YES;
            }
            else{
                weakSelf.Success = NO;
            }
        } resopnseTokenErrorBlock:^(HTMIBaseRequest *api) {
            
            [weakSelf.accessTokenApi loadData];//刷新Token
        }];
        [super beforePerformSuccessWithResponse:weakResponse];
    }
    
}

- (void)beforePerformFailWithResponse:(HTMIResponse *)response{
    [super beforePerformFailWithResponse:response];
    
//    [SVProgressHUD dismiss];
}

#pragma mark --------- HTMIBaseRequestCallBackDelegate --------

/**
 请求成功
 
 @param request 请求
 */
- (void)requestDidSuccess:(HTMIBaseRequest *)request {
    
}

//写这个是为了演示多个接口， 实际本Demo只有一个，可以直接写requestDidSuccess里或者block
- (NSDictionary<NSString *, NSString *> *)requestSuccessDicWithClassStrAndSELStr {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:NSStringFromSelector(@selector(handleAccessTokenApi:)) forKey:NSStringFromClass([HTMIAccessTokenApi class])];
    return [dic copy];
}

/**
 处理token请求响应
 
 @param api 接口对象
 */
- (void)handleAccessTokenApi:(HTMIAccessTokenApi *)api{
    
    if (api.isSuccess) {
        if ([api.response.finialResult isEqualToString:@"900"]) {
            [self.accessTokenApi loadData];//刷新Token
        }
        else{
            [self loadData];
        }
    }
}

/**
 请求失败响应方法
 
 @param request 请求
 */
- (void)requestDidFailed:(HTMIBaseRequest *)request {
    
}

/**
 设置参数
 
 @param functionCode 方法Code
 @param consumeMillis 耗时
 @param resultStatus 是否成功
 @param resultInfo 结果信息
 */
- (void)setParams:(NSString *)functionCode consumeMillis:(NSString *)consumeMillis resultStatus:(NSString *)resultStatus resultInfo:(NSString *)resultInfo functionLogId:(NSString *)functionLogId{
    
    //    if (!(functionCode && consumeMillis && resultStatus)) {
    //        NSAssert(NO, @"参数没有赋值");
    //    }
    NSDictionary *dic = @{};
    if (kJavaApiFlag) {
        dic = @{@"deviceInfo": [HTMINormalRequestProxy objectNotNil:[HTMINormalRequestProxy sharedInstance].deviceId],
                @"functionCode":[HTMINormalRequestProxy objectNotNil:functionCode],
                @"consumeMillis": [HTMINormalRequestProxy objectNotNil:consumeMillis],
                @"userId":[HTMINormalRequestProxy objectNotNil:[[HTMINormalRequestProxy sharedInstance] defaultLoadUserID]],
                @"keyvalue":[HTMINormalRequestProxy objectNotNil:[[HTMINormalRequestProxy sharedInstance] defaultLoadLoginName]],
                @"resultStatus":[HTMINormalRequestProxy objectNotNil:resultStatus],
                @"resultInfo":[HTMINormalRequestProxy objectNotNil:resultInfo],
                @"functionLogId":[HTMINormalRequestProxy objectNotNil:functionLogId]
                };
    }
    else {
        /*
        NSDictionary * context = [HTMIUserdefaultHelper defaultLoadContext];
        NSDictionary *logfunctionDic = @{@"deviceInfo": [NSObject objectNotNil:[HTMIKeychainTool getDeviceId]],
                                         @"functionCode":[NSString objectNotNil:functionCode],
                                         @"consumeMillis": [NSString objectNotNil:consumeMillis],
                                         @"resultStatus":[NSString objectNotNil:resultStatus],
                                         @"resultInfo":[NSString objectNotNil:resultInfo],
                                         @"functionLogId":[NSString objectNotNil:functionLogId]
                                         };
        
        dic = @{@"context":context,@"logfunction":logfunctionDic};
         */
    }

    NSMutableDictionary *mDic = [self.httpHeaderDic mutableCopy];
    [mDic setValue:[HTMINormalRequestProxy objectNotNil:[HTMINormalRequestProxy objectNotNil:functionLogId]] forKey:@"functionLogId"];
    self.httpHeaderDic = mDic;
    self.parameterDic = dic;
}

/**
 设置请求头
 
 @param header 请求头
 */
- (void)setHeader:(NSDictionary *)header {
    NSMutableDictionary * mDic = [NSMutableDictionary dictionaryWithDictionary:self.httpHeaderDic];
    if (header != nil && [header isKindOfClass:[NSDictionary class]]) {
        [mDic setValuesForKeysWithDictionary:header];
    }
    self.httpHeaderDic = [mDic copy];
}

- (HTMIAccessTokenApi *)accessTokenApi{
    if (!_accessTokenApi) {
        _accessTokenApi = [[HTMIAccessTokenApi alloc]initWithRequest:self];
        _accessTokenApi.delegate = self;
    }
    return  _accessTokenApi;
}

@end
