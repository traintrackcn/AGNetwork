//
//  DANetworkLoader.h
//  AGNetwork
//
//  Created by Tao Yunfei on 5/19/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPClient;
@interface DANetworkLoader : NSObject

+ (instancetype)instance;

- (void)cancel;
@property (nonatomic, strong) AFHTTPClient *client;

@end
