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

@interface HTMIHttpsRequestProxy : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)callGETWithParams:(id)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail;

- (NSInteger)callPOSTWithParams:(id)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail;

- (NSInteger)callUPLOADWithParams:(id)params url:(NSString *)url headers:(NSDictionary*)headers uploads:(NSDictionary*)uploads methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail;

- (NSInteger)callFormUrlWithParams:(id)params url:(NSString *)url headers:(NSDictionary *)headers methodName:(NSString *)methodName success:(HTMIProxyCallback)success fail:(HTMIProxyCallback)fail;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
