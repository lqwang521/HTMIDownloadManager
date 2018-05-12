//
//  HTMINormalRequestProxy.h
//  LXProject
//
//  Created by sharejoy_lx on 16-10-18.
//  Copyright © 2016年 wlx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"
#import "HTMIResponse.h"
#import "HTMIRequestProxy.h"


@interface HTMINormalRequestProxy : NSObject

/**
 baseUrl
 */
@property (nonatomic, strong, readonly) NSString *baseUrl;

/**
 位置信息
 */
@property (nonatomic, strong, readonly) NSString *positionString;

/**
 设备id
 */
@property (nonatomic, strong, readonly) NSString *deviceId;

/**
 当前登录用户名
 */
@property (nonatomic, strong, readonly) NSString *userName;

/**
 设置用户名
 
 @param userName 用户名
 */
- (void)setUserName:(NSString *)userName;

+ (instancetype)sharedInstance;

- (NSInteger)callGETWithParams:(id)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail;

- (NSInteger)callPOSTWithParams:(id)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail;

- (NSInteger)callUPLOADWithParams:(id)params url:(NSString *)url headers:(NSDictionary*)headers uploads:(NSDictionary*)uploads methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail;

- (NSInteger)callFormUrlWithParams:(id)params url:(NSString *)url headers:(NSDictionary *)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

/**
 设置基础url

 @param baseUrl 基础url
 */
- (void)setBaseUrl:(NSString *)baseUrl;

/**
 设置位置信息

 @param positionString 位置信息
 */
- (void)setPositionString:(NSString *)positionString;

/**
 设置当前设备id
 
 @param deviceId 设备id
 */
- (void)setDeviceId:(NSString *)deviceId;

/**
 accessToken
 
 @return accessToken
 */
- (NSString*)defaultLoadAccessToken;

/**
 保存AccessToken
 
 @param accessToken accessToken
 */
- (void)defaultSaveAccessToken:(NSString *)accessToken;

/**
 refreshToken
 
 @return refreshToken
 */
- (NSString *)defaultLoadRefreshToken;

/**
 保存RefreshToken
 
 @param refreshToken refreshToken
 */
- (void)defaultSaveRefreshToken:(NSString *)refreshToken;

/**
 获取当前用户id
 
 @return 当前用户id
 */
- (NSString*)defaultLoadUserID;

/**
 获取登录名
 
 @return 登录名
 */
- (NSString *)defaultLoadLoginName;

/**
 获取当前应用id
 
 @return 当前应用id
 */
- (NSString *)defaultLoadCurrentAppId;

/**
 获取当前应用版本id
 
 @return 当前应用版本id
 */
- (NSString *)defaultLoadCurrentAppVersionId;

/**
 获取当前门户id
 
 @return 当前门户id
 */
- (NSString *)defaultLoadPortalID;

/**
 处理nil参数

 @param obj 参数对象
 @return 如果是nil 返回 null
 */
+ (NSObject *)objectNotNil:(NSObject *)obj;

@end
