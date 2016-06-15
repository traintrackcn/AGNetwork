//
//  AGRemoterResultError.h
//  AboveGEM
//
//  Created by traintrackcn on 19/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGModel.h"

@class AGRemoterResult;
@interface AGRemoterResultError : AGModel

- (void)updateWithOriginalErrorUserInfo:(id)userInfo;
//- (void)updateWithRecoverySuggestionString:(NSString *)recoverySuggestionStr;

//@property (nonatomic, strong) id raw;
//@property (nonatomic, assign) NSInteger code;
@property (nonatomic, weak) AGRemoterResult *result;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *developMessage;
//@property (nonatomic, strong) NSArray *failures;
@property (nonatomic, strong) NSString *localizedDesc;
@property (nonatomic, strong) NSURL *failingURL;

@end
