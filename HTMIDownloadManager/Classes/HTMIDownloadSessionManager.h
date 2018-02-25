//
//  HTMIDownloadManager.h
//  大文件断点下载
//
//  Created by wlq on 18/02/25.
//  Copyright © 2018年 wlq. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HTMIDownloadSessionManager : NSObject

/**
 *  继续任务
 */
- (void)resume;

/**
 *  停止下载任务
 */
- (void)suspend;

/**
 *  取消任务
 */
- (void)cancel;

/**下载方法*/
- (void)downloadFromURL:(NSString *)urlString progress:(void(^)(CGFloat downloadProgress))downloadProgressBlock complement:(void(^)(NSString *filePath,NSError *error))completeBlock;

@end
