    //
//  AGFlurryEvent.m
//  AboveGEM
//
//  Created by traintrackcn on 23/4/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGMonitor.h"
#import "AGRemoterResult.h"
#import "AGRemoterResultError.h"
#import "Flurry.h"
#import "DSRequest.h"
#import "GlobalDefine.h"
#import "DSValueUtil.h"
#import "NSObject+Singleton.h"

NSString *AGCPHome = @"AGCPHome";
NSString *AGCPProfile = @"AGCPProfile";
NSString *AGCPProfileHomeAddressEditor = @"AGCPProfileHomeAddressEditor";
NSString *AGCPProfileShippingAddressEditor = @"AGCPProfileShippingAddressEditor";
NSString *AGCPProfileBillingAddressEditor = @"AGCPProfileBillingAddressEditor";
NSString *AGCPProfileOnWebAddressEditor = @"AGCPProfileOnWebAddressEditor";
NSString *AGCPRegistrationBasic = @"AGCPRegistrationBasic";
NSString *AGCPRegistrationStepChooseProduct = @"AGCPRegistrationStepChooseProduct";
NSString *AGCPRegistrationStepFillProfile = @"AGCPRegistrationStepFillProfile";
NSString *AGCPRegistrationStepReview = @"AGCPRegistrationStepReview";
NSString *AGCPRegistrationStepResult = @"AGCPRegistrationStepResult";
NSString *AGCPAutoshipList = @"AGCPAutoshipList";
NSString *AGCPAutoshipDetail = @"AGCPAutoshipDetail";
NSString *AGCPAutoshipStepChooseProduct = @"AGCPAutoshipStepChooseProduct";
NSString *AGCPAutoshipStepReview = @"AGCPAutoshipStepReview";
NSString *AGCPAutoshipStepResult = @"AGCPAutoshipStepResult";
NSString *AGCPShoppingTaxonList = @"AGCPShoppingTaxonList";
NSString *AGCPShoppingProductList = @"AGCPShoppingProductList";
NSString *AGCPShoppingProductDetail = @"AGCPShoppingProductDetail";
NSString *AGCPShoppingCart = @"AGCPShoppingCart";
NSString *AGCPShoppingStepReview = @"AGCPShoppingStepReview";
NSString *AGCPShoppingStepResult = @"AGCPShoppingStepResult";
NSString *AGCPGenealogyUnilevel = @"AGCPGenealogyUnilevel";
NSString *AGCPGenealogyDualteam = @"AGCPGenealogyDualteam";
NSString *AGCPSetting = @"AGCPSetting";
NSString *AGCPCommissionWeekly = @"AGCPCommissionWeekly";
NSString *AGCPCommissionMonthly = @"AGCPCommissionMonthly";
NSString *AGCPCommissionQuartly = @"AGCPCommissionQuartly";
NSString *AGCPCommissionRank = @"AGCPCommissionRank";
NSString *AGCPCommissionDualteam = @"AGCPCommissionDualteam";
NSString *AGCPReportOrder = @"AGCPReportOrder";
NSString *AGCPReportOrganization = @"AGCPReportOrganization";
NSString *AGCPReportRecentGrowth = @"AGCPReportRecentGrowth";
NSString *AGCPReportTotal = @"AGCPReportTotal";
NSString *AGCPReportReturn = @"AGCPReportReturn";
NSString *AGCPGiftCardList = @"AGCPGiftCardList";
NSString *AGCPGiftCardBoughtList = @"AGCPGiftCardBoughtList";
NSString *AGCPGiftCardStepReview = @"AGCPGiftCardStepReview";
NSString *AGCPGiftCardStepResult = @"AGCPGiftCardStepResult";
NSString *AGCPServerIsDown = @"AGCPServerIsDown";


@implementation AGMonitor


#pragma mark - 

- (void)startWithFlurryAPIKey:(NSString *)flurryAPIKey{
    
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
    
//    [AGMonitor setDistributorID:[AGSession singleton].profile.person.distributorID];
//    [AGMonitor setAppVersion:[AGAppUtil buildNumberText]];

//=== AirBrake Setting ===
//    [ABNotifier setEnvironmentValue:[DSHostSettingManager selectedHost] forKey:@"host"];
//    [ABNotifier startNotifierWithAPIKey:@"6065e442c3e43cfa794ec3e37c018951"
//                        environmentName:ABNotifierAutomaticEnvironment
//                                 useSSL:NO // only if your account supports it
//                               delegate:self];
    
 
    
//=== Flurry Setting ===
//    TLOG(@"[AGConfigurationCoordinator singleton].flurryAPIKey -> %@", [AGConfigurationCoordinator singleton].flurryAPIKey);
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:flurryAPIKey];

    
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
    [AGMonitor logClientException:exception];
}

void signalHandler(int sig) {
    [AGMonitor logErrorID:[NSString stringWithFormat:@"SIGNAL-%d", sig]];
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
    NSMutableString *eId = [NSMutableString string];
    [eId appendString:[NSString stringWithFormat:@"%@", [AGMonitor RESPONSE_EXCEPTION_OF_CLIENT]]];
    
    if ([DSValueUtil isAvailable:request]) {
        [eId appendString: [NSString stringWithFormat:@"-%@", [request URL]] ];
    }
    
    [self logErrorID:eId message:exception.name reason:exception.reason];
}

+ (void)logClientException:(NSException *)exception{
    [self logClientException:exception forRequest:nil];
}

+ (void)logServerExceptionWithResult:(AGRemoterResult *)result{
//    TLOG(@"result.request -> %@", result.request);
    NSMutableString *eId = [NSMutableString string];
    [eId appendString:[NSString stringWithFormat:@"%@", [AGMonitor RESPONSE_EXCEPTION_OF_SERVER]]];
    
    if (result.code != AGResultCodeUnknown) {
        [eId appendString:[NSString stringWithFormat:@"-%ld",(long)result.code] ];
    }
    
    if ([DSValueUtil isAvailable:result.request]) {
        [eId appendString:[NSString stringWithFormat:@"-%@", result.request.URL] ];
    }
    
    AGRemoterResultError *error = result.errorParsed;
//    TLOG(@"headers -> %@", [result.request allHTTPHeaderFields]);
    [self logErrorID:eId message:[NSString stringWithFormat:@"%@",error.message] reason:error.localizedDesc];
}

#pragma mark - basic remote log ops

+ (void)logErrorID:(NSString *)errorID{
    [self logErrorID:errorID message:nil reason:nil];
}

+ (void)logErrorID:(NSString *)errorID message:(NSString *)message{
    [self logErrorID:errorID message:message reason:nil];
}

+ (void)logErrorID:(NSString *)errorID message:(NSString *)message reason:(NSString *)reason{
    
//    NSString *distributorID = [AGSession singleton].profile.person.distributorID;
//    NSString *appVersion = [AGAppUtil buildNumberText];
    NSString *userID = [AGMonitor singleton].userID;
    NSString *appVersion = [AGMonitor singleton].appVersion;
    
    
    NSString *environment = [NSString stringWithFormat:@"[b.%@][u.%@]", appVersion,[DSValueUtil isAvailable:userID]?userID:@"Anonymous"];
    NSException *e = [NSException exceptionWithName:environment reason:[DSValueUtil isAvailable:reason]?reason:@"" userInfo:nil];
    
    [Flurry logError:errorID message:[DSValueUtil isAvailable:message]?message:@"" exception:e];

//    [ABNotifier logException:e];
    
    TLOG(@"%@ %@ %@ %@", environment,errorID, message, reason);
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


@end
