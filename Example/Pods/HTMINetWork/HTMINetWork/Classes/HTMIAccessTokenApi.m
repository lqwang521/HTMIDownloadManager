//
//  SecondTestApi.m
//  HTMINetworkDemo
//
//  Created by sharejoy_HTMI on 16-09-05.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMIAccessTokenApi.h"
#import "HTMINormalRequestProxy.h"


@interface HTMIAccessTokenApi()<HTMIBaseRequestCallBackDelegate>


/**
 功能API，不需要具体类型
 */
@property (nonatomic,weak,readwrite)HTMIBaseRequest *baseRequest;

@property (nonatomic,copy) RefreshAccessTokenSuccessBlcok refreshAccessTokenSuccessBlcok;

@end

@implementation HTMIAccessTokenApi

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

- (instancetype)initWithRequest:(HTMIBaseRequest *)request {
    return [self initWithRequest:request refreshAccessTokenSuccessCallBack:nil];
}

- (instancetype)initWithRequest:(HTMIBaseRequest *)request refreshAccessTokenSuccessCallBack:(RefreshAccessTokenSuccessBlcok)refreshAccessTokenSuccessCallBack {
    
    self = [super init];
    
    if (self) {
        self.paramSource = self;
        self.headerSource = self;
        self.baseRequest = request;
        
        self.refreshAccessTokenSuccessBlcok = refreshAccessTokenSuccessCallBack;
    }
    return self;
}

- (NSInteger)loadData {
    
    if (self.delegate == nil) {//如果外部没有声明代理那么使用自己作为代理
        self.delegate = self;
    }
    
    return [super loadData];
}

- (NSInteger)loadDataWithSuccess:(HTMIReuqestCallback)success fail:(HTMIReuqestCallback)fail {
    
    if (self.delegate == nil) {//如果外部没有声明代理那么使用自己作为代理
        self.delegate = self;
    }
    
    return [super loadDataWithSuccess:success fail:fail];
}

- (HTMIBaseRequestType)requestType {
    return HTMIBaseRequestTypePost;
}

- (BOOL)shouldCache {
    return NO;
}

- (NSString *)requestUrl {
    
    NSString *urlPath = [NSString stringWithFormat:@"%@/accesstokencontroller/accesstoken",[HTMINormalRequestProxy sharedInstance].baseUrl];
    
    return urlPath;
}

- (NSDictionary *)headersForRequest:(HTMIBaseRequest *)request {
    
    NSMutableDictionary *mDic = [self.httpHeaderDic mutableCopy];
    
    NSString *accessToken =   [[HTMINormalRequestProxy sharedInstance] defaultLoadAccessToken];//[HTMIUserdefaultHelper defaultLoadAccessToken];
    NSString *refreshToken =  [[HTMINormalRequestProxy sharedInstance] defaultLoadRefreshToken];//[HTMIUserdefaultHelper defaultLoadRefreshToken];
    
    [mDic setValue:accessToken forKey:@"accessToken"];
    [mDic setValue:refreshToken forKey:@"refreshToken"];
    
    if([HTMINormalRequestProxy sharedInstance].deviceId) {
        [mDic setValue:[HTMINormalRequestProxy sharedInstance].deviceId forKey:@"deviceSn"];
    }
    
    self.httpHeaderDic = mDic;
    return self.httpHeaderDic;
}

- (id)paramsForRequest:(HTMIBaseRequest *)request {
    
    return [self.parameterDic copy];
}

- (void)beforePerformSuccessWithResponse:(HTMIResponse *)response {
    [super beforePerformSuccessWithResponse:response];
    
    //成功了，将token保存
    if ([response.content isKindOfClass:[NSDictionary class]]) {
        
        NSString * code = [NSString stringWithFormat:@"%@",[response.content objectForKey:@"code"]];
        
        if ([code isEqualToString:@"200"]) {
            
            NSDictionary * resultDic = [response.content objectForKey:@"result"];
            
            //将token进行存储
            //[HTMIUserdefaultHelper defaultSaveRefreshToken:[NSString stringWithFormat:@"%@",[resultDic objectForKey:@"refreshToken"]]];
            //[HTMIUserdefaultHelper defaultSaveAccessToken:[NSString stringWithFormat:@"%@",[resultDic objectForKey:@"accessToken"]]];
            [[HTMINormalRequestProxy sharedInstance] defaultSaveRefreshToken:
             [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"refreshToken"]]];
            [[HTMINormalRequestProxy sharedInstance] defaultSaveAccessToken:[NSString stringWithFormat:@"%@",[resultDic objectForKey:@"accessToken"]]];
            
            self.response.finialResult = @"200";
            
            //返回成功
            self.Success = YES;
        }
        else if([code isEqualToString:@"900"]){
            
            //利用runtime遍历属性，如果属性是accessToken属性
            self.response.finialResult = @"900";
            //返回成功
            self.Success = YES;//特殊处理，
        }
        else{
            self.Success = NO;
        }
    }
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
            [self loadData];//刷新Token
        }
        else {
            if (self.refreshAccessTokenSuccessBlcok) {
                self.refreshAccessTokenSuccessBlcok();
            }
        }
    }
}

/**
 请求失败响应方法
 
 @param request 请求
 */
- (void)requestDidFailed:(HTMIBaseRequest *)request {
    //    HTMILogError(@"%@",@"刷新tonken接口请求失败");
}

@end
