//
//  DSRequestData.m
//  DirectSale
//
//  Created by Sean Guo on 7/16/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//



#import "DSRequestInfo.h"
#import "GlobalDefine.h"
#import "DSValueUtil.h"
#import "AGNetworkMacro.h"
#import "DSDeviceUtil.h"
#import "AGNetworkDefine.h"
#import "NSObject+Singleton.h"
#import "AGRequestBinary.h"

@interface DSRequestInfo(){
    
}


@property (nonatomic, strong) NSString *headerForPostingOrder;
@property (nonatomic, strong) NSURL *defaultURL;
@property (nonatomic, strong) NSMutableData *defaultBody;

@end

@implementation DSRequestInfo

//- (instancetype)init{
//    @throw [NSException exceptionWithName:@"init is invalid" reason:@"please use AGRemoter GET/POST" userInfo:nil];
//}

+ (instancetype)instance{
    DSRequestInfo *requestInfo = [[DSRequestInfo alloc] init];
    return requestInfo;
}

#pragma mark - properties

- (NSURL *)defaultURL{
    if (!_defaultURL) {
        NSMutableString* urlStr = [NSMutableString stringWithString:@"/"];
        if (self.protocolVersion) [urlStr appendString:self.protocolVersion];
        if (self.requestType) [urlStr appendFormat:@"/%@",self.requestType];
        _defaultURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.serverUrl, urlStr]];
    }
    return _defaultURL;
}

- (NSString *)method{
    if (_method) return _method;
    return HTTP_METHOD_GET;
}

- (NSString *)key{
    return [[self URL] absoluteString];
}

- (NSString *)headerForPostingOrder{
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *uuidStr = [uuid UUIDString];
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidStr;
}

- (NSString *)protocolVersion{
    if (!_protocolVersion) return [AGNetworkDefine singleton].defaultProtocolVersion;
    return _protocolVersion;
}

- (NSString *)serverUrl{
    if (!_serverUrl) return [AGNetworkDefine singleton].defaultServerUrl;
    return _serverUrl;
}

#pragma mark - assemble request

- (void)assemble{
     @try {
        [self setHTTPMethod:[self method]];
        [self setTimeoutInterval:300];
        
        if ([self thirdPartyUrl]) {
            [self setURL:self.thirdPartyUrl];
//            TLOG(@"self.thirdPartyHeaders -> %@", self.thirdPartyHeaders);
            if (self.thirdPartyHeaders) [self setAllHTTPHeaderFields:self.thirdPartyHeaders];
        }else{
            [self setURL:self.defaultURL];
            [self setAllHTTPHeaderFields:[AGNetworkDefine singleton].defaultHeaders];
            if (self.randomRequestId) [self setValue:self.headerForPostingOrder forHTTPHeaderField:@"X-Client-Request-Id"];
        }
        if (self.defaultBody) [self setHTTPBody:self.defaultBody];
        
         TLOG(@"self.allHTTPHeaderFields -> %@", self.allHTTPHeaderFields);
        
    }@catch (NSException *exception) {
        TLOG(@"exception -> %@", exception);
    }
}


- (NSData *)defaultBodyWithRequestBody{
    NSError *error;
    if (!_defaultBody){
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.requestBody options:NSJSONWritingPrettyPrinted error:&error];
        _defaultBody = [NSMutableData dataWithData:data];
    }
    return _defaultBody;
}

- (NSData *)defaultBodyWithRequestBinaryAsForm{ // will be defaultBodyWithRequestBodyAndRequestBinary some day
    if (!_defaultBody){
        NSString *boundary = [self boundaryInstance];
        _defaultBody = [NSMutableData data];
        
        // process request body
        //        for (NSString *paramKey in self.requestBody) {
        //            NSString *paramValue = [self.requestBody objectForKey:paramKey];
        //            [_defaultBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //            [_defaultBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", paramKey] dataUsingEncoding:NSUTF8StringEncoding]];
        //            [_defaultBody appendData:[[NSString stringWithFormat:@"%@\r\n", paramValue] dataUsingEncoding:NSUTF8StringEncoding]];
        //        }
        
        //json data
        //        if (self.requestBody) {
        //            NSError *error;
        //            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.requestBody options:0 error:&error];
        //            [_defaultBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //            [_defaultBody appendData:[@"Content-Disposition: form-data; name=\"data\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //            [_defaultBody appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //            [_defaultBody appendData:jsonData];
        //            [_defaultBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        //        }
        
        // process request binary
        [_defaultBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [_defaultBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", self.requestBinary.name, self.requestBinary.file] dataUsingEncoding:NSUTF8StringEncoding]];
        //            [_defaultBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [_defaultBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [_defaultBody appendData:self.requestBinary.data];
        [_defaultBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

        
        [_defaultBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *headerForContentLength = [NSString stringWithFormat:@"%ld", (unsigned long)[_defaultBody length]];
        
        //headers
        [self setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:HTTP_HEAD_CONTENT_TYPE];
        [self setValue:headerForContentLength forHTTPHeaderField:@"Content-Length"];
    }
        
    return _defaultBody;
}

- (NSData *)defaultBodyWithRequestBinary{ // will be defaultBodyWithRequestBodyAndRequestBinary some day
    if (!_defaultBody){
        _defaultBody = [NSMutableData data];
        [_defaultBody appendData:self.requestBinary.data];
//        NSString *headerForContentLength = [NSString stringWithFormat:@"%ld", (unsigned long)[_defaultBody length]];
        [self setValue:self.defaultBodyContentLength forHTTPHeaderField:@"Content-Length"];
        [self setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    }
    return _defaultBody;
}

- (id)defaultBodyContentLength{
    return [[NSNumber numberWithInteger:[_defaultBody length]] stringValue];
}

- (NSData *)defaultBody{
//    TLOG(@"self.requestBinary -> %@", self.requestBinary);
    if (self.requestBody&&!self.requestBinary) return [self defaultBodyWithRequestBody];
    if (!self.requestBody&&self.requestBinary) {
        if (self.requestBinary.sendAsForm) return [self defaultBodyWithRequestBinaryAsForm];
        return [self defaultBodyWithRequestBinary];
    }
    return [NSData data];
}


- (NSString *)boundaryInstance{
    NSString *hexRandom = [NSString stringWithFormat:@"%06X", (arc4random() % 16777216)];
    return hexRandom;
}


@end
