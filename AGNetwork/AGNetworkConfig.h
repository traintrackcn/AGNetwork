//
//  AGNetworkConfig.h
//  AGNetwork
//
//  Created by traintrackcn on 23/9/14.
//  Copyright (c) 2014 AboveGEM. All rights reserved.
//

#import "AGModel.h"

@class DSRequest;
@class AGRemoterResult;


@interface AGNetworkConfig : AGModel

@property (nonatomic, strong) NSString *defaultProtocolVersion;
@property (nonatomic, strong) NSString *defaultServerUrl;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, assign) BOOL isOG;



@property (nonatomic, copy) void(^dataReceivedBlock)(id responseData, DSRequest *request);
@property (nonatomic, copy) void(^errorOccuredBlock)(AGRemoterResult *result);
@property (nonatomic, copy) void(^serverCurrentTimeReceivedBlock)(NSString *serverCurrentTime);


@end
