//
//  DANetworkLoader.m
//  AGNetwork
//
//  Created by Tao Yunfei on 5/19/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "DANetworkLoader.h"
#import "GlobalDefine.h"
#import "AFHTTPClient.h"

@implementation DANetworkLoader

+ (instancetype)instance{
    return [[self.class alloc] init];
}

#pragma mark - lifecycle

- (void)dealloc{
    [self cancel];
}

#pragma mark - op

- (void)cancel{
    [_client.operationQueue cancelAllOperations];
    _client = nil;
}

#pragma mark - properties

- (AFHTTPClient *)client{
    if (!_client) {
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
#ifdef DEBUG
        TLOG(@"allow invalid certificate");
        [_client setAllowsInvalidSSLCertificate:YES];
#endif
    }
    return _client;
}

@end
