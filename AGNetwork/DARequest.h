//
//  DARequestBox.h
//  Distributors
//
//  Created by Tao Yunfei on 4/21/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "AGModel.h"

@class AGRemoteUnit;

@interface DARequest : AGModel{
    
}

+ (instancetype)instance;
- (void)cancel;

- (AGRemoteUnit *)rUnit;

- (NSInteger)method;
- (id)requestType:(id)userInfo;
- (id)requestBody:(id)userInfo;
- (id)requestBinary:(id)userInfo;
//- (id)requestForm:(id)userInfo;
- (id)thirdPartyUrl:(id)userInfo;
- (id)thirdParthHeaders:(id)userInfo;
- (id)headers:(id)userInfo;
- (id)protocolVersion:(id)userInfo;
- (NSTimeInterval)timeoutInterval;

- (void)requestWithCompletion:(void (^)(id, id))completion;
- (void)requestWithCompletion:(void (^)(id, id))completion userInfo:(id)userInfo;
- (void)requestSuccessfulWithCompletion:(void (^)(id, id))completion data:(id)data  userInfo:(id)userInfo;
- (void)requestFailedWithCompletion:(void(^)(id,id))completion error:(id)error userInfo:(id)userInfo;

@property (nonatomic, assign) BOOL randomRequestId;
@property (nonatomic, assign) BOOL hideActivityIndicator;

@end
