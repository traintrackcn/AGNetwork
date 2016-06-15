//
//  AGOperationResult.m
//  AboveGEM
//
//  Created by traintrackcn on 18/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGRemoterResult.h"
#import "AGRemoterResultError.h"

@implementation AGRemoterResult

#pragma mark -

- (NSString *)type{
    NSString *str = [NSString stringWithFormat:@"%ld",(long)self.code];
    
    if ([self isCanceled]) {
        str = @"CANCELED";
    }else if([self isTimeout]){
        str = @"TIMEOUT";
    }else if ([self isNotModified]){
        str = @"Not Modified";
    }
    
    return str;
}

- (BOOL)isTimeout{
    if (self.code==504 || self.code == 0) return YES;
    return NO;
}

- (BOOL)isNotModified{
    if (self.code == 304) return YES;
    return NO;
}

- (BOOL)isInvalidAuthentication{
    if (self.code == 401) return YES;
    return NO;
}

- (BOOL)isCanceled{
    if (self.code == 1) return YES;
    return NO;
}

- (BOOL)isInvalidConnection{
    if (self.code == 0) return YES;
    return NO;
}

- (BOOL)isError{
    if (self.code == 200) return NO;
    if (self.code == 201) return NO;
    if (self.code == 204) return NO;
    if (self.code == 304) return NO; //content not modified
    return YES;
}



#pragma mark - properties



- (NSString *)errorType{
    return self.errorParsed.type;
}

- (NSString *)errorMessage{
    return self.errorParsed.message;
}



@end
