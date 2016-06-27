//
//  DANetworkLoader.m
//  AGNetwork
//
//  Created by Tao Yunfei on 5/19/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "DANetworkLoader.h"
#import "GlobalDefine.h"
//#import "AFHTTPClient.h"
#import "AGNetworkDefine.h"

@implementation DANetworkLoader

+ (instancetype)instance{
    return [[self.class alloc] init];
}

#pragma mark - lifecycle

- (void)dealloc{
//    TLOG(@"");
    [self cancel];
}

#pragma mark - op

- (void)cancel{
//    TLOG(@"%@", self);
//    [_client.operationQueue cancelAllOperations];
//    _client = nil;
}

#pragma mark - properties

//- (AFHTTPClient *)client{
//    if (!_client) {
//        NSURL *baseURL = [NSURL URLWithString:@""];
//        _client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
//        if (AG_NETWORK_DEFINE.allowInvalidSSL){
//            TLOG(@"allow invalid certificate");
//            [_client setAllowsInvalidSSLCertificate:YES];
//        }
//    }
//    return _client;
//}

@end
