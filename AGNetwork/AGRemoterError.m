//
//  AGRemoterResultError.m
//  AboveGEM
//
//  Created by traintrackcn on 19/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGRemoterError.h"
#import "DSValueUtil.h"
#import "GlobalDefine.h"
#import "AFURLResponseSerialization.h"


@interface AGRemoterError(){

}

@property (nonatomic, strong) id recoverySuggestion;

@end

@implementation AGRemoterError

- (void)updateWithErrorRaw:(id)raw{
    
    [self setRaw:raw];
    
    if ([self isAvailableForKey:@"error-code"]) {
        [self setType:[self stringForKey:@"error-code"]];
    }
    
    if ([self isAvailableForKey:@"code"]) {
        [self setType:[self stringForKey:@"code"]];
    }
    
    if ([self isAvailableForKey:@"message"]) {
        [self setMessage:[self stringForKey:@"message"]];
    }
    
    if ([self isAvailableForKey:@"developer-message"]) {
        [self setDevelopMessage:[self stringForKey:@"developer-message"]];
    }
    
}

#pragma mark - parser

- (void)parseErrorUserInfo:(id)userInfo{
    
    [self setLocalizedDesc:[userInfo objectForKey:@"NSLocalizedDescription"]];
    [self setFailingURL:[userInfo objectForKey:@"NSErrorFailingURLKey"]];
    
    NSString *recoverySuggestionStr = [userInfo objectForKey:@"NSLocalizedRecoverySuggestion"];
    NSData *recoverySuggestionData;
    
    if (recoverySuggestionStr) {
        recoverySuggestionData = [recoverySuggestionStr dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        recoverySuggestionData = [userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
    }
    
    
    if (recoverySuggestionData){
        [self setRecoverySuggestion:[NSJSONSerialization JSONObjectWithData:recoverySuggestionData options:NSJSONReadingAllowFragments error:nil]];
        
        //if error in meta
        if (self.error) {
            [self updateWithErrorRaw:self.error];
        }
//        else{
//            [self updateWithRaw:self.recoverySuggestion];
//        }
    }
}


#pragma mark - properties

- (id)meta{
    return [self.recoverySuggestion objectForKey:@"meta"];
}

- (id)error{
    return [self.meta objectForKey:@"error"];
}

- (id)request{
    return [self.recoverySuggestion objectForKey:@"request"];
}

- (id)headers{
    return [self.request objectForKey:@"headers"];
}

- (id)response{
    return [self.recoverySuggestion objectForKey:@"response"];
}


#pragma mark - util


- (NSArray *)messages{
    NSMutableArray *arr = [NSMutableArray array];
    
    //append message for users
    if (self.message) {
        [arr addObjectsFromArray:[self.message componentsSeparatedByString:@"\\n"]];
    }
    if (arr.count == 0) { //if no message for users, append message for developers
        if (self.localizedDesc) [arr addObject:self.localizedDesc];
        if (self.developMessage){
            if (![self.developMessage isEqualToString:@""]) [arr addObject:self.developMessage];
        }
    }

    return arr;
}

@end
