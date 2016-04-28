//
//  AGNetworkConfig.h
//  AGNetwork
//
//  Created by traintrackcn on 23/9/14.
//  Copyright (c) 2014 AboveGEM. All rights reserved.
//

#import "AGModel.h"


#define HTTP_METHOD_POST @"POST"
#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_PUT @"PUT"
#define HTTP_METHOD_DELETE @"DELETE"

#define HTTP_HEAD_CONTENT_TYPE @"Content-Type"
#define HTTP_HEAD_ACCEPT_TYPE @"Accept"
#define HTTP_HEAD_ACCEPT_LANGUAGE @"Accept-Language"
//#define HTTP_HEAD_AUTH_TOKEN @"X-Authentication-Token"
#define HTTP_HEAD_DEVICE_ID @"X-Device-UUID"
#define HTTP_HEAD_DEVICE_INFO @"X-Device-Info"
#define HTTP_HEAD_WSSID_AUTH @"X-WSSID-Authorization"
#define HTTP_HEAD_COOKIE @"Cookie"

#define HTTP_OG_HEAD_DEVICE_ID @"X-Organo-Device-UUID"

#define DS_SERVER_CONTENT_TYPE_JSON @"application/json"


@class DSRequestInfo;
@class AGRemoterResult;


@interface AGNetworkDefine : AGModel

@property (nonatomic, strong) NSString *defaultProtocolVersion;
@property (nonatomic, strong) NSString *defaultServerUrl;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
//@property (nonatomic, assign) BOOL isOG;

//@property (nonatomic, strong) NSMutableDictionary *defaultHeadersForThirdParty;
@property (nonatomic, strong) NSMutableDictionary *defaultHeaders;


@property (nonatomic, copy) void(^dataReceivedBlock)(id responseData, DSRequestInfo *request);
@property (nonatomic, copy) void(^errorOccuredBlock)(AGRemoterResult *result);
@property (nonatomic, copy) void(^serverCurrentTimeReceivedBlock)(NSString *serverCurrentTime);


@end
