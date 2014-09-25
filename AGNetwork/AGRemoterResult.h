//
//  AGOperationResult.h
//  AboveGEM
//
//  Created by traintrackcn on 18/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGModel.h"

@class AGRemoterResultError;

typedef enum {
    AGResultCodeUnknown = -9999,
    AGResultCodeInvailidConnection = 0,
    AGResultCodeOperationCancelled = 1,
    AGResultCodeTimeout = 2,
    
    DSErrorBadRequest = 400,
    AGResultCodeInvalidAuthentication= 401,
    DSErrorForbidden = 403,
    AGResultCodeCannotFindPage = 404,
    DSErrorServerInternal = 500,
    DSErrorNotImplemented = 501,
    DSErrorServiceUnavailable = 503
}AGResultCode;

@class DSRequest;

@interface AGRemoterResult : AGModel

- (BOOL)isError;

- (NSString *)errorType;
- (NSString *)errorMessage;

@property (nonatomic, assign) NSInteger code;

@property (nonatomic, strong) DSRequest *request;
@property (nonatomic, strong) id responseData;
@property (nonatomic, strong) AGRemoterResultError *errorParsed;
@property (nonatomic, strong) NSError *errorOrigin;
@property (nonatomic, strong) id responseHeaders;

@end
