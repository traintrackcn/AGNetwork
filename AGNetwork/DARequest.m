//
//  DARequestBox.m
//  Distributors
//
//  Created by Tao Yunfei on 4/21/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "DARequest.h"
#import "AGRemoteUnit.h"
#import "GlobalDefine.h"

@interface DARequest(){
    AGRemoteUnit *_rUnit;
}

@property (nonatomic, weak) DARequest *ws;
//@property (nonatomic, strong) AGRemoteUnit *rUnit;

@end

@implementation DARequest

+ (instancetype)instance{
    return [[self.class alloc] init];
}

- (void)dealloc{
    TLOG(@"%@", NSStringFromClass(self.class));
}

#pragma mark - 

- (void)cancel{
    [_rUnit cancel];
}

#pragma mark - remote stuff

- (void)requestWithCompletion:(void (^)(id, id))completion{
    [self requestWithCompletion:completion userInfo:nil];
}

- (void)requestWithCompletion:(void (^)(id, id))completion userInfo:(id)userInfo{
//    TLOG(@"");
    AGRemoteUnit *rUnit = [self rUnit:userInfo];
    [rUnit requestWithCompletion:^(id data, id error) {
//        TLOG(@"");
        [self.ws requestCallbackWithCompletion:completion data:data error:error userInfo:userInfo];
    }];
}

- (void)requestCallbackWithCompletion:(void (^)(id, id))completion data:(id)data error:(id)error userInfo:(id)userInfo{
//        TLOG(@"data -> %@", data);
    
    if (error) {
        completion(nil, error);
        return;
    }
    

    
    [self requestSuccessfulWithCompletion:completion data:data userInfo:userInfo];
}

- (void)requestSuccessfulWithCompletion:(void (^)(id, id))completion data:(id)data userInfo:(id)userInfo{
    completion(data, nil);
}

- (AGRemoteUnit *)rUnit:(id)userInfo{
    if (!_rUnit) {
        _rUnit = [AGRemoteUnit instance];
        [_rUnit setMethod:self.method];
    }
    
    id requestType = [self requestType:userInfo];
    id requestBody = [self requestBody:userInfo];
    id requestBinary = [self requestBinary:userInfo];
    id thirdPartyUrl = [self thirdPartyUrl:userInfo];
    id thirdPartyHeaders = [self thirdParthHeaders:userInfo];
    id headers = [self headers:userInfo];
    
    if (requestType) [_rUnit setRequestType:requestType];
    if (requestBody) [_rUnit setRequestBody:requestBody];
    if (requestBinary) [_rUnit setRequestBinary:requestBinary];
    if (thirdPartyUrl) [_rUnit setThirdPartyUrl:thirdPartyUrl];
    if (thirdPartyHeaders) [_rUnit setThirdPartyHeaders:thirdPartyHeaders];
    if (headers) [_rUnit setHeaders:headers];
//    TLOG(@"thirdPartyUrl -> %@", thirdPartyUrl);
    
//    TLOG(@"requestBody -> %@ rUnit.requestBody -> %@", requestBody, _rUnit.requestBody);
    
    [_rUnit setRandomRequestId:self.randomRequestId];
    [_rUnit setHideActivityIndicator:self.hideActivityIndicator];
    
    return _rUnit;
}

- (id)requestBody:(id)userInfo{
    return nil;
}

- (id)requestType:(id)userInfo{
    return nil;
}

- (id)requestBinary:(id)userInfo{
    return nil;
}

- (id)thirdPartyUrl:(id)userInfo{
    return nil;
}

- (id)thirdParthHeaders:(id)userInfo{
    return nil;
}

- (id)headers:(id)userInfo{
    return nil;
}

- (NSInteger)method{
    return AGRemoteUnitMethodGET;
}

#pragma mark - properties

- (AGRemoteUnit *)rUnit{
    return _rUnit;
}

- (DARequest *)ws{
    if (!_ws) {
        _ws = self;
    }
    return _ws;
}

@end
