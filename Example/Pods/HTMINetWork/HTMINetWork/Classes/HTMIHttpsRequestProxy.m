//
//  HTMINormalRequestProxy.m
//  HTMIProject
//
//  Created by sharejoy_HTMI on 16-10-18.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMIHttpsRequestProxy.h"
#import "HTMINetworkConfiguration.h"
#import "NSDictionary+HTMINetworkParams.h"

@interface HTMIHttpsRequestProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;

//AFNetworking stuff
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation HTMIHttpsRequestProxy

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
        _sessionManager.responseSerializer = response;
        
        //        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];  //都在具体请求里设置
        //        [_sessionManager.securityPolicy setAllowInvalidCertificates:NO]; //设置这句话可以支持发布测试url
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        securityPolicy.allowInvalidCertificates = YES;      //是否允许使用自签名证书
        securityPolicy.validatesDomainName = NO;           //是否需要验证域名
        _sessionManager.securityPolicy = securityPolicy;
        
        __weak typeof(self) weakSelf = self;
        
        [_sessionManager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *_credential) {
            
            /// 获取服务器的trust object
            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
            // 导入自签名证书
            
#warning 注意将你的证书加入项目，并把下面名称改为自己证书的名称
            NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"htmitech" ofType:@"cer"];
            NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
            //            if (!caCert) {
            //                NSLog(@" ===== .cer file is nil =====");
            //                return nil;
            //            }
            /*
             if (caCert) {
             NSArray *cerArray = @[caCert];
             weakSelf.sessionManager.securityPolicy.pinnedCertificates = cerArray;
             }
             */
            SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
            NSCAssert(caRef != nil, @"caRef is nil");
            
            NSArray *caArray = @[(__bridge id)(caRef)];
            NSCAssert(caArray != nil, @"caArray is nil");
            // 将读取到的证书设置为serverTrust的根证书
            OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
            SecTrustSetAnchorCertificatesOnly(serverTrust,NO);
            NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
            //选择质询认证的处理方式
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            __autoreleasing NSURLCredential *credential = nil;
            
            //NSURLAuthenticationMethodServerTrust质询认证方式
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                //基于客户端的安全策略来决定是否信任该服务器，不信任则不响应质询。
                if ([weakSelf.sessionManager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                    //创建质询证书
                    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                    //确认质询方式
                    if (credential) {
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    } else {
                        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                    }
                } else {
                    //取消挑战
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
            
            return disposition;
        }];
    }
    return _sessionManager;
}


#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static HTMIHttpsRequestProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HTMIHttpsRequestProxy alloc] init];
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

-(void)fillHeader:(NSDictionary* )headers
{
    if (nil != headers) {
        for (id key in headers) {
            [self.sessionManager.requestSerializer setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
}

@end
