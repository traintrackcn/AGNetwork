//
//  DSReachability.h
//  og
//
//  Created by traintrackcn on 13-5-8.
//  Copyright (c) 2013 2ViVe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSReachabilityManager : NSObject

- (void)startWithTargetHost:(NSString *)targetHost;

@property (nonatomic, assign) BOOL isHostReachable;

@property (nonatomic, assign) BOOL isInternetReachable;


@end
