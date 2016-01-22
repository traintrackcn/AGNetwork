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
    [requset setIsThirdParty:YES];
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

- (NSData*)data{
    
    if ([self contentBinary] != nil) return [self contentBinary];
    
    if ([self contentJSON] != nil)  {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:[self contentJSON] options:NSJSONWritingPrettyPrinted error:&error];
        if(error){
            TLOG(@"error occurend when converting to JSON %@", error);
            return nil;
        }
        return data;
    }
    
    return nil;
}

- (NSString *)method{
    if (_method!=nil) return _method;
    
    if ([self contentBinary] != nil) return HTTP_METHOD_PUT;
    if ([self contentJSON] != nil) return HTTP_METHOD_POST;
    
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
    
    if ([self isThirdParty]) {
        [self setAllHTTPHeaderFields:[AGNetworkDefine singleton].defaultHeadersForThirdParty];
        if(self.defaultBody) [self setHTTPBody:self.defaultBody];
    }else{
        
        @try {
            [self setURL:self.defaultURL];
            [self setAllHTTPHeaderFields:[AGNetworkDefine singleton].defaultHeaders];
            if(self.defaultBody) [self setHTTPBody:self.defaultBody];
            if (self.isForOrder) [self setValue:self.headerForPostingOrder forHTTPHeaderField:@"X-Client-Request-Id"];
            
        }@catch (NSException *exception) {
            TLOG(@"exception -> %@", exception);
        }
        
    }
}


- (NSData *)defaultBody{
    if (!_defaultBody) {
        _defaultBody = [[self data] mutableCopy];
        if (!_defaultBody) return nil;
        
        //write binary data to body
        if ([self contentBinary]!=nil) {
            NSString *hexRandom = [NSString stringWithFormat:@"%06X", (arc4random() % 16777216)];
            NSString *boundary = hexRandom;
            [self setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:HTTP_HEAD_CONTENT_TYPE];

            _defaultBody = [NSMutableData data];
            [_defaultBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [_defaultBody appendData:[@"Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [_defaultBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [_defaultBody appendData:[self data]];
            [_defaultBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

        // Write to local disk for test
        //            NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
        //            [data writeToFile:[NSString stringWithFormat:@"%@/postBody", bundlePath] atomically:YES];
            
            NSString *headerForContentLength = [NSString stringWithFormat:@"%ld", (unsigned long)[_defaultBody length]];
            [self setValue:headerForContentLength forHTTPHeaderField:@"Content-Length"];
        }
        
        
    }
    
    return _defaultBody;
}


@end
