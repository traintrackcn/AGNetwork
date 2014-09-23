//
//  AGFlurryEvent.m
//  AboveGEM
//
//  Created by traintrackcn on 23/4/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGRemoteMonitor.h"
#import "AGSession.h"
#import "AGContact.h"
#import "AGRemoterResultError.h"
#import "Flurry.h"
#import "DSHostSettingManager.h"
#import "AGRemoterResultError.h"


@implementation AGRemoteMonitor


#pragma mark - 

- (void)start{
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // create the signal action structure
    struct sigaction newSignalAction;
    // initialize the signal action structure
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    // set SignalHandler as the handler in the signal action structure
    newSignalAction.sa_handler = &signalHandler;
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
    
 //=== Global Environment Setting
    
    [AGRemoteMonitor setDistributorID:[AGSession singleton].profile.person.distributorID];
    [AGRemoteMonitor setAppVersion:[AGAppUtil buildNumberText]];

//=== AirBrake Setting ===
//    [ABNotifier setEnvironmentValue:[DSHostSettingManager selectedHost] forKey:@"host"];
//    [ABNotifier startNotifierWithAPIKey:@"6065e442c3e43cfa794ec3e37c018951"
//                        environmentName:ABNotifierAutomaticEnvironment
//                                 useSSL:NO // only if your account supports it
//                               delegate:self];
    
 
    
//=== Flurry Setting ===
    TLOG(@"[AGConfigurationCoordinator singleton].flurryAPIKey -> %@", [AGConfigurationCoordinator singleton].flurryAPIKey);
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:[AGConfigurationCoordinator singleton].flurryAPIKey];

    
#ifdef DEBUG
    //    TLOG(@"=== DEBUG CONFIG ===");
    
    //flurry log on console
//    [Flurry setShowErrorInLogEnabled:YES];
//    [Flurry setDebugLogEnabled:YES];
    
    //post data of flurry immediatly
//    [Flurry setSessionReportsOnCloseEnabled:YES];
//    [Flurry setEventLoggingEnabled:YES];
    
//    [Flurry setBackgroundSessionEnabled:YES];
//    [Flurry logError:@"Test Log Exception" message:@"exception msg" exception:[[NSException alloc] initWithName:@"name" reason:@"reason" userInfo:nil]];
//    [Flurry logError:@"Test Log Error" message:@"error msg" error:[[NSError alloc] initWithDomain:@"domain" code:0 userInfo:nil]];
#endif
}


void uncaughtExceptionHandler(NSException *exception){
    [AGRemoteMonitor logClientUncaughtException:exception];
}

void signalHandler(int sig) {
    [AGRemoteMonitor logErrorID:[NSString stringWithFormat:@"SIGNAL-%d", sig]];
//    NSLog(@"This is where we save the application data during a signal");
    // Save application data on crash
}

#pragma mark - checkpoint ops

+ (void)passCheckpoint:(NSString *)checkpointName{
    [Flurry logEvent:checkpointName];
}

#pragma mark - set global environments

+ (void)setDistributorID:(NSString *)distributorID{
    NSString *value = [DSValueUtil isAvailable:distributorID]?distributorID:@"Anonymous";
    [Flurry setUserID:value];
//    [ABNotifier setEnvironmentValue:value forKey:@"distributor-id"];
}

+ (void)setAppVersion:(NSString *)appVersion{
    NSString *value = appVersion;
//    [ABNotifier setEnvironmentValue:value forKey:@"app-version"];
    [Flurry setAppVersion:value];
}

#pragma mark - remote log ops

+ (void)logClientException:(NSException *)exception forRequest:(DSRequest *)request{
    NSString *errId = [NSString stringWithFormat:@"%@-%@",[AGRemoteMonitor RESPONSE_EXCEPTION_OF_CLIENT],[request url]];
    [self logErrorID:errId message:exception.name reason:exception.reason];
}

