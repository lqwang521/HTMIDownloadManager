//
//  HTMIBaseRequest.h
//  LXProject
//
//  Created by sharejoy_lx on 16-10-18.
//  Copyright © 2016年 wlx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMIResponse.h"

//定义网络请求ID字典名称
static NSString * const HTMINRequestId = @"HTMINRequestId";

#pragma mark -- HTMIBaseRequestState各种状态
typedef enum : NSUInteger {
    HTMIBaseRequestStateDefault,       //没有API请求，默认状态。
    HTMIBaseRequestStateSuccess,       //API请求成功且返回数据正确。
    HTMIBaseRequestStateNetError,      //API请求返回失败。
    HTMIBaseRequestStateContentError,  //API请求成功但返回数据不正确。
    HTMIBaseRequestStateParamsError,   //API请求参数错误。
    HTMIBaseRequestStateTimeout,       //API请求超时。
    HTMIBaseRequestStateNoNetWork      //网络故障。
    
} HTMIBaseRequestState;

#pragma mark -- HTTP请求方式
typedef enum : NSUInteger {
    HTMIBaseRequestTypeGet = 0,
    HTMIBaseRequestTypePost,
    HTMIBaseRequestTypeUpload,
    HTMIBaseRequestTypeFormUrl
    
} HTMIBaseRequestType;


@class HTMIBaseRequest;

#pragma mark -- 获取API所需基本设置
@protocol HTMIBaseRequestDelegate <NSObject>

@required
- (NSString *)requestUrl;
- (HTMIBaseRequestType)requestType;
@optional
- (NSString *)cacheRegexKey;
/**
 *   在调用API之前额外添加一些参数，但不应该在这个函数里面修改已有的参数
 *   如果实现这个方法, 一定要在传入的params基础上修改 , 再返回修改后的params
 *   HTMIBaseRequest会先调用这个函数，然后才会调用到 id<HTMIBaseRequestValidator> 中的 manager:isCorrectWithParamsData: 所以这里返回的参数字典还是会被后面的验证函数去验证的
 */
- (id)reformParams:(id)params;
- (BOOL)shouldCache;

@end

#pragma mark -- 获取调用API所需要的参数
@protocol HTMIBaseRequestParamDelegate <NSObject>
@required
- (id)paramsForRequest:(HTMIBaseRequest *)request;
@end

#pragma mark -- 获取调用API所需要的头部数据(一般用于携带token等)
@protocol HTMIBaseRequestHeaderDelegate <NSObject>
@required
- (NSDictionary *)headersForRequest:(HTMIBaseRequest *)request;
@end

#pragma mark -- 获取调用API所需要的上传数据
@protocol HTMIBaseRequestUploadDelegate <NSObject>
@required
- (NSDictionary *)uploadsForRequest:(HTMIBaseRequest *)manager;
@end

#pragma mark -- 接口调用的回调
@protocol HTMIBaseRequestCallBackDelegate <NSObject>
@required
- (void)requestDidSuccess:(HTMIBaseRequest *)request;
- (void)requestDidFailed:(HTMIBaseRequest *)request;
@optional
/**
 如果一个控制器内存在多个接口，并使用协议代理方式回调，则可以实现下面方法，将各个请求回调分发到各自的方法里
 注意：使用了这个方法，则对应接口的requestDidSuccess 和 successBlock 都不会被执行
 例如：字典key为接口类名，value为方法的selector字符串
 - (NSDictionary<NSString *, NSString *> *)requestDicWithClassStrAndSELStr {
 NSMutableDictionary *dic = [NSMutableDictionary dictionary];
 [dic setObject:NSStringFromSelector(@selector(handleShopListService:)) forKey:@"ShopListService"];
 [dic setObject:NSStringFromSelector(@selector(handleRelationService:)) forKey:@"RelationService"];
 。。。
 return [dic copy];
 }
 */
- (NSDictionary<NSString *, NSString *> *)requestSuccessDicWithClassStrAndSELStr;
@end



#pragma mark -- 验证器，用于验证API的返回或者调用API的参数是否正确
@protocol HTMIBaseRequestValidator <NSObject>
@required
//验证CallBack数据的正确性
- (BOOL)request:(HTMIBaseRequest *)request isCorrectWithResponseData:(NSDictionary *)data;
//验证传递的参数数据的正确性
- (BOOL)request:(HTMIBaseRequest *)request isCorrectWithParamsData:(NSDictionary *)data;
@end

