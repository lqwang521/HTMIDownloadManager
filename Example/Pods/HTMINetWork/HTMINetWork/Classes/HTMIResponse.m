//
//  HTMIResponse.m
//  HTMIProject
//
//  Created by sharejoy_HTMI on 16-10-18.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMIResponse.h"


@interface HTMIResponse()

/** 响应状态 */
@property (nonatomic, assign, readwrite) HTMIResponseStatus status;
/** 回调json字符串 */
@property (nonatomic, copy, readwrite) NSString *contentString;
/** 回调对象, 字典或者数组 */
@property (nonatomic, copy, readwrite) id content;
/** 请求记录id (app生命周期内递增不会减少) */
@property (nonatomic, assign, readwrite) NSInteger requestId;
/** 请求 */
@property (nonatomic, copy, readwrite) NSURLRequest *request;
/** 回调json的二进制Data */
@property (nonatomic, copy, readwrite) NSData *responseData;
/** 回调json的实际数据字典(不含返回码及message) */
@property (nonatomic, copy, readwrite) NSDictionary *result;
/** 返回码 */
@property (nonatomic,assign, readwrite) NSString * responseCode;
/** 返回message */
//@property (nonatomic,copy, readwrite) NSString *responseMessage;
/** 错误信息 */
@property (nonatomic, strong, readwrite) NSError *error;
/** 是否是缓存数据 */
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation HTMIResponse


#warning HTMIResponse 以下三个方法都需要根据自己公司返回格式定制

#pragma mark - life cycle
//成功走这里, 这里需要根据公司不同格式定制
- (instancetype)initWithRequestId:(NSNumber *)requestId request:(NSURLRequest *)request params:(NSDictionary *)params reponseObject:(id)reponseObject
{
    self = [super init];
    if (self) {
        self.status = HTMIResponseStatusSuccess;
        self.requestId = [requestId integerValue];
        self.request = request;
        self.requestParams = params;
        
        if (reponseObject) {
            self.responseData = [NSJSONSerialization dataWithJSONObject:reponseObject options:NSJSONWritingPrettyPrinted error:nil];
#ifdef DEBUG
            NSString *contentString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
            self.contentString = contentString;
#else
            
#endif
            self.content = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:NULL];
            
            self.responseCode =  [self getResponseCode];
            self.responseMessage = [self getResponseMessage];
        }
        else{
            self.content = nil;
        }
        
        self.result = self.content;
        self.isCache = NO;
        
        NSLog(@"url : %@\n successCode : %@", self.request.URL, self.responseCode);
    }
    return self;
}



//错误走这里, 这里需要根据公司不同格式定制
- (instancetype)initWithRequestId:(NSNumber *)requestId request:(NSURLRequest *)request params:params error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.status = [self responseStatusWithError:error];
        
        self.requestId = [requestId integerValue];
        self.request = request;
        self.requestParams = params;
        
        NSError *underError = error.userInfo[@"NSUnderlyingError"];
        NSData *responseData = underError.userInfo[@"com.alamofire.serialization.response.error.data"];
        self.responseData = responseData;
        self.contentString = @"";
        self.error = error;
        
        if (responseData) {
            self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
            
            self.responseCode = [self getResponseCode];
            self.result = self.content;
            
        } else {
            self.content = nil;
        }
        
        self.isCache = NO;
        
        NSLog(@"url : %@\n successCode : %@", self.request.URL, self.responseCode);
    }
    return self;
}

// 使用initWithData的response，它的isCache是YES，上面两个函数生成的response的isCache是NO
- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        self.status = HTMIResponseStatusSuccess;
        
        self.requestId = 0;
        self.request = nil;
        
        self.responseData = [data copy];
        
        if (self.responseData) {
            
            
            
#ifdef DEBUG
            NSString *contentString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
            self.contentString = contentString;
#else
            
#endif
            self.content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
            
            self.responseCode = [self getResponseCode];
            self.responseMessage = [self getResponseMessage];
            
        }
        else{
            self.content = nil;
        }
        
        self.result = self.content;
        
        self.isCache = YES;
        
        NSLog(@"url : %@\n successCode : %@", self.request.URL, self.responseCode);
    }
    return self;
}

#pragma mark - private methods
- (HTMIResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        HTMIResponseStatus result = HTMIResponseStatusNoNetwork;
        
        NSLog(@"url : %@\n errorCode: %zd\n errorMessage: %@",self.request.URL ,error.code, error.userInfo[@"NSLocalizedDescription"]);
        
        //wlq add 错误信息也放到responseMessage中
        NSString * errorString = error.userInfo[@"NSLocalizedDescription"];
        if (errorString.length > 0) {
            self.responseMessage = errorString;
        }
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = HTMIResponseStatusTimeout;
        }
        return result;
    } else {
        return HTMIResponseStatusSuccess;
    }
}

- (NSString *)getValueFrom:(id)value{
    
    if (!value || value == [NSNull null]) {
        return @"";
    }
    else{
        return [NSString stringWithFormat:@"%@",value];
    }
}

- (NSString *)getResponseCode{
    
    if ([self.content isKindOfClass:[NSDictionary class]]) {
        
        NSString * code = [self getValueFrom:[self.content objectForKey:@"code"]];
        
        
        if (code.length > 0) {
            
            return code;
        }
        else{
            
            NSDictionary * MessageDic = [self.content objectForKey:@"Message"];
            
            if ([MessageDic isKindOfClass:[NSDictionary class]]){
                
                NSString * StatusCode = [self getValueFrom:[MessageDic objectForKey:@"StatusCode"]];
                
                if (StatusCode.length > 0 && ![StatusCode isKindOfClass:[NSNull class]]) {
                    return StatusCode;
                }
                else{
                    return @"";
                }
            }
            else{
                return @"";
            }
        }
    }
    else{
        return @"";
    }
}

- (NSString *)getResponseMessage{
    
    if ([self.content isKindOfClass:[NSDictionary class]]) {
        
        NSString * message = [self getValueFrom:[self.content objectForKey:@"message"]];
        
        if (message.length > 0 && ![message isKindOfClass:[NSNull class]]) {
            
            return message;
        }
        else{
            
            NSDictionary * MessageDic = [self.content objectForKey:@"Message"];
            
            if ([MessageDic isKindOfClass:[NSDictionary class]]){
                
                NSString * StatusMessage = [self getValueFrom:[MessageDic objectForKey:@"StatusMessage"]];
                
                if (StatusMessage.length > 0 && ![StatusMessage isKindOfClass:[NSNull class]]) {
                    return StatusMessage;
                }
                else{
                    return @"";
                }
            }
            else{
                return @"";
            }
        }
    }
    else{
        return @"";
    }
}

- (id)setNoNull:(id)aValue{
    if (aValue == nil) {
        aValue = @"";//为null时，直接赋空
    } else if ((NSNull *)aValue == [NSNull null]) {
        aValue = @"";
        if ([aValue isEqual:nil]) {
            aValue = @"";
        }
    }
    return aValue;
}


@end
