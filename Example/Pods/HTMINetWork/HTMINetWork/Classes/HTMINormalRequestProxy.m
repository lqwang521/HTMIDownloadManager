//
//  HTMINormalRequestProxy.m
//  HTMIProject
//
//  Created by sharejoy_HTMI on 16-10-18.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMINormalRequestProxy.h"
#import "HTMINetworkConfiguration.h"
#import "NSDictionary+HTMINetworkParams.h"
#import "HTMIUserDefaultHelper.h"


@interface HTMINormalRequestProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;

//AFNetworking stuff
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

//baseUrl
@property (nonatomic, strong, readwrite) NSString *baseUrl;

/**
 位置信息
 */
@property (nonatomic, strong, readwrite) NSString *positionString;

/**
 设备id
 */
@property (nonatomic, strong, readwrite) NSString *deviceId;

/**
 当前登录用户名
 */
@property (nonatomic, strong, readwrite) NSString *userName;

///**
// 扩展应用的UserDefaults（共享数据）
// */
//@property (nonatomic, strong, readwrite) NSUserDefaults *groupUserDefaults;

@end

@implementation HTMINormalRequestProxy

/**
 设置基础url
 
 @param baseUrl 基础url
 */
- (void)setBaseUrl:(NSString *)baseUrl {
    _baseUrl = baseUrl;
}

/**
 设置位置信息
 
 @param positionString 位置信息
 */
- (void)setPositionString:(NSString *)positionString {
    _positionString = positionString;
}

/**
 设置当前设备id
 
 @param deviceId 设备id
 */
- (void)setDeviceId:(NSString *)deviceId {
    _deviceId = deviceId;
}

/**
 设置用户名
 
 @param userName 用户名
 */
- (void)setUserName:(NSString *)userName {
    _userName = userName;
}

/**
 accessToken
 
 @return accessToken
 */
- (NSString*)defaultLoadAccessToken {
    //[_normalUserDefaults objectForKey:@"htmiAccessToken"] ==  nil ? @"": [_normalUserDefaults objectForKey:@"htmiAccessToken"];
    return [HTMIUserdefaultHelper defaultLoadAccessToken];
}

/**
 保存AccessToken
 
 @param accessToken accessToken
 */
- (void)defaultSaveAccessToken:(NSString *)accessToken {
    
    //    [_normalUserDefaults setObject:accessToken  forKey:@"htmiAccessToken"];
    //    [_normalUserDefaults synchronize];
    [HTMIUserdefaultHelper defaultSaveAccessToken:accessToken];
}

/**
 refreshToken
 
 @return refreshToken
 */
- (NSString *)defaultLoadRefreshToken {
    
    //[_normalUserDefaults objectForKey:@"htmiRefreshToken"] ==  nil ? @"": [_normalUserDefaults objectForKey:@"htmiRefreshToken"];
    return [HTMIUserdefaultHelper defaultLoadRefreshToken];
}

/**
 保存RefreshToken
 
 @param refreshToken refreshToken
 */
- (void)defaultSaveRefreshToken:(NSString *)refreshToken {
    //    [_normalUserDefaults setObject:refreshToken  forKey:@"htmiRefreshToken"];
    //    [_normalUserDefaults synchronize];
    [HTMIUserdefaultHelper defaultSaveRefreshToken:refreshToken];
    
}


/**
 获取当前用户id
 
 @return 当前用户id
 */
- (NSString*)defaultLoadUserID {
    
    //    NSUserDefaults *defaults = _normalUserDefaults;
    //    return [defaults objectForKey:@"UserID"] ==  nil ? @"":[defaults objectForKey:@"UserID"];
    return [HTMIUserdefaultHelper defaultLoadUserID];;
}

/**
 获取登录名
 
 @return 登录名
 */
- (NSString *)defaultLoadLoginName {
    //    [_normalUserDefaults objectForKey:@"HTMILoginName"];
    return [HTMIUserdefaultHelper defaultLoadLoginName];
}

/**
 获取当前应用id
 
 @return 当前应用id
 */
- (NSString *)defaultLoadCurrentAppId {
    
    //    NSUserDefaults *defaults=_normalUserDefaults;
    //    return [defaults objectForKey:@"htmi_AppId"] ==  nil ? @"": [defaults objectForKey:@"htmi_AppId"];
    return [HTMIUserdefaultHelper defaultLoadCurrentAppId];
}

