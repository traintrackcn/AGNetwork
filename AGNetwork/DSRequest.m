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

@implementation DSRequest


+ (instancetype)instanceWithRequestType:(NSString *)requestType{
    DSRequest *request = [[DSRequest alloc] initWithRequestType:requestType];
    return request;
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

- (NSString *)url{
    NSMutableString* url = [NSMutableString stringWithString:@"/"];
    if ([DSValueUtil isAvailable:self.protocolVersion]) {
        [url appendString:self.protocolVersion];
    }
//    else{
//        [url appendString:[AGConfigurationCoordinator singleton].protocolVersion];
//    }
    if (_requestType){
        [url appendString:@"/"];
        [url appendString:_requestType];
    }
    return url;
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


- (void)setRequestType:(NSString *)requestType{
    _requestType = [requestType stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
//    TLOG(@"requestTypep -> %@", requestType);
}

#pragma mark - assemble request

- (void)assemble{
    @try {
        [self assembleBasic];
        [self assembleDefaultHeaders];
        [self assembleHeaders];
        
        if (self.isForOrder){
            [self assembleHeaderForPostingOrder];
        }
        
        [self assembleBody];
    }@catch (NSException *exception) {
        TLOG(@"exception -> %@", exception);
    }
}

- (void)assembleBasic{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", self.serverUrl, self.url];
    
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    [self setHTTPMethod:[self method]];
    [self setTimeoutInterval:45];
    [self setURL:url];
}

- (void)assembleDefaultHeaders{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:DS_SERVER_CONTENT_TYPE_JSON forKey:HTTP_HEAD_ACCEPT_TYPE];
    [headers setObject:[DSDeviceUtil identifier] forKey:HTTP_HEAD_DEVICE_ID];
    [headers setObject:[DSDeviceUtil identifier] forKey:HTTP_OG_HEAD_DEVICE_ID];
    [headers setObject:[DSDeviceUtil systemInfo] forKey:HTTP_HEAD_DEVICE_INFO];
    [headers setObject:@"en-US" forKey:HTTP_HEAD_ACCEPT_LANGUAGE];
    [headers setObject:DS_SERVER_CONTENT_TYPE_JSON forKey:HTTP_HEAD_CONTENT_TYPE];
    [headers setObject:@"gzip" forKey:@"Accept-Encoding"];
    [self setAllHTTPHeaderFields:headers];
}

- (void)assembleHeaders{
//    NSString *token = [AGSession singleton].token;
    if ([DSValueUtil isAvailable:self.token]){
        [self setValue:self.token forHTTPHeaderField:@"X-Authentication-Token"];
        [self setValue:self.token forHTTPHeaderField:@"X-Organo-Authentication-Token"];
    }
    
}

- (void)assembleHeaderForPostingOrder{
    NSUUID *uuid = [[NSUUID alloc] init];
    NSString *uuidStr = [uuid UUIDString];
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    [self setValue:uuidStr forHTTPHeaderField:@"X-Client-Request-Id"];
}

- (void)assembleBody{
    NSMutableData * body = [[self data] mutableCopy];
    if (!body) return;
    if ([self contentBinary]!=nil) {
        NSString *hexRandom = [NSString stringWithFormat:@"%06X", (arc4random() % 16777216)];
        NSString *boundary = hexRandom;
        [self setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:HTTP_HEAD_CONTENT_TYPE];
        
        body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[self data]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // Write to local disk for test
        //            NSString *bundlePath = [[NSBundle mainBundle] resourcePath];
        //            [data writeToFile:[NSString stringWithFormat:@"%@/postBody", bundlePath] atomically:YES];
    }
    
    [self setValue:[NSString stringWithFormat:@"%ld", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:body];
}

#pragma mark - specific types

//- (BOOL)isTypeOfGetOrderInfo{
//    if ([self.url rangeOfString:@"orders/payment-methods?country-id"].location != NSNotFound) return YES;
//    if ([self.url rangeOfString:@"orders/shipping-methods?country-id"].location != NSNotFound) return YES;
//    if ([self.url rangeOfString:@"orders/adjustments"].location != NSNotFound) return YES;
//    return NO;
//}



@end
