//
//  AGRemoterResultError.m
//  AboveGEM
//
//  Created by traintrackcn on 19/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGRemoterResultError.h"
#import "DSValueUtil.h"

@implementation AGRemoterResultError

- (void)updateWithRaw:(id)raw{
    
    if ([DSValueUtil isAvailable:[raw objectForKey:@"error-code"]]) {
        [self setCode:[DSValueUtil toString:[raw objectForKey:@"error-code"]]];
    }
    
    if ([DSValueUtil isAvailable:[raw objectForKey:@"message"]]) {
        [self setMessage:[DSValueUtil toString:[raw objectForKey:@"message"]]];
    }
    
    if ([DSValueUtil isAvailable:[raw objectForKey:@"developer-message"]]) {
        [self setDeveloperMessage:[DSValueUtil toString:[raw objectForKey:@"developer-message"]]];
    }
    
}

@end
