//
//  SecondTestApi.m
//  HTMINetworkDemo
//
//  Created by sharejoy_HTMI on 16-09-05.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMILogFunctionStartApi.h"
//#import "HTMIUserdefaultHelper.h"
//#import "NSObject+JudgeNull.h"
//#import "HTMISettingManager.h"
//#import "NSString+Extention.h"
#import "HTMIAccessTokenApi.h"
//#import "HTMILocationManager.h"
//#import "HTMILocationModel.h"
//#import "HTMILoginUserModel.h"
//#import "JSONKit.h"
//#import "HTMIKeychainTool.h"
#import "HTMINormalRequestProxy.h"


@interface HTMILogFunctionStartApi()
{
}

/**
 应用id数组
 */
@property (nonatomic,copy)NSArray *appIds;

/**
 方法Code
 */
@property (nonatomic,copy,readwrite)NSString *functionCode;

///**
// 获取Token的API
// */
//@property (nonatomic,copy)HTMIAccessTokenApi *accessTokenApi;

/**
 LOG结束接口
 */
@property (nonatomic,strong)HTMILogFunctionFinishApi *logFunctionFinishApi;

/**
 接口的开始时间，毫秒级别的
 */
@property (nonatomic,assign,readwrite)double startTime;

/**
 中间接口的结束时间，毫秒级别的
 */
@property (nonatomic,assign,readwrite)double functionFinishTime;

/**
 日志方法id
 */
@property (nonatomic,copy,readwrite)NSString *functionLogId;

/**
 功能API，不需要具体类型
 */
@property (nonatomic,weak,readwrite)HTMIBaseRequest *baseRequest;

@end

@implementation HTMILogFunctionStartApi

static const BOOL kJavaApiFlag = YES;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(NO, @"禁止使用默认的初始化方法，需要使用initWithRequest");
        self.paramSource = self;
        self.headerSource = self;
    }
    return self;
}

