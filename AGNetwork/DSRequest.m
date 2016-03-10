//
//  DSRequestData.m
//  DirectSale
//
//  Created by Sean Guo on 7/16/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//



#import "DSRequest.h"
#import "GlobalDefine.h"
#import "DSValueUtil.h"
#import "AGNetworkMacro.h"
#import "DSDeviceUtil.h"
#import "AGNetworkDefine.h"
#import "NSObject+Singleton.h"
#import "AGRequestBinary.h"

@interface DSRequest(){
    
}


@property (nonatomic, strong) NSString *headerForPostingOrder;
@property (nonatomic, strong) NSURL *defaultURL;
@property (nonatomic, strong) NSMutableData *defaultBody;

@end

@implementation DSRequest


+ (instancetype)instanceWithRequestType:(NSString *)requestType{
    DSRequest *request = [[DSRequest alloc] initWithRequestType:requestType];
    return request;
}

+ (instancetype)instanceWithThirdPartyUrl:(NSURL *)thirdPartyUrl{
    DSRequest *requset = [[DSRequest alloc] initWithURL:thirdPartyUrl];
    [requset setThirdParty:YES];
    return requset;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:@"init is invalid" reason:@"please use AGRemoter GET/POST" userInfo:nil];
}


- (id)initWithRequestType:(NSString*)requestType{
    self = [super init];
    if (self){
        if (requestType != nil)  [self setRequestType:requestType] ;
    }
    return self;
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
    
    if (self.requestBinary) return HTTP_METHOD_PUT;
    if (self.requestBody) return HTTP_METHOD_POST;
    
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
    
    [self setHTTPMethod:[self method]];
    [self setTimeoutInterval:300];
    
    if ([self thirdParty]) {
        [self setAllHTTPHeaderFields:[AGNetworkDefine singleton].defaultHeadersForThirdParty];
        if(self.defaultBody) [self setHTTPBody:self.defaultBody];
    }else{
        
        @try {
            [self setURL:self.defaultURL];
            [self setAllHTTPHeaderFields:[AGNetworkDefine singleton].defaultHeaders];
            if(self.defaultBody) [self setHTTPBody:self.defaultBody];
            if (self.forOrder) [self setValue:self.headerForPostingOrder forHTTPHeaderField:@"X-Client-Request-Id"];
            
        }@catch (NSException *exception) {
            TLOG(@"exception -> %@", exception);
        }
        
    }
}


- (NSData *)defaultBody{
    
    if (!self.requestBody&&!self.requestBinary) return nil;
    
    if (self.requestBody&&!self.requestBinary) {
        NSError *error;
         NSData *data = [NSJSONSerialization dataWithJSONObject:self.requestBody options:NSJSONWritingPrettyPrinted error:&error];
        if (!_defaultBody) {
            _defaultBody = [NSMutableData dataWithData:data];
        }
        return _defaultBody;
    }
    
    // requestBody & requestBinary
    if (!_defaultBody) {
        _defaultBody = [NSMutableData data];
        
        NSString *boundary = [self boundaryInstance];
        
        [self setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:HTTP_HEAD_CONTENT_TYPE];
        
        
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
        
        
        
        if (self.requestBinary) {
            [_defaultBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [_defaultBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", self.requestBinary.name, self.requestBinary.file] dataUsingEncoding:NSUTF8StringEncoding]];
//            [_defaultBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [_defaultBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [_defaultBody appendData:self.requestBinary.data];
            [_defaultBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
// Write to local disk for test
//        NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
//        [data writeToFile:[NSString stringWithFormat:@"%@/postBody", bundlePath] atomically:YES];
        
        [_defaultBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *headerForContentLength = [NSString stringWithFormat:@"%ld", (unsigned long)[_defaultBody length]];
        [self setValue:headerForContentLength forHTTPHeaderField:@"Content-Length"];

    }
    return _defaultBody;
}


- (NSString *)boundaryInstance{
    NSString *hexRandom = [NSString stringWithFormat:@"%06X", (arc4random() % 16777216)];
    return hexRandom;
}


@end
