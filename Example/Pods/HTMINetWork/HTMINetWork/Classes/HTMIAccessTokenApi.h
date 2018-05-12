//
//  SecondTestApi.h
//  HTMINetworkDemo
//
//  Created by sharejoy_HTMI on 16-09-05.
//  Copyright © 2016年 wHTMI. All rights reserved.
//

#import "HTMIBaseRequest.h"

typedef void (^RefreshAccessTokenSuccessBlcok) ();

@interface HTMIAccessTokenApi : HTMIBaseRequest <HTMIBaseRequestDelegate, HTMIBaseRequestParamDelegate,HTMIBaseRequestHeaderDelegate>

- (instancetype)initWithRequest:(HTMIBaseRequest *)request;

- (instancetype)initWithRequest:(HTMIBaseRequest *)request refreshAccessTokenSuccessCallBack:(RefreshAccessTokenSuccessBlcok)refreshAccessTokenSuccessCallBack;

@end