+ (void)logClientUncaughtException:(NSException *)exception{
    NSString *errId = [NSString stringWithFormat:@"%@-UNCAUGHT",[AGRemoteMonitor RESPONSE_EXCEPTION_OF_CLIENT]];
    [self logErrorID:errId message:exception.name reason:exception.reason];
}

+ (void)logServerExceptionWithResult:(AGRemoterResult *)result forRequest:(DSRequest *)request{
    NSString *errId = [NSString stringWithFormat:@"%@-%ld-%@",[AGRemoteMonitor RESPONSE_EXCEPTION_OF_SERVER],(long)result.code,[request url]];
    AGRemoterResultError *error = result.error;
    [self logErrorID:errId message:[NSString stringWithFormat:@"[%@] %@", error.code, error.message] reason:error.developerMessage];
}

+ (void)logLoadImageFailedError:(NSError *)error forImageUrl:(NSURL *)url{
    NSString *errId = [NSString stringWithFormat:@"%@-IMG-%@",[AGRemoteMonitor RESPONSE_EXCEPTION_OF_SERVER],url];
    [self logErrorID:errId message:[DSValueUtil toString:error.userInfo]];
}

+ (void)logLoadIFrameFailedError:(NSError *)error{
    NSString *url = [error.userInfo objectForKey:@"NSErrorFailingURLKey"];
    NSString *description = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    NSString *errId = [NSString stringWithFormat:@"%@-IFRAME-%@",[AGRemoteMonitor RESPONSE_EXCEPTION_OF_SERVER],url];
    [self logErrorID:errId message:description];
}

#pragma mark - basic remote log ops

+ (void)logErrorID:(NSString *)errorID{
    [self logErrorID:errorID message:nil reason:nil];
}

+ (void)logErrorID:(NSString *)errorID message:(NSString *)message{
    [self logErrorID:errorID message:message reason:nil];
}

+ (void)logErrorID:(NSString *)errorID message:(NSString *)message reason:(NSString *)reason{
    
    NSString *distributorID = [AGSession singleton].profile.person.distributorID;
    NSString *appVersion = [AGAppUtil buildNumberText];
    NSString *environment = [NSString stringWithFormat:@"%@-%@", appVersion,[DSValueUtil isAvailable:distributorID]?distributorID:@"Anonymous"];
    NSException *e = [NSException exceptionWithName:environment reason:[DSValueUtil isAvailable:reason]?reason:@"" userInfo:nil];
    
    [Flurry logError:errorID message:[DSValueUtil isAvailable:message]?message:@"" exception:e];

//    [ABNotifier logException:e];
    
    TLOG(@"ErrorID:%@ Message:%@ Reason:%@", errorID, message, reason);
}

+ (NSString *)RESPONSE_EXCEPTION_OF_CLIENT{
    return @"EOC";
}

+ (NSString *)RESPONSE_EXCEPTION_OF_SERVER{
    return @"EOS";
}

//#pragma mark - ABNotifierDelegate
//
//- (void)notifierDidLogException:(NSException *)e{
//    TLOG(@"e -> %@ name -> %@", e, e.name);
//}
//
//- (NSString *)titleForNoticeAlert {
////	TLOG(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}
//- (NSString *)bodyForNoticeAlert {
////	TLOG(@"%s", __PRETTY_FUNCTION__);
//	return nil;
//}

#pragma mark -

+ (NSString *)HOME_VIEW{
//    TLOG(@"HOME_VIEW happend");
    return @"HOME_VIEW";
}

+ (NSString *)ENROLL_STEP_BASIC_VIEW{
    return @"ENROLL_STEP_BASIC_VIEW";
}

+ (NSString *)ENROLL_STEP_PRODUCTS_VIEW{
    return @"ENROLL_STEP_PRODUCTS_VIEW";
}

+ (NSString *)ENROLL_STEP_PROFILE_VIEW{
    return @"ENROLL_STEP_PROFILE_VIEW";
}

+ (NSString *)ENROLL_STEP_REVIEW_VIEW{
    return @"ENROLL_STEP_REVIEW_VIEW";
}

