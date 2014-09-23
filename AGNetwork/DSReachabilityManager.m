//
//  DSReachability.m
//  og
//
//  Created by traintrackcn on 13-5-8.
//  Copyright (c) 2013 2ViVe. All rights reserved.
//

#import "DSReachabilityManager.h"
#import "Reachability.h"
#import "GlobalDefine.h"
//#import "DSHostSettingManager.h"
//#import "MKInfoPanel.h"

@interface DSReachabilityManager(){
    Reachability *reachHost;
    Reachability *reachInternet;
}
@end

@implementation DSReachabilityManager

- (void)startWithTargetHost:(NSString *)targetHost{
    //internet access
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    reachInternet = [Reachability reachabilityForInternetConnection] ;
    [self configureReachability:reachInternet];
    [reachInternet startNotifier];
    
	reachHost = [Reachability reachabilityWithHostname:targetHost];
    [reachHost startNotifier];
    
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note{
	[self configureReachability: (Reachability *) [note object]];
}

- (void) configureReachability: (Reachability*) curReach{
    
    BOOL isHostReachabilityChanged = [curReach isEqual:reachHost];
    BOOL isInternentReachabilityChanged = [curReach isEqual:reachInternet];
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    NSString* netStatusStr= @"";
    BOOL isReachable = YES;
    
    
    switch (netStatus){
        case NotReachable:{
            netStatusStr = @"Access Not Available";
            isReachable = NO;
            break;
        }
        case ReachableViaWWAN:{
            netStatusStr = @"Reachable WWAN";
            isReachable = YES;
            break;
        }
        case ReachableViaWiFi:{
            netStatusStr= @"Reachable WiFi";
            isReachable = YES;
            break;
        }
    }
    
    if (isHostReachabilityChanged) {
        TLOG(@"HostRechability -> %@", netStatusStr);
        if(isReachable){
            [self setIsHostReachable:YES];
        }else{
            [self setIsHostReachable:NO];
        }
    }else if(isInternentReachabilityChanged){
        TLOG(@"InternentReachability-> %@ ", netStatusStr);
        if (isReachable) {
            [self setIsInternetReachable:YES];
        }else{
            [self setIsInternetReachable:NO];
        }
    }
    
    
}

@end
