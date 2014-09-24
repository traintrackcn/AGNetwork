//
//  AGNetworkConfig.m
//  AGNetwork
//
//  Created by traintrackcn on 23/9/14.
//  Copyright (c) 2014 AboveGEM. All rights reserved.
//

#import "AGNetworkConfig.h"

@implementation AGNetworkConfig

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setDefaultProtocolVersion:[aDecoder decodeObjectForKey:@"default-protocol-version"]];
        //        [self setToken:[aDecoder decodeObjectForKey:@"token"]];
        [self setDefaultServerUrl:[aDecoder decodeObjectForKey:@"default-server-url"]];
        [self setToken:[aDecoder decodeObjectForKey:@"token"]];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.defaultProtocolVersion forKey:@"default-protocol-version"];
    //    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.defaultServerUrl forKey:@"default-server-url"];
    [aCoder encodeObject:self.token forKey:@"token"];
}

@end
