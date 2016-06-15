//
//  AGOperationResult.h
//  AboveGEM
//
//  Created by traintrackcn on 18/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGModel.h"

@class AGRemoterResultError;

@class DSRequestInfo;

@interface AGRemoterResult : AGModel

- (BOOL)isError;
- (BOOL)isTimeout;
- (BOOL)isCanceled;
- (BOOL)isNotModified;
- (BOOL)isInvalidAuthentication;
- (BOOL)isInvalidConnection;
- (NSString *)type;

- (NSString *)errorType;
- (NSString *)errorMessage;

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) DSRequestInfo *request;
@property (nonatomic, strong) id responseData;
@property (nonatomic, strong) AGRemoterResultError *errorParsed;
@property (nonatomic, strong) NSError *errorOrigin;
@property (nonatomic, strong) id responseHeaders;

@end
