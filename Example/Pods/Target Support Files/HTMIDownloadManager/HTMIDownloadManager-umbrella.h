#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HTMIDownloadManager.h"
#import "HTMIDownloadSessionManager.h"
#import "NSString+Hash.h"

FOUNDATION_EXPORT double HTMIDownloadManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char HTMIDownloadManagerVersionString[];

