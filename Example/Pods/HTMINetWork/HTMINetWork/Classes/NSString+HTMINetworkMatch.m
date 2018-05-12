//
//  NSString+HTMINetworkMatch.m
//  LXProject
//
//  Created by sharejoy_lx on 16-10-18.
//  Copyright © 2016年 wlx. All rights reserved.
//

#import "NSString+HTMINetworkMatch.h"

@implementation NSString (HTMINetworkMatch)

- (BOOL)sjMatchWithRegex:(NSString*)regexString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexString];
    return [predicate evaluateWithObject:self];
}

@end
