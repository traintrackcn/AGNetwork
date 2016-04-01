//
//  AGNetworkConfig.m
//  AGNetwork
//
//  Created by traintrackcn on 23/9/14.
//  Copyright (c) 2014 AboveGEM. All rights reserved.
//

#import "AGNetworkDefine.h"
#import "NSObject+Singleton.h"
#import "DSDeviceUtil.h"
#import "AGNetworkMacro.h"

@implementation AGNetworkDefine

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaultProtocolVersion:[aDecoder decodeObjectForKey:@"default-protocol-version"]];
        //        [self setToken:[aDecoder decodeObjectForKey:@"token"]];
        [self setDefaultServerUrl:[aDecoder decodeObjectForKey:@"default-server-url"]];
        [self setToken:[aDecoder decodeObjectForKey:@"token"]];
        [self setClientID:[aDecoder decodeObjectForKey:@"client-id"]];
        [self setClientSecret:[aDecoder decodeObjectForKey:@"client-secret"]];
//        [self setIsOG:[[aDecoder decodeObjectForKey:@"is-og"] boolValue]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.defaultProtocolVersion forKey:@"default-protocol-version"];
    //    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.defaultServerUrl forKey:@"default-server-url"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.clientID forKey:@"client-id"];
    [aCoder encodeObject:self.clientSecret forKey:@"client-secret"];
//    [aCoder encodeObject:[NSNumber numberWithBool:self.isOG] forKey:@"is-og"];
}



#pragma mark - headers


- (NSMutableDictionary *)defaultHeaders{
    if (!_defaultHeaders) {
        _defaultHeaders = [NSMutableDictionary dictionary];
        [_defaultHeaders setObject:DS_SERVER_CONTENT_TYPE_JSON forKey:HTTP_HEAD_ACCEPT_TYPE];
        [_defaultHeaders setObject:[DSDeviceUtil identifier] forKey:HTTP_HEAD_DEVICE_ID];
        
        [_defaultHeaders setObject:[DSDeviceUtil systemInfo] forKey:HTTP_HEAD_DEVICE_INFO];
        [_defaultHeaders setObject:@"en-US" forKey:HTTP_HEAD_ACCEPT_LANGUAGE];
        [_defaultHeaders setObject:DS_SERVER_CONTENT_TYPE_JSON forKey:HTTP_HEAD_CONTENT_TYPE];
        [_defaultHeaders setObject:@"gzip" forKey:@"Accept-Encoding"];
    }
    
    if ([AGNetworkDefine singleton].clientID) [_defaultHeaders setObject:[AGNetworkDefine singleton].clientID forKey:@"X-Client-Id"];
    if ([AGNetworkDefine singleton].clientSecret) [_defaultHeaders setObject:[AGNetworkDefine singleton].clientSecret forKey:@"X-Client-Secret"];
    
    if (self.token) {
        [_defaultHeaders setObject:self.token forKey:@"X-Authentication-Token"];
    }else{
        [_defaultHeaders removeObjectForKey:@"X-Authentication-Token"];
    }
    
    return _defaultHeaders;
}

- (NSMutableDictionary *)defaultHeadersForThirdParty{
    if (!_defaultHeadersForThirdParty) {
        _defaultHeadersForThirdParty = [NSMutableDictionary dictionary];
        [_defaultHeadersForThirdParty setObject:@"application/json, text/*" forKey:HTTP_HEAD_ACCEPT_TYPE];
        [_defaultHeadersForThirdParty setObject:DS_SERVER_CONTENT_TYPE_JSON forKey:HTTP_HEAD_CONTENT_TYPE];
        [_defaultHeadersForThirdParty setObject:@"compress, gzip" forKey:@"Accept-Encoding"];
        //    [headers setObject:@"utf-8" forKey:@"Accept-Charset"];
        [_defaultHeadersForThirdParty setObject:@"en-US" forKey:HTTP_HEAD_ACCEPT_LANGUAGE];
    }
    return _defaultHeadersForThirdParty;
}

@end
