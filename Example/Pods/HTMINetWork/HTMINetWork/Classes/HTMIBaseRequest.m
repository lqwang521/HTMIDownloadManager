//
//  HTMIBaseRequest.m
//  HTMIProject
//
//  Created by sharejoy_HTMI on 16-10-18.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMIBaseRequest.h"
#import "HTMICache.h"
#import "AFNetworking.h"
#import "HTMINormalRequestProxy.h"
#import "HTMIHttpsRequestProxy.h"
//#import "HTMIUserdefaultHelper.h"
//#import "SVProgressHUD.h"

#define HTMISuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)



@interface HTMIJavaResponseinterpreter ()

/**
 请求成功
 */
@property (nonatomic, copy) HTMIResopnseSuccessBlock resopnseSuccessBlock;

/**
 Token失效
 */
@property (nonatomic, copy) HTMIResopnseTokenErrorBlock resopnseTokenErrorBlock;

@end

@implementation HTMIJavaResponseinterpreter

- (instancetype)initWithResopnseSuccessBlock:(HTMIResopnseSuccessBlock)resopnseSuccessBlock resopnseTokenErrorBlock:(HTMIResopnseTokenErrorBlock)resopnseTokenErrorBlock {
    
    self = [super init];
    if (self) {
        self.resopnseSuccessBlock = resopnseSuccessBlock;
        self.resopnseTokenErrorBlock = resopnseTokenErrorBlock;
    }
    return self;
}

@end

@interface HTMIDotNetResponseinterpreter ()

/**
 请求成功
 */
@property (nonatomic, copy) HTMIResopnseSuccessBlock resopnseSuccessBlock;

/**
 Token失效
 */
@property (nonatomic, copy) HTMIResopnseTokenErrorBlock resopnseTokenErrorBlock;

@end

@implementation HTMIDotNetResponseinterpreter

- (instancetype)initWithResopnseSuccessBlock:(HTMIResopnseSuccessBlock)resopnseSuccessBlock resopnseTokenErrorBlock:(HTMIResopnseTokenErrorBlock)resopnseTokenErrorBlock {

    self = [super init];
    if (self) {
        self.resopnseSuccessBlock = resopnseSuccessBlock;
        self.resopnseTokenErrorBlock = resopnseTokenErrorBlock;
    }
    return self;
}

@end

@interface HTMIBaseRequest ()

/** 返回信息 */
@property (nonatomic, strong, readwrite) HTMIResponse *response;
//@property (nonatomic, copy, readwrite) NSString *responseMessage;
@property (nonatomic, copy, readwrite) NSString * responseCode;
/** 状态类型: 默认/成功/返回数据不正确/参数错误/超时/网络故障 */
@property (nonatomic, assign, readwrite) HTMIBaseRequestState requestState;
/** 请求id(app生命周期内递增) */
@property (nonatomic, strong) NSMutableArray *requestIdList;
/** 缓存对象 */
@property (nonatomic, strong) HTMICache *cache;


@property (nonatomic, copy) HTMIReuqestCallback successBlock;
@property (nonatomic, copy) HTMIReuqestCallback failBlock;

@end

@implementation HTMIBaseRequest

#pragma mark - --getters and setters
- (HTMICache *)cache
{
    if (_cache == nil) {
        _cache = [HTMICache sharedInstance];
    }
    return _cache;
}

- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}

- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

- (BOOL)isLoading
{
    return [self.requestIdList count] > 0;
}

