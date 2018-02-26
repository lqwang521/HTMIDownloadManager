//
//  HTMIDownloadManager.h
//  大文件断点下载
//
//  Created by wlq on
//  Copyright © 2018年 wlq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DownloadProgressBlock)(CGFloat progress, CGFloat totalMBRead, CGFloat totalMBExpectedToRead);
typedef void(^DownloadSuccessBlock)(id operation, id responseObject);
typedef void(^DownloadFailureBlock)(id operation, NSError *error);


@interface HTMIDownloadManager : NSObject

+ (instancetype)sharedManager;

- (void)downloadFromURL:(NSString *)urlString progress:(void(^)(CGFloat downloadProgress))downloadProgressBlock complement:(void(^)(NSString *filePath,NSError *error))completeBlock;

/**
 *  暂停某个url的下载任务
 */
- (void)suspendTaskWithURL:(NSString *)urlString;

/**
 *  暂停某个url的下载任务
 */
- (void)suspendAllTasks;

/**
 *  继续某个url的下载任务
 */
- (void)resumeTaskWithURL:(NSString *)urlString;

/**
 *  继续所有下载任务
 */
- (void)resumeAllTasks;

/**
 *  取消某个url的下载任务,取消以后必须重新设置任务
 */
- (void)cancelTaskWithURL:(NSString *)urlString;

/**
 *  取消所有下载任务,取消以后必须重新设置任务
 */
- (void)cancelAllTasks;

/**
 *  开始下载文件
 *
 *  @param URLString     文件链接
 *  @param path          本地路径 (已做处理，传个 `xx.xxx` 即可，如 `demo.mp3`)
 *  @param progressBlock 进度回调
 *  @param successBlock  成功回调
 *  @param failureBlock  失败回调
 *
 *  @return 下载任务
 */
+ (id)downloadFileWithURLString:(NSString *)URLString
                      cachePath:(NSString *)cachePath
                       progress:(DownloadProgressBlock)progressBlock
                        success:(DownloadSuccessBlock)successBlock
                        failure:(DownloadFailureBlock)failureBlock;

/**
 *  开始下载文件
 *
 *  @param URLString     文件链接
 *  @param path          本地路径 (已做处理，传个 `xx.xxx` 即可，如 `demo.mp3`)
 *  @param headers          functionCode
 *  @param progressBlock 进度回调
 *  @param successBlock  成功回调
 *  @param failureBlock  失败回调
 *
 *  @return 下载任务
 */
+ (id)downloadFileWithURLString:(NSString *)URLString
                      cachePath:(NSString *)cachePath
                        headers:(NSDictionary *)headers
                       progress:(DownloadProgressBlock)progressBlock
                        success:(DownloadSuccessBlock)successBlock
                        failure:(DownloadFailureBlock)failureBloc;

@end
