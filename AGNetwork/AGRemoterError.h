//
//  AGRemoterResultError.h
//  AboveGEM
//
//  Created by traintrackcn on 19/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGModel.h"

@class AGRemoterResult;
@interface AGRemoterError : AGModel

- (void)parseErrorUserInfo:(id)userInfo;

- (id)request;
- (id)response;
- (id)recoverySuggestion;
- (id)headers;
- (NSArray *)messages;

@property (nonatomic, weak) AGRemoterResult *result;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *developMessage;
@property (nonatomic, strong) NSString *localizedDesc;
@property (nonatomic, strong) NSURL *failingURL;




@end
