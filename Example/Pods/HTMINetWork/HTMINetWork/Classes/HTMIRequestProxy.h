//
//  HTMIRequestProxy.h
//  Pods
//
//  Created by wlq on 2017/4/28.
//
//

#ifndef HTMIRequestProxy_h
#define HTMIRequestProxy_h

typedef void(^suceesBlock)(NSURLSessionDataTask *task, id reponseObject);
typedef void(^failureBlock)(NSURLSessionDataTask *task, NSError *error);
typedef void(^HTMIProxyCallback)(HTMIResponse * response);
typedef void(^multipart)(id<AFMultipartFormData>);
typedef NS_ENUM(NSInteger, RequestType) {
    REQUEST_GET = 0,
    REQUEST_POST,
    REQUEST_UPLOAD,
    REQUEST_FormUrl
};


#endif /* HTMIRequestProxy_h */
