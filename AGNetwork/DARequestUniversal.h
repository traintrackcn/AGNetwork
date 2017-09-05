//
//  DARequestUniversal.h
//  AGNetwork
//
//  Created by Tao Yunfei on 4/28/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "DARequest.h"
#import "NSObject+Singleton.h"

#define DA_REQUEST_UNIVERSAL_INSTANCE [DARequestUniversal instance]


@interface DARequestUniversal : DARequest

//
- (void)requestWithCompletion:(void (^)(id, id))completion method:(NSInteger)method requestType:(id)requestType requestBody:(id)requestBody protocolVersion:(id)protocolVersion;

- (void)requestWithCompletion:(void (^)(id, id))completion method:(NSInteger)method requestType:(id)requestType requestBody:(id)requestBody;
- (void)requestWithRandomRequestIdWithCompletion:(void (^)(id, id))completion method:(NSInteger)method requestType:(id)requestType requestBody:(id)requestBody;
@end