/**
 获取当前应用版本id
 
 @return 当前应用版本id
 */
- (NSString *)defaultLoadCurrentAppVersionId {
    
    //    NSUserDefaults *defaults=_normalUserDefaults;
    //    return [defaults objectForKey:@"htmi_AppCurrentVersionId"] ==  nil ? @"": [defaults objectForKey:@"htmi_AppCurrentVersionId"];
    return [HTMIUserdefaultHelper defaultLoadCurrentAppVersionId];
}

/**
 获取当前门户id
 
 @return 当前门户id
 */
- (NSString*)defaultLoadPortalID {
    //    NSUserDefaults *defaults=_normalUserDefaults ;
    //    return [defaults objectForKey:@"HTMIPortalID"] ==  nil ? @"": [defaults objectForKey:@"HTMIPortalID"];
    return [HTMIUserdefaultHelper defaultLoadPortalID];
}

///**
// 设置当前UserDefaults
// 
// @param groupUserDefaults 扩展应用的UserDefaults（共享数据）
// */
//- (void)setupGroupUserDefaults:(NSUserDefaults *)groupUserDefaults {
//    //    _normalUserDefaults = normalUserDefaults;
//    _groupUserDefaults = groupUserDefaults;
//}

+ (NSObject *)objectNotNil:(NSObject *)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        
    }
    return obj == nil ? [NSNull null]:obj;
}

