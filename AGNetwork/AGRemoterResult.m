//
//  AGOperationResult.m
//  AboveGEM
//
//  Created by traintrackcn on 18/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGRemoterResult.h"
#import "DSReachabilityManager.h"


@implementation AGRemoterResult

#pragma mark -

- (BOOL)isError{
    if (self.code == 200) return NO;
    if (self.code == 201) return NO;
    return YES;
}



#pragma mark - properties



- (NSString *)errorType{
    return self.error.code;
}

- (NSString *)errorMessage{
    return self.error.message;
}



@end