- (instancetype)initWithRequest:(HTMIBaseRequest *)request
{
    self = [super init];
    if (self) {
        self.paramSource = self;
        self.headerSource = self;
        self.baseRequest = request;
        
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
    
    //发起请求之前设置开始时间
    self.startTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *urlPath = @"";
    if (kJavaApiFlag) {
        urlPath = [NSString stringWithFormat:@"%@/gateway/logcrabController/transmit/LogFunctionStart",[HTMINormalRequestProxy sharedInstance].baseUrl];
        
    }
    else {
        //        urlPath = [NSString stringWithFormat:@"http://%@/%@/api/AppPortLogin/LogFunctionStart",kAPI_URL,kAPI_DIR];
    }
    
    return urlPath;
}

//伪代码， 本接口不需要header， 演示一下
- (NSDictionary *)headersForRequest:(HTMIBaseRequest *)request {
    
    NSMutableDictionary *mDic = [self.httpHeaderDic mutableCopy];
    
    /*
     HTMILocationManager *manager = [HTMILocationManager manager];
     NSString *positionString = @"";
     if (manager.isEnable && manager.locationModel) {
     //locationModel 转json 传入头信息中
     positionString  = [HTMILocationModel htmi_changeModelToJsonString:[HTMILocationManager manager].locationModel];
     [mDic setValue:[NSObject objectNotNil:positionString] forKey:@"position"];
     }
     */
    
    NSString *accessToken =  [[HTMINormalRequestProxy sharedInstance] defaultLoadAccessToken];
    NSString *refreshToken =  [[HTMINormalRequestProxy sharedInstance] defaultLoadRefreshToken];
    
    if ([HTMINormalRequestProxy sharedInstance].positionString && [HTMINormalRequestProxy sharedInstance].positionString.length > 0) {
        [mDic setValue:[HTMINormalRequestProxy objectNotNil:[HTMINormalRequestProxy sharedInstance].positionString] forKey:@"position"];
    }
    [mDic setValue:accessToken forKey:@"accessToken"];
    [mDic setValue:refreshToken forKey:@"refreshToken"];
    [mDic setValue:[HTMINormalRequestProxy objectNotNil:[HTMINormalRequestProxy sharedInstance].deviceId] forKey:@"deviceSn"];
    
    self.httpHeaderDic = mDic;
    
    return self.httpHeaderDic;
}

- (id)paramsForRequest:(HTMIBaseRequest *)request {
    
    if (!self.functionCode) {
        NSAssert(NO, @"参数没有赋值");
    }
    
    NSString * appIdString = [NSString stringWithFormat:@"%@",[[HTMINormalRequestProxy sharedInstance] defaultLoadCurrentAppId]];
    //首次登录传 app_code: app_login
    if (!appIdString || appIdString.length <= 0 || [appIdString isEqualToString:@"0"]) {
        appIdString = @"";
    }
    
    NSString * appVersionIdString = [NSString stringWithFormat:@"%@",[[HTMINormalRequestProxy sharedInstance] defaultLoadCurrentAppVersionId]];
    //首次登录传 app_code: app_login
    if (!appVersionIdString || appVersionIdString.length <= 0 || [appVersionIdString isEqualToString:@"0"]) {
        
        //CFBundleShortVersionString
        appVersionIdString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    }
    
    NSDictionary *appInfoDict = @{@"portal_id":[HTMINormalRequestProxy objectNotNil:[[HTMINormalRequestProxy sharedInstance] defaultLoadPortalID]],
                                  @"app_id":[HTMINormalRequestProxy objectNotNil:appIdString],
                                  @"app_version_id":[HTMINormalRequestProxy objectNotNil:appVersionIdString]};
    NSString *userName =  [HTMINormalRequestProxy sharedInstance].userName;//[[HTMILoginUserModel shareLoginUserModel].userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSData *appInfoData = [appInfoDict JSONData];
    NSData *appInfoData = [NSJSONSerialization dataWithJSONObject:appInfoDict options:NSJSONWritingPrettyPrinted error:nil];
    NSArray *keyvalueArray = @[@{@"key":@"user_name",@"value":[HTMINormalRequestProxy objectNotNil:userName]}];
    //NSData *keyvalueData = [keyvalueArray JSONData];
    NSData *keyvalueData = [NSJSONSerialization dataWithJSONObject:keyvalueArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *appInfo = [[NSString alloc] initWithData:appInfoData encoding:NSUTF8StringEncoding];
    NSString *keyvalue = [[NSString alloc] initWithData:keyvalueData encoding:NSUTF8StringEncoding];
    //appInfo = [appInfo stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
    //keyvalue = [appInfo stringByReplacingOccurrencesOfString:@"null" withString:@"\"\""];
    NSDictionary *dic = @{};
    
    if (kJavaApiFlag) {
        dic = @{@"appInfo":[HTMINormalRequestProxy objectNotNil:appInfo],
                @"functionCode":[HTMINormalRequestProxy objectNotNil:self.functionCode],
                @"keyvalue":keyvalue,
                @"portalId":[HTMINormalRequestProxy objectNotNil:[[HTMINormalRequestProxy sharedInstance] defaultLoadPortalID]],
                @"userId":[HTMINormalRequestProxy objectNotNil:[[HTMINormalRequestProxy sharedInstance] defaultLoadUserID]],
                @"deviceInfo":[HTMINormalRequestProxy objectNotNil:[HTMINormalRequestProxy sharedInstance].deviceId],
                @"appId":[HTMINormalRequestProxy objectNotNil:appIdString],
                @"appVersionId": [HTMINormalRequestProxy objectNotNil:appVersionIdString]};
    }
    else {
        /*
         NSDictionary *logfunctionDic = @{@"deviceInfo":
         [NSObject objectNotNil:[HTMIKeychainTool getDeviceId]],
         @"functionCode":
         [NSString objectNotNil:self.functionCode],
         @"appId":[NSObject objectNotNil:appIdString] ,
         @"appVersionId": [NSObject objectNotNil:appVersionIdString]};
         NSDictionary * context = [HTMIUserdefaultHelper defaultLoadContext];
         dic = @{@"context":context,@"logfunction":logfunctionDic};
         */
    }
    
    return dic;
}

- (void)beforePerformSuccessWithResponse:(HTMIResponse *)response {
    
    if (kJavaApiFlag) {
        if ([response.content isKindOfClass:[NSDictionary class]]) {
            
            NSString * code = [NSString stringWithFormat:@"%@",[response.content objectForKey:@"code"]];
            
            if ([code isEqualToString:@"200"]) {
                
                NSDictionary * resultDic = [response.content objectForKey:@"result"];
                
                if ([resultDic isKindOfClass:[NSDictionary class]]) {
                    
                    response.finialResult = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"functionLogId"]];
                    
                    self.Success = YES;
                }
                else{
                    self.Success = NO;
                }
                
                self.Success = YES;
            }
            else if([code isEqualToString:@"900"]){//token失效
                
                //[self.accessTokenApi loadData];//刷新Token
                self.Success = NO;
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
                
                weakResponse.finialResult = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"LogFunctionId"]];
                
                weakSelf.Success = YES;
            }
            else{
                weakSelf.Success = NO;
            }
        } resopnseTokenErrorBlock:^(HTMIBaseRequest *api) {
            //            @strongify(self);
            //            [self.accessTokenApi loadData];//刷新Token
            weakSelf.Success = NO;
        }];
        [super beforePerformSuccessWithResponse:weakResponse];
    }
}