typedef void(^HTMIReuqestCallback)(id api);

typedef void(^HTMIResopnseSuccessBlock)(HTMIBaseRequest *api);
typedef void(^HTMIResopnseTokenErrorBlock)(HTMIBaseRequest *api);

@interface HTMIDotNetResponseinterpreter : NSObject

- (instancetype)initWithResopnseSuccessBlock:(HTMIResopnseSuccessBlock)resopnseSuccessBlock resopnseTokenErrorBlock:(HTMIResopnseTokenErrorBlock)resopnseTokenErrorBlock;

@end

@interface HTMIJavaResponseinterpreter : NSObject

- (instancetype)initWithResopnseSuccessBlock:(HTMIResopnseSuccessBlock)resopnseSuccessBlock resopnseTokenErrorBlock:(HTMIResopnseTokenErrorBlock)resopnseTokenErrorBlock;

@end

@interface HTMIBaseRequest : NSObject

@property (nonatomic, weak) NSObject<HTMIBaseRequestDelegate> *child; //!<获取请求基本设置
@property (nonatomic, weak) id<HTMIBaseRequestParamDelegate> paramSource; //!<获取参数代理
@property (nonatomic, weak) id<HTMIBaseRequestHeaderDelegate> headerSource; //!<获取请求头代理
@property (nonatomic, weak) id<HTMIBaseRequestUploadDelegate> uploadsSource; //!<获取上传数据代理
@property (nonatomic, weak) id<HTMIBaseRequestCallBackDelegate> delegate; //!<这个代理一般为控制器，实现回调相关操作
@property (nonatomic, weak) id<HTMIBaseRequestValidator> validator; //!<验证器
@property (nonatomic, assign,getter=isSuccess) BOOL Success;//wlq add 请求是否成功，子类自己设置
/** 服务器返回的message，具体根据不同json格式在HTMIResponse中设置 */
@property (nonatomic, strong, readonly) HTMIResponse *response;
@property (nonatomic, copy, readwrite) NSString *responseMessage;
@property (nonatomic, copy, readonly) NSString * responseCode;
@property (nonatomic, readonly) HTMIBaseRequestState requestState;
/** 是否正在请求数据 */
@property (nonatomic, assign, readonly) BOOL isLoading;

/**
 请求头字典
 */
@property (nonatomic,copy,readwrite)NSDictionary *httpHeaderDic;

/**
 参数字典
 */
@property (nonatomic,copy,readwrite)NSDictionary *parameterDic;

/**
 .net接口响应解释器
 */
@property (nonatomic,strong) HTMIDotNetResponseinterpreter *dotNetResponseinterpreter;

/**
 Java接口响应解释器
 */
@property (nonatomic,strong) HTMIJavaResponseinterpreter *javaResponseinterpreter;

/** 调用接口 */
- (NSInteger)loadData;
/** 调用接口, 并以block形式处理返回数据，如果使用这种方式，则响应控制器不需要遵守HTMIBaseRequestCallBackDelegate，响应请求类也不需要设置delegate */
- (NSInteger)loadDataWithSuccess:(HTMIReuqestCallback)success fail:(HTMIReuqestCallback)fail;


- (NSInteger)loadDataWithParams:(NSDictionary *)params headers:(NSDictionary*)headers uploads:(NSDictionary*) uploads;

- (void)failedOnCallingAPI:(HTMIResponse *)response withErrorType:(HTMIBaseRequestState)errorType;

- (void)deleteCache;


+ (void)cancelRequestWith:(NSArray<HTMIBaseRequest *> *)requestArray;

//取消全部网络请求
- (void)cancelAllRequests;

//根据requestId取消网络请求
- (void)cancelRequestWithRequestId:(NSInteger)requestId;

// 拦截器方法，继承之后需要调用一下super，如果需要其他位置实现拦截， 使用代理
- (void)beforePerformSuccessWithResponse:(HTMIResponse *)response;
- (void)afterPerformSuccessWithResponse:(HTMIResponse *)response;

- (void)beforePerformFailWithResponse:(HTMIResponse *)response;
- (void)afterPerformFailWithResponse:(HTMIResponse *)response;

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params;
- (void)afterCallingAPIWithParams:(NSDictionary *)params;

@end