#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                                     @"text/json",
                                                                     @"text/javascript",
                                                                     @"text/html",
                                                                     @"text/xml",
                                                                     @"text/plain",
                                                                     @"image/*",nil];//声明返回的结果是json类型
        
        //设置超时时间
        [_sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _sessionManager.requestSerializer.timeoutInterval = kHTMINTimeoutSeconds;//设置请求超时时间
        [_sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        /*! 设置返回数据类型为 json, 分别设置请求以及相应的序列化器 */
        /*!
         根据服务器的设定不同还可以设置：
         json：[AFJSONResponseSerializer serializer](常用)
         http：[AFHTTPResponseSerializer serializer]
         */
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        /*! 这里是去掉了键值对里空对象的键值 */
        response.removesKeysWithNullValues = YES;
        self.sessionManager.responseSerializer = response;
        //        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];  //都在具体请求里设置
        //        [_sessionManager.securityPolicy setAllowInvalidCertificates:NO]; //设置这句话可以支持发布测试url
    }
    return _sessionManager;
}

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static HTMINormalRequestProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HTMINormalRequestProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - 公有方法
- (NSInteger)callGETWithParams:(id)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail
{
#warning 如果有加密需求，可以在这个类里设置公共的一些加密字段及value
    //    headers = [NSDictionary sjHeaderForGETComplementWithHeader:headers];
    //    params = [NSDictionary sjParamsForGETComplementWithParams:params];
    
    self.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = kHTMINCacheOverdueSeconds;
    //设置超时时间
    [_sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.sessionManager.requestSerializer.timeoutInterval = kHTMINTimeoutSeconds;//设置请求超时时间
    [self.sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [self fillHeader:headers];
    /*! 设置返回数据类型为 json, 分别设置请求以及相应的序列化器 */
    /*!
     根据服务器的设定不同还可以设置：
     json：[AFJSONResponseSerializer serializer](常用)
     http：[AFHTTPResponseSerializer serializer]
     */
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    /*! 这里是去掉了键值对里空对象的键值 */
    response.removesKeysWithNullValues = YES;
    self.sessionManager.responseSerializer = response;
    NSNumber *requestId = [self callApiWithParams:params url:url methodName:methodName requestType:REQUEST_GET success:success fail:fail upload:nil];
    
    return [requestId integerValue];
}

- (NSInteger)callPOSTWithParams:(id)params url:(NSString *)url headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail
{
    
    //    headers = [NSDictionary sjHeaderForPOSTComplementWithHeader:headers];
    
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.sessionManager.requestSerializer.timeoutInterval = kHTMINCacheOverdueSeconds;
    //设置超时时间
    [self.sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.sessionManager.requestSerializer.timeoutInterval = kHTMINTimeoutSeconds;//设置请求超时时间
    [self.sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [self fillHeader:headers];
    /*! 设置返回数据类型为 json, 分别设置请求以及相应的序列化器 */
    /*!
     根据服务器的设定不同还可以设置：
     json：[AFJSONResponseSerializer serializer](常用)
     http：[AFHTTPResponseSerializer serializer]
     */
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    /*! 这里是去掉了键值对里空对象的键值 */
    response.removesKeysWithNullValues = YES;
    self.sessionManager.responseSerializer = response;
    NSNumber *requestId = [self callApiWithParams:params url:url methodName:methodName requestType:REQUEST_POST success:success fail:fail upload:nil];
    
    return [requestId integerValue];
}

- (NSInteger)callUPLOADWithParams:(id)params url:(NSString *)url headers:(NSDictionary *)headers uploads:(NSDictionary *)uploads methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail
{
    //    headers = [NSDictionary sjHeaderForPOSTComplementWithHeader:headers];
    
    [self.sessionManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    self.sessionManager.requestSerializer.timeoutInterval = 60.0f;
    [self fillHeader:headers];
    /*! 设置返回数据类型为 json, 分别设置请求以及相应的序列化器 */
    /*!
     根据服务器的设定不同还可以设置：
     json：[AFJSONResponseSerializer serializer](常用)
     http：[AFHTTPResponseSerializer serializer]
     */
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    /*! 这里是去掉了键值对里空对象的键值 */
    response.removesKeysWithNullValues = YES;
    self.sessionManager.responseSerializer = response;
    multipart upload = ^(id<AFMultipartFormData> formData){
        NSMutableArray *filepart = [uploads objectForKey:@"fileparts"];
        NSString *filename = [uploads objectForKey:@"filename"];
        for (int i = 0; i< filepart.count; i++) {
            NSData *imageData = filepart[i];
            [formData appendPartWithFileData:imageData
                                        name:[NSString stringWithFormat:@"%@",filename]
                                    fileName:[NSString stringWithFormat:@"image%d.jpg",i]mimeType:@"image/jpeg"];
        }
    };
    NSNumber *requestId = [self callApiWithParams:params url:url methodName:methodName requestType:REQUEST_UPLOAD success:success fail:fail upload:upload];
    return [requestId integerValue];
}

//wlq add
- (NSInteger)callFormUrlWithParams:(id)params url:(NSString *)url headers:(NSDictionary *)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail
{
    //    headers = [NSDictionary sjHeaderForPOSTComplementWithHeader:headers];
    
    //这个比较特殊，需要放到请求中具体设置
    
    [self.sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    self.sessionManager.requestSerializer.timeoutInterval = kHTMINCacheOverdueSeconds;
    
    [self fillHeader:headers];
    
    //设置超时时间
    [self.sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.sessionManager.requestSerializer.timeoutInterval = kHTMINTimeoutSeconds;//设置请求超时时间
    [self.sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    /*! 设置返回数据类型为 json, 分别设置请求以及相应的序列化器 */
    /*!
     根据服务器的设定不同还可以设置：
     json：[AFJSONResponseSerializer serializer](常用)
     http：[AFHTTPResponseSerializer serializer]
     */
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    /*! 这里是去掉了键值对里空对象的键值 */
    response.removesKeysWithNullValues = YES;
    self.sessionManager.responseSerializer = response;
    NSNumber *requestId = [self callApiWithParams:params url:url methodName:methodName requestType:REQUEST_FormUrl success:success fail:fail upload:nil];
    
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSOperation *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

#pragma mark - 私有方法
/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。因为最终调用三方的主要代码都在这个方法里 */
- (NSNumber *)callApiWithParams:(id)params url:(NSString *)url methodName:(NSString *)methodName requestType:(RequestType)type success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail upload:(multipart)upload
{
    
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷(配合setter, 值才会变)
    NSNumber *requestId = [self generateRequestId];
    
    //AFN回调成功的block, 内部会将返回的参数转成HTMIAPIResponse, 在调用BaseManager中的success:(AXCallback)success的block实现回调(即从BaseManager中传进来一个block, 回调成功把这个block参数一填, 外部就回调了)
    suceesBlock sblk = ^(NSURLSessionDataTask *task, id reponseObject) {
        //假设连续发出请求, recordedRequestId连续增加, 这里的requestId为什么不会用最大的值, 因为block引用的值会引用当时该变量的值, 调用这个方法的时候, 定义了这个block时如果requestId = 2, 即使连续增长至5, 回调的时候requestId依然会是2
        NSURLSessionDataTask *storedTask = self.dispatchTable[requestId];
        
        if (storedTask == nil) {
            // 如果这个operation是被cancel的(即self.dispatchTable中对应的operation已被删除了), 那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];//成功返回数据, 删除掉request记录
        }
        
        
        HTMIResponse *response = [[HTMIResponse alloc] initWithRequestId:requestId request:task.originalRequest params:params reponseObject:reponseObject];
        
        success ? success(response) : nil;
        
    };
    
    
    failureBlock fblk =  ^(NSURLSessionDataTask *task, NSError *error) {
        
        NSURLSessionDataTask *storedTask = self.dispatchTable[requestId];
        
        if (storedTask == nil) {
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
        
        HTMIResponse *response = [[HTMIResponse alloc] initWithRequestId:requestId request:task.originalRequest params:params error:error];
        
        fail?fail(response):nil;
        
    };
    
    
    // 跑到这里的block的时候，就已经是主线程了。
    //返回的类型就是AFHTTPRequestOperation, 含请求头, 响应头等信息, 发起一个请求之后就会返回这个对象, 只不过内部的response为(null), 回调成功之后这个对象的response就会赋值真正的响应头
    NSURLSessionDataTask *urlSessionDataTask;  //返回的类型就是AFHTTPRequestOperation, 含请求头, 响应头等信息
    switch (type) {
        case REQUEST_GET:
            urlSessionDataTask = [self.sessionManager GET:url parameters:params progress:nil success:sblk failure:fblk];
            break;
        case REQUEST_POST:
            urlSessionDataTask = [self.sessionManager POST:url parameters:params progress:nil success:sblk failure:fblk];
            break;
        case REQUEST_UPLOAD:
            urlSessionDataTask = [self.sessionManager POST:url parameters:params constructingBodyWithBlock:upload progress:nil success:sblk failure:fblk];
            break;
        case REQUEST_FormUrl:{
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            
            NSDictionary *header = self.sessionManager.requestSerializer.HTTPRequestHeaders;
            
            [request setAllHTTPHeaderFields:header];
            
            [request setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            
            if (params != nil) {
                
                // http body
                NSMutableString *paraString = [NSMutableString string];
                for (NSString *key in [params allKeys]) {
                    [paraString appendFormat:@"&%@=%@", key, params[key]];
                }
                if (paraString.length > 0) {
                    [paraString deleteCharactersInRange:NSMakeRange(0, 1)]; // 删除多余的&号
                    [request setHTTPBody:[paraString dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                //设置请求体数据
                //[request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
            
            urlSessionDataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                
                if(error) {
                    
                    NSURLSessionDataTask *storedTask = self.dispatchTable[requestId];
                    
                    if (storedTask == nil) {
                        return;
                    } else {
                        [self.dispatchTable removeObjectForKey:requestId];
                    }
                    
                    HTMIResponse *response = [[HTMIResponse alloc] initWithRequestId:requestId request:urlSessionDataTask.originalRequest params:params error:error];
                    
                    fail?fail(response):nil;
                    
                }
                else{
                    //假设连续发出请求, recordedRequestId连续增加, 这里的requestId为什么不会用最大的值, 因为block引用的值会引用当时该变量的值, 调用这个方法的时候, 定义了这个block时如果requestId = 2, 即使连续增长至5, 回调的时候requestId依然会是2
                    NSURLSessionDataTask *storedTask = self.dispatchTable[requestId];
                    
                    if (storedTask == nil) {
                        // 如果这个operation是被cancel的(即self.dispatchTable中对应的operation已被删除了), 那就不用处理回调了。
                        return;
                    } else {
                        [self.dispatchTable removeObjectForKey:requestId];//成功返回数据, 删除掉request记录
                    }
                    
                    HTMIResponse *response = [[HTMIResponse alloc] initWithRequestId:requestId request:urlSessionDataTask.originalRequest params:params reponseObject:responseObject];
                    
                    success ? success(response) : nil;
                }
                
                NSLog(@"%@ %@", response, responseObject);
                
            }];
            
            [urlSessionDataTask resume];
        }
            
            break;
            
        default:
            break;
    }
    
    self.dispatchTable[requestId] = urlSessionDataTask;   //发出请求之后立即将httpRequestOperation加进dispatchTable
    return requestId;
}

//生成的id在本次APP生命周期内一直递增, 会一直记录
- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

- (void)fillHeader:(NSDictionary* )headers
{
    if (nil != headers) {
        for (id key in headers) {
            [self.sessionManager.requestSerializer setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
}

@end
