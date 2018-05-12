//
//  HTMICacheObject.m
//  LXProject
//
//  Created by sharejoy_lx on 16-10-18.
//  Copyright © 2016年 wlx. All rights reserved.
//

#import "HTMICacheObject.h"
#import "HTMINetworkConfiguration.h"

@interface HTMICacheObject()

@property (nonatomic, copy, readwrite) NSData *content;
@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation HTMICacheObject


- (instancetype)initWithContent:(NSData *)content{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

- (void)updateContent:(NSData *)content{
    self.content = content;
}


- (BOOL)isEmpty{
    return nil == self.content;
}

- (BOOL)isOverdue{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return timeInterval > kHTMINCacheOverdueSeconds;
}

- (void)setContent:(NSData *)content{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}


@end