#pragma mark - --life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate = nil;
        _paramSource = nil;
        _headerSource = nil;
        _responseMessage = nil;
        _Success = NO;
        _requestState = HTMIBaseRequestStateDefault;
        
        _parameterDic = [NSMutableDictionary dictionary] ;
        _httpHeaderDic = [NSMutableDictionary dictionary];
        NSString *accessToken =   [[HTMINormalRequestProxy sharedInstance] defaultLoadAccessToken];//[HTMIUserdefaultHelper defaultLoadAccessToken];
        NSString *refreshToken =  [[HTMINormalRequestProxy sharedInstance] defaultLoadRefreshToken];//[HTMIUserdefaultHelper defaultLoadRefreshToken];
        
        [_httpHeaderDic setValue:accessToken forKey:@"accessToken"];
        [_httpHeaderDic setValue:refreshToken forKey:@"refreshToken"];
        NSString * deviceId = [HTMINormalRequestProxy sharedInstance].deviceId;
        if(deviceId) {
            [_httpHeaderDic setValue:deviceId forKey:@"deviceSn"];
        }
        if ([self conformsToProtocol:@protocol(HTMIBaseRequestDelegate)]) {
            self.child = (id <HTMIBaseRequestDelegate>)self;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - --公有方法
+ (void)cancelRequestWith:(NSArray<HTMIBaseRequest *> *)requestArray {
    for (HTMIBaseRequest *request in requestArray) {
        if ([request isKindOfClass:[self class]]) {
            [request cancelAllRequests];
        }
    }
}

- (void)cancelAllRequests
{
    [[HTMINormalRequestProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [[HTMIHttpsRequestProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}


- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[HTMINormalRequestProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
    [[HTMIHttpsRequestProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (void)deleteCache
{
    NSString *methodName = [self getMethodName];
    [self.cache deleteCacheWithMethodName:methodName];
}

#pragma mark - --发起请求
- (NSInteger)loadData
{
    if ([self shouldCallAPIWithParams:nil]) {
        //参数等通过代理获得, 所以即使是子类, 也一定要遵守协议, 实现代理
        NSDictionary *params = [self.paramSource paramsForRequest:self];
        NSDictionary *headers = [self.headerSource headersForRequest:self];
        NSDictionary *uploads = [self.uploadsSource uploadsForRequest:self];
        
        //重置请求结果和status
        self.requestState = HTMIBaseRequestStateDefault;
        self.response = nil;
        self.responseCode = @"";
        
        //loadData是子类调用父类方法实现的
        NSInteger requestId = [self loadDataWithParams:params headers:headers uploads:uploads];
        return requestId;
        
    } else {
        [self failedOnCallingAPI:nil withErrorType:HTMIBaseRequestStateParamsError];
        return 0;
    }
}

- (NSInteger)loadDataWithSuccess:(HTMIReuqestCallback)success fail:(HTMIReuqestCallback)fail
{
    self.successBlock = success;
    self.failBlock = fail;
    
    if ([self shouldCallAPIWithParams:nil]) {
        //参数等通过代理获得, 所以即使是子类, 也一定要遵守协议, 实现代理
        NSDictionary *params = [self.paramSource paramsForRequest:self];
        NSDictionary *headers = [self.headerSource headersForRequest:self];
        NSDictionary *uploads = [self.uploadsSource uploadsForRequest:self];
        //loadData是子类调用父类方法实现的
        NSInteger requestId = [self loadDataWithParams:params headers:headers uploads:uploads];
        return requestId;
    } else {
        [self failedOnCallingAPI:nil withErrorType:HTMIBaseRequestStateParamsError];
        return 0;
    }
}

- (NSInteger)loadDataWithParams:(id)params headers:(NSDictionary*)headers uploads:(NSDictionary*) uploads
{
    if (!([self.child respondsToSelector:@selector(requestType)] &&
          [self.child respondsToSelector:@selector(requestUrl)])) {
        NSAssert(NO, @"接口类需实现requestType 与 requestUrl 方法");
        return 0;
    }
    
    NSInteger requestId = 0;
    
    id apiParams;
    if ([self.child respondsToSelector:@selector(reformParams:)]) {
        apiParams = [self.child reformParams:params];
    } else {
        apiParams = params;
    }
    
    if ([self shouldCallAPIWithParams:apiParams]) {       //通过参数决定是否发送请求
        if ([self isCorrectWithParamsData:apiParams]) {    //检查参数正确性
            
            // 先检查一下是否有缓存
            if (self.child.requestType == HTMIBaseRequestTypeGet && [self shouldCache] && [self hasCacheWithParams:apiParams]) {  //需要缓存并且有缓存
                
                //在hasCacheWithParams中已发出
                NSLog(@"%@ : 这次请求用的是缓存", NSStringFromClass([self.child class]) );
                
                return 0;
            }
            
            // 实际的网络请求
            if ([self isReachable]) {              // 有网络
                NSString *accessToken =   [[HTMINormalRequestProxy sharedInstance] defaultLoadAccessToken];//[HTMIUserdefaultHelper defaultLoadAccessToken];
                NSString *refreshToken =  [[HTMINormalRequestProxy sharedInstance] defaultLoadRefreshToken];//[HTMIUserdefaultHelper defaultLoadRefreshToken];
                
                NSMutableDictionary * mDic = [NSMutableDictionary dictionary];
                [mDic setValue:accessToken forKey:@"accessToken"];
                [mDic setValue:refreshToken forKey:@"refreshToken"];
                if ([HTMINormalRequestProxy sharedInstance].deviceId) {
                    [mDic setValue:[HTMINormalRequestProxy sharedInstance].deviceId forKey:@"deviceSn"];
                }
                headers = mDic;
                switch (self.child.requestType)    // get/post/upload
                {
                    case HTMIBaseRequestTypeGet:
                    {
                        if (![self.child.requestUrl hasPrefix:@"https123"]) {
                            requestId = [[HTMINormalRequestProxy sharedInstance] callGETWithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(HTMIResponse *response) {
                                
                                [self successedOnCallingAPI:response];
                                
                            } fail:^(HTMIResponse *response) {
                                
                                [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateNetError];
                                
                            }];
                        }
                        else{
                            requestId = [[HTMIHttpsRequestProxy sharedInstance] callGETWithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(HTMIResponse *response) {
                                
                                [self successedOnCallingAPI:response];
                                
                            } fail:^(HTMIResponse *response) {
                                
                                [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateNetError];
                                
                            }];
                        }
                        
                        
                        [self.requestIdList addObject:@(requestId)];
                    }
                        
                        break;
                        
                    case HTMIBaseRequestTypePost:
                    {
                        if (![self.child.requestUrl hasPrefix:@"https123"]) {
                            requestId = [[HTMINormalRequestProxy sharedInstance] callPOSTWithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(HTMIResponse *response) {
                                
                                [self successedOnCallingAPI:response];
                                
                            } fail:^(HTMIResponse *response) {
                                
                                [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateNetError];
                                
                            }];
                        }else{
                            requestId = [[HTMIHttpsRequestProxy sharedInstance] callPOSTWithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(HTMIResponse *response) {
                                
                                [self successedOnCallingAPI:response];
                                
                            } fail:^(HTMIResponse *response) {
                                
                                [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateNetError];
                                
                            }];
                        }
                        
                        
                        [self.requestIdList addObject:@(requestId)];
                    }
                        break;
                        
                    case HTMIBaseRequestTypeUpload:
                    {
                        if (![self.child.requestUrl hasPrefix:@"https123"]) {
                            requestId = [[HTMINormalRequestProxy sharedInstance] callUPLOADWithParams:apiParams url:self.child.requestUrl headers:headers uploads:uploads methodName:self.getMethodName success:^(HTMIResponse *response) {
                                
                                [self successedOnCallingAPI:response];
                                
                            } fail:^(HTMIResponse *response) {
                                
                                [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateNetError];
                                
                            }];
                        }else{
                            requestId = [[HTMIHttpsRequestProxy sharedInstance] callUPLOADWithParams:apiParams url:self.child.requestUrl headers:headers uploads:uploads methodName:self.getMethodName success:^(HTMIResponse *response) {
                                
                                [self successedOnCallingAPI:response];
                                
                            } fail:^(HTMIResponse *response) {
                                
                                [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateNetError];
                                
                            }];
                        }
                        
                        
                        [self.requestIdList addObject:@(requestId)];
                    }
                        break;
                    case HTMIBaseRequestTypeFormUrl:
                    {
                        if (![self.child.requestUrl hasPrefix:@"https123"]) {
                            requestId = [[HTMINormalRequestProxy sharedInstance] callFormUrlWithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(HTMIResponse *response) {
                                
                                [self successedOnCallingAPI:response];
                                
                            } fail:^(HTMIResponse *response) {
                                
                                [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateNetError];
                                
                            }];
                        }else{
                            requestId = [[HTMIHttpsRequestProxy sharedInstance] callFormUrlWithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(HTMIResponse *response) {
                                
                                [self successedOnCallingAPI:response];
                                
                            } fail:^(HTMIResponse *response) {
                                
                                [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateNetError];
                                
                            }];
                        }
                        
                        [self.requestIdList addObject:@(requestId)];
                    }
                        break;
                        
                    default:
                        break;
                }
                
                //wlq delete 可能是数组
                /*
                 NSMutableDictionary *params = [apiParams mutableCopy];
                 if ([params isKindOfClass:[NSDictionary class]]) {
                 params[HTMINRequestId] = @(requestId);
                 }
                 */
                
                [self afterCallingAPIWithParams:apiParams];
                return requestId;
                
            } else {
                [self failedOnCallingAPI:nil withErrorType:HTMIBaseRequestStateNoNetWork];//网络故障,没网
                return requestId;
            }
        } else {
            [self failedOnCallingAPI:nil withErrorType:HTMIBaseRequestStateParamsError];
            return requestId;
        }
        
    } else {
        [self failedOnCallingAPI:nil withErrorType:HTMIBaseRequestStateParamsError];
        return requestId;
    }
}


#pragma mark - API回调执行的方法
- (void)successedOnCallingAPI:(HTMIResponse *)response
{
    self.requestState = HTMIBaseRequestStateSuccess;
    self.response = response;
    self.responseCode = response.responseCode;
    self.responseMessage = response.responseMessage;
    
    [self removeRequestIdWithRequestID:response.requestId];
    
    if ([self isCorrectWithResponseData:response.content]) {
        
        if (self.child.requestType == HTMIBaseRequestTypeGet && [self shouldCache] && !response.isCache) {
            
            //检查get请求/需要缓存/不是缓存数据  就保存缓存
            [self.cache saveCacheWithData:response.responseData methodName:[self getMethodName] requestParams:response.requestParams];
        }
        //        //token非法处理
        //        if (response.responseCode == 403000) {
        //            [HTMINotice postNotificationName:HTMILogoutNotification object:nil];
        //            return;
        //        }
        
        [self beforePerformSuccessWithResponse:response];
        
        
        //多请求 分发
        if ([self.delegate respondsToSelector:@selector(requestSuccessDicWithClassStrAndSELStr)]) {
            [self dispatchService];
            
        } else {
            
            if ([self.delegate respondsToSelector:@selector(requestDidSuccess:)]) {
                [self.delegate requestDidSuccess:self];
            } else {
                if (self.successBlock) {
                    self.successBlock(self);
                    self.successBlock = nil;
                }
            }
        }
        
        [self afterPerformSuccessWithResponse:response];
    } else {
        [self failedOnCallingAPI:response withErrorType:HTMIBaseRequestStateContentError];
    }
}


-(void)dispatchService
{
    for (NSString *str in [self.delegate requestSuccessDicWithClassStrAndSELStr].allKeys) {
        if ([self isKindOfClass:NSClassFromString(str)]) {
            SEL sel = NSSelectorFromString([[self.delegate requestSuccessDicWithClassStrAndSELStr] objectForKey:str]);
            if (sel) {
                HTMISuppressPerformSelectorLeakWarning
                (
                 [self.delegate performSelector:sel withObject:self]
                 );
                return;
            }
        }
    }
}

- (void)failedOnCallingAPI:(HTMIResponse *)response withErrorType:(HTMIBaseRequestState)errorType
{
    self.requestState = errorType;
    self.response = response;
    self.responseCode = response.responseCode;
    self.responseMessage = response.responseMessage;
    if (self.requestState == HTMIBaseRequestStateContentError) {//请求结果错误

        //[HTMIErrorTipTool showHTMIErrorTip:request.response.responseMessage];
    }
    
    [self removeRequestIdWithRequestID:response.requestId];
    
    if (errorType == HTMIBaseRequestStateNetError) {
        if (response.status == HTMIResponseStatusTimeout) {
            self.requestState = HTMIBaseRequestStateTimeout;
        }
    }
    if (errorType == HTMIBaseRequestStateNoNetWork) {
        self.requestState = HTMIBaseRequestStateNoNetWork;
    }
    
    [self beforePerformFailWithResponse:response];
    
    if ([self.delegate respondsToSelector:@selector(requestDidFailed:)]) {
        [self.delegate requestDidFailed:self];
    } else {
        if (self.failBlock) {
            self.failBlock(self);
            self.failBlock = nil;
        }
    }
    
    [self afterPerformFailWithResponse:response];
    
    /*
     //HTMIBaseRequest 可以在这里实现错误弹窗
     switch (self.requestState) {
     case HTMIBaseRequestStateNetError:
     #ifdef DEBUG
     [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"http错误 %@", NSStringFromClass([self class])]];
     
     #else
     [SVProgressHUD showWithStatus:@"http错误"];
     #endif
     break;
     
     case HTMIBaseRequestStateContentError:
     #ifdef DEBUG
     [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"返回数据内容错误 %@", NSStringFromClass([self class])]];
     
     #else
     [SVProgressHUD showWithStatus:@"返回数据内容错误"];
     #endif
     break;
     
     case HTMIBaseRequestStateParamsError:
     
     #ifdef DEBUG
     [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"参数错误 %@", NSStringFromClass([self class])]];
     
     #else
     [SVProgressHUD showWithStatus:@"参数错误"];
     #endif
     break;
     
     case HTMIBaseRequestStateTimeout:
     #ifdef DEBUG
     [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"网络超时 %@", NSStringFromClass([self class])]];
     
     #else
     [SVProgressHUD showWithStatus:@"网络超时"];
     
     #endif
     break;
     
     case HTMIBaseRequestStateNoNetWork:
     [SVProgressHUD showWithStatus:@"网络异常, 请检查网络设置"];
     break;
     
     default:
     break;
     }
     */
    
    
}




#pragma mark - --BaseManager实现的子类或者代理的方法


/** 是否允许调用接口 */
- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params
{
    return YES;
}

/** 调用接口之后做的操作 */
- (void)afterCallingAPIWithParams:(id)params
{
    
}

/** 接口返回成功，返回控制器回调requestDidSuccess之前的操作 */
- (void)beforePerformSuccessWithResponse:(HTMIResponse *)response
{
    if(self.dotNetResponseinterpreter) {

        if ([response.content isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary * MessageDic = [response.content objectForKey:@"Message"];
            
            if ([MessageDic isKindOfClass:[NSDictionary class]]) {
                
                NSString * Status = [NSString stringWithFormat:@"%@",[response.content objectForKey:@"Status"]];
                NSString * StatusCode = [NSString stringWithFormat:@"%@",[MessageDic objectForKey:@"StatusCode"]];
                
                if ([StatusCode isEqualToString:@"200"] && [Status isEqualToString:@"1"]) {
                    
                    if(self.dotNetResponseinterpreter.resopnseSuccessBlock) {
                        self.Success = YES;
                        self.dotNetResponseinterpreter.resopnseSuccessBlock(self);
                    }
                }
                else if ([Status isEqualToString:@"900"]) {//token失效
                    
                    if(self.dotNetResponseinterpreter.resopnseTokenErrorBlock) {
                        self.dotNetResponseinterpreter.resopnseTokenErrorBlock(self);
                    }
                }
                else {
                    self.Success = NO;
                }
            }
            else{
                self.Success = NO;
            }
        }
        else {
            self.Success = NO;
        }
    }
    else if (self.javaResponseinterpreter) {
        
        if ([response.content isKindOfClass:[NSDictionary class]]) {
            
            NSString * code = [NSString stringWithFormat:@"%@",[response.content objectForKey:@"code"]];
            
            if ([code isEqualToString:@"200"]) {
                if(self.javaResponseinterpreter.resopnseSuccessBlock) {
                    self.Success = YES;
                    self.javaResponseinterpreter.resopnseSuccessBlock(self);
                }
            }
            else if([code isEqualToString:@"900"]) {//token失效
                
                if(self.javaResponseinterpreter.resopnseTokenErrorBlock) {
                    self.javaResponseinterpreter.resopnseTokenErrorBlock(self);
                }
            }
            else{
                self.Success = NO;
            }
        }
        else{
            self.Success = NO;
        }
    }
}

/** 接口返回失败，返回控制器回调requestDidFailed之前的操作 */
- (void)beforePerformFailWithResponse:(HTMIResponse *)response
{
    
}

/** 接口返回成功，返回控制器回调requestDidSuccess之后的操作 */
- (void)afterPerformSuccessWithResponse:(HTMIResponse *)response
{
    
}

/** 接口返回失败，返回控制器回调requestDidFailed之后的操作 */
- (void)afterPerformFailWithResponse:(HTMIResponse *)response
{
    
}

#pragma mark -- 验证器(validator)方法
-(BOOL)isCorrectWithParamsData:(NSDictionary*)params
{
    if ([self.validator respondsToSelector:@selector(request:isCorrectWithParamsData:)]) {
        return [self.validator request:self isCorrectWithParamsData:params];
    }else{
        return YES;
    }
}

-(BOOL)isCorrectWithResponseData:(NSDictionary*)data
{
    if ([self.validator respondsToSelector:@selector(request:isCorrectWithResponseData:)]) {
        return [self.validator request:self isCorrectWithResponseData:data];
    }else{
        return YES;
    }
}


-(NSString*)getMethodName
{
#warning HTMIBaseRequest 实际项目用真是的 token 作为缓存的 key
    //    NSString *methodName = [NSString stringWithFormat:@"%@_%@_%@",[self convertRequestType:self.child.requestType], HTMIAPPDelegate.token ? HTMIAPPDelegate.token : @"token", self.child.requestUrl];
    NSString *methodName = [NSString stringWithFormat:@"%@_%@_%@",[self convertRequestType:self.child.requestType], @"token", self.child.requestUrl];
    
    return methodName;
}

- (BOOL)shouldCache
{
    return kHTMINNeedCache;
}

#pragma mark - --私有方法
- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}

- (BOOL)hasCacheWithParams:(NSDictionary *)params
{
    NSString *methodName = [self getMethodName];
    NSData *result = [self.cache fetchCachedDataWithAPIResources:methodName  requestParams:params];
    
    if (result == nil) {
        return NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        HTMIResponse *response = [[HTMIResponse alloc] initWithData:result];
        response.requestParams = params;
        [self successedOnCallingAPI:response];
    });
    return YES;
}



- (NSString*)convertRequestType:(HTMIBaseRequestType)type
{
    NSString* str;
    switch (type) {
        case HTMIBaseRequestTypePost:
            str = @"POST";
            break;
        case HTMIBaseRequestTypeGet:
            str = @"GET";
            break;
        case HTMIBaseRequestTypeUpload:
            str = @"UPLOAD";
            break;
        default:
            break;
    }
    return str;
}

- (void)setSuccess:(BOOL)Success{
    _Success = Success;
    if (!Success) {
        [self failedOnCallingAPI:self.response withErrorType:HTMIBaseRequestStateContentError];
    }
}

@end



