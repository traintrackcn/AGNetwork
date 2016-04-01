//
//  AGRemoterResultError.m
//  AboveGEM
//
//  Created by traintrackcn on 19/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGRemoterResultError.h"
#import "DSValueUtil.h"
#import "GlobalDefine.h"

@implementation AGRemoterResultError


- (void)updateWithOriginalErrorUserInfo:(id)userInfo{
    NSString *recoverySuggestionStr = [userInfo objectForKey:@"NSLocalizedRecoverySuggestion"];
    if (recoverySuggestionStr) [self updateWithRecoverySuggestionString:recoverySuggestionStr];
    [self setLocalizedDesc:[userInfo objectForKey:@"NSLocalizedDescription"]];
    [self setFailingURL:[userInfo objectForKey:@"NSErrorFailingURLKey"]];
}

- (void)updateWithRecoverySuggestionString:(NSString *)recoverySuggestionStr{
    NSData *recoverySuggestionData = [recoverySuggestionStr dataUsingEncoding:NSUTF8StringEncoding];
    id recoverySuggestionRaw  = [NSJSONSerialization JSONObjectWithData:recoverySuggestionData options:NSJSONReadingAllowFragments error:nil];
//    TLOG(@"recoverySuggestionRaw -> %@", recoverySuggestionRaw);
    
    
    //if error in meta
    NSDictionary *metaRaw = [recoverySuggestionRaw objectForKey:@"meta"];
    id errorRaw = [metaRaw objectForKey:@"error"];
    if (metaRaw && errorRaw) {
        [self updateWithRaw:errorRaw];
    }else{
        [self updateWithRaw:recoverySuggestionRaw];
    }
    
}



- (void)updateWithRaw:(id)raw{
    
    
    
    [self setRaw:raw];
    
    if ([self isAvailableForKey:@"error-code"]) {
        [self setCode:[self stringForKey:@"error-code"]];
    }
    
    if ([self isAvailableForKey:@"code"]) {
        [self setCode:[self stringForKey:@"code"]];
    }
    
    if ([self isAvailableForKey:@"message"]) {
        [self setMessage:[self stringForKey:@"message"]];
    }
    
    if ([self isAvailableForKey:@"developer-message"]) {
        [self setDevelopMessage:[self stringForKey:@"developer-message"]];
    }
    
}

@end