+ (NSString *)ENROLL_STEP_RESULT_VIEW{
    return @"ENROLL_STEP_RESULT_VIEW";
}

+ (NSString *)AUTOSHIPS_VIEW{
    return @"AUTOSHIPS_VIEW";
}

+ (NSString *)AUTOSHIP_VIEW{
    return @"AUTOSHIP_VIEW";
}

+ (NSString *)CREATE_AUTOSHIP_STEP_PRODUCT_VIEW{
    return @"CREATE_AUTOSHIP_STEP_PRODUCT_VIEW";
}

+ (NSString *)CREATE_AUTOSHIP_STEP_REVIEW_VIEW{
    return @"CREATE_AUTOSHIP_STEP_REVIEW_VIEW";
}

+ (NSString *)CREATE_AUTOSHIP_STEP_RESULT_VIEW{
    return @"CREATE_AUTOSHIP_STEP_RESULT_VIEW";
}

+ (NSString *)SHOP_TAXONS_VIEW{
    return @"SHOP_TAXONS_VIEW";
}

+ (NSString *)SHOP_PRODUCTS_VIEW{
    return @"SHOP_PRODUCTS_VIEW";
}

+ (NSString *)SHOP_PRODUCT_VIEW{
    return @"SHOP_PRODUCT_VIEW";
}

+ (NSString *)SHOPPING_CART_VIEW{
    return @"SHOPPING_CART_VIEW";
}

+ (NSString *)SHOPPING_STEP_REVIEW_VIEW{
    return @"SHOPPING_STEP_REVIEW_VIEW";
}

+ (NSString *)SHOPPING_STEP_RESULT_VIEW{
    return @"SHOPPING_STEP_RESULT_VIEW";
}

+ (NSString *)GENEALOGY_UNILEVEL_VIEW{
    return @"GENEALOGY_UNILEVEL_VIEW";
}

+ (NSString *)GENEALOGY_DUALTEAM_VIEW{
    return @"GENEALOGY_DUALTEAM_VIEW";
}

+ (NSString *)SETTING_VIEW{
    return @"SETTING_VIEW";
}

+ (NSString *)COMMISSIONS_WEEKLY_VIEW{
    return @"COMMISSIONS_WEEKLY_VIEW";
}

+ (NSString *)COMMISSIONS_MONTHLY_VIEW{
    return @"COMMISSIONS_MONTHLY_VIEW";
}

+ (NSString *)COMMISSIONS_QUARTERLY_VIEW{
    return @"COMMISSIONS_QUARTERLY_VIEW";
}

+ (NSString *)COMMISSIONS_RANK_VIEW{
    return @"COMMISSIONS_RANK_VIEW";
}

+ (NSString *)COMMISSIONS_DUALTEAM_VIEW{
    return @"COMMISSIONS_DUALTEAM_VIEW";
}

+ (NSString *)REPORTS_ORDERS_VIEW{
    return @"REPORTS_ORDERS_VIEW";
}

+ (NSString *)REPORTS_ORGANIZATIONS_VIEW{
    return @"REPORTS_ORGANIZATIONS_VIEW";
}

+ (NSString *)REPORTS_RECENT_GROWTH_VIEW{
    return @"REPORTS_RECENT_GROWTH_VIEW";
}

+ (NSString *)REPORTS_TOTAL_VIEW{
    return @"REPORTS_TOTAL_VIEW";
}

+ (NSString *)REPORTS_RETURNS_VIEW{
    return @"REPORTS_RETURNS_VIEW";
}

+ (NSString *)GIFT_CARD_VIEW{
    return @"GIFT_CARD_VIEW";
}

#pragma mark - interactive actions
+ (NSString *)TAPPED_ADD_PRODUCT_TO_CART{
    return @"TAPPED_ADD_PRODUCT_TO_CART";
}

+ (NSString *)TAPPED_CLOSE_SHOPPING_CART{
    return @"TAPPED_CLOSE_SHOPPING_CART";
}

+ (NSString *)TAPPED_LOGOUT{
    return @"TAPPED_LOGOUT";
}
@end