- (void)beforePerformFailWithResponse:(HTMIResponse *)response{
    [super beforePerformFailWithResponse:response];
    
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
    
    [dic setObject:NSStringFromSelector(@selector(handleLogFunctionFinishApi:)) forKey:NSStringFromClass([HTMILogFunctionFinishApi class])];
    [dic setObject:NSStringFromSelector(@selector(handleAccessTokenApi:)) forKey:NSStringFromClass([HTMIAccessTokenApi class])];
    
    return [dic copy];
}

/**
 请求失败响应方法
 
 @param request 请求
 */
- (void)requestDidFailed:(HTMIBaseRequest *)request{
    
    //不处理finish的失败
    if (![request isMemberOfClass:[HTMILogFunctionFinishApi class]]) {
        self.responseMessage = request.responseMessage;
        [self failedOnCallingAPI:request.response withErrorType:request.requestState];
    }
}

/**
 处理日志结束请求响应
 
 @param api 接口对象
 */
- (void)handleLogFunctionFinishApi:(HTMILogFunctionFinishApi *)api{
    
}

/**
 处理token请求响应
 
 @param api 接口对象
 */
- (void)handleAccessTokenApi:(HTMIAccessTokenApi *)api{
    
    //    if (api.isSuccess) {
    //        if ([api.response.finialResult isEqualToString:@"900"]) {
    //            [self.accessTokenApi loadData];//刷新Token
    //        }
    //        else{
    //            [self loadData];
    //        }
    //    }
}

/**
 设置参数
 
 @param functionCode 设置方法Code
 */
- (void)setParams:(NSString *)functionCode{
    self.functionCode = functionCode;
}

/**
 获取消耗的时间差 毫秒级别的
 
 @return 时间差
 */
- (NSString *)getConsumeMillis{
    
    double consumeMillis =  self.functionFinishTime - self.startTime;
    
    return [NSString stringWithFormat:@"%.f",consumeMillis];
}

- (void)logFunctionFinish:(HTMILogFunctionType)type{
    
    if (![self.functionLogId isEqualToString:@"0"]) {//当前的functionId如果是0，说明Start失败了，不需要调用finish
        NSString * resultInfo = @"";
        if (self.baseRequest) {
            if (self.baseRequest.responseMessage.length > 0) {
                resultInfo = self.baseRequest.responseMessage;
            }
        }
        
        [self.logFunctionFinishApi setHeader:@{@"functionLogId":self.functionLogId}];
        
        if (type == HTMILogFunctionSuccess) {
            
            [self.logFunctionFinishApi setParams:self.functionCode consumeMillis:[self getConsumeMillis] resultStatus:@"1" resultInfo:resultInfo functionLogId:self.functionLogId];
        }
        else if(type == HTMILogFunctionFailure){
            
            [self.logFunctionFinishApi setParams:self.functionCode consumeMillis:[self getConsumeMillis] resultStatus:@"2" resultInfo:resultInfo functionLogId:self.functionLogId];
        }
        else if(type == HTMILogFunctionCancel){
            
            [self.logFunctionFinishApi setParams:self.functionCode consumeMillis:[self getConsumeMillis] resultStatus:@"3" resultInfo:@"" functionLogId:self.functionLogId];
        }
        
        [self.logFunctionFinishApi loadData];
    }
}

- (void)setfunctionLogId:(NSString *)functionLogId
{
    _functionLogId = functionLogId;
}

//- (HTMIAccessTokenApi *)accessTokenApi{
//    if (!_accessTokenApi) {
//        _accessTokenApi = [[HTMIAccessTokenApi alloc]initWithRequest:self];
//        _accessTokenApi.delegate = self;
//    }
//    return  _accessTokenApi;
//}

- (double)functionFinishTime{
    
    return [[NSDate date] timeIntervalSince1970] * 1000;
}


/**
 重写父类的方法，不成功需要设置一下functionLogId
 
 @param Success 是否成功
 */
- (void)setSuccess:(BOOL)Success{
    
    if (Success) {
        
        self.functionLogId = self.response.finialResult;//需要先设置功能ID
    }
    else{
        
        self.functionLogId = @"0";
    }
    
    //[super setSuccess:Success];wlq delete 不需要处理Start的失败
}

- (HTMILogFunctionFinishApi *)logFunctionFinishApi{
    if (!_logFunctionFinishApi) {
        _logFunctionFinishApi = [[HTMILogFunctionFinishApi alloc]init];
        _logFunctionFinishApi.delegate = self;
    }
    return _logFunctionFinishApi;
}

- (NSString *)functionLogId{
    if(!_functionLogId){
        _functionLogId = @"";
    }
    return _functionLogId;
}

@end
