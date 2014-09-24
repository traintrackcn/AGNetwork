//
//  AGFlurryEvent.h
//  AboveGEM
//
//  Created by traintrackcn on 23/4/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "ABNotifier.h"

@class DSRequest;
@class AGRemoterResult;

@interface AGMonitor : NSObject

- (void)startWithFlurryAPIKey:(NSString *)flurryAPIKey;

#pragma mark - ops

+ (void)logClientException:(NSException *)exception forRequest:(DSRequest *)request;
+ (void)logClientUncaughtException:(NSException *)exception;
+ (void)logServerExceptionWithResult:(AGRemoterResult *)result forRequest:(DSRequest *)request;
+ (void)logLoadImageFailedError:(NSError *)error forImageUrl:(NSURL *)url;
+ (void)logLoadIFrameFailedError:(NSError *)error;
//+ (void)logError:(NSString *)errorID message:(id)message message1:(id)message1;

+ (void)setDistributorID:(NSString *)distributorID;

+ (void)passCheckpoint:(NSString *)checkpointName;

#pragma mark -

//+ (NSString *)ERROR_DOMAIN;
//+ (NSString *)RESPONSE_EXCEPTION_OF_CLIENT;
//+ (NSString *)RESPONSE_EXCEPTION_OF_SERVER;
+ (NSString *)HOME_VIEW;
+ (NSString *)ENROLL_STEP_BASIC_VIEW;
+ (NSString *)ENROLL_STEP_PRODUCTS_VIEW;
+ (NSString *)ENROLL_STEP_PROFILE_VIEW;
+ (NSString *)ENROLL_STEP_REVIEW_VIEW;
+ (NSString *)ENROLL_STEP_RESULT_VIEW;
+ (NSString *)AUTOSHIPS_VIEW;
+ (NSString *)AUTOSHIP_VIEW;
+ (NSString *)CREATE_AUTOSHIP_STEP_PRODUCT_VIEW;
+ (NSString *)CREATE_AUTOSHIP_STEP_REVIEW_VIEW;
+ (NSString *)CREATE_AUTOSHIP_STEP_RESULT_VIEW;
+ (NSString *)SHOP_TAXONS_VIEW;
+ (NSString *)SHOP_PRODUCTS_VIEW;
+ (NSString *)SHOP_PRODUCT_VIEW;
+ (NSString *)SHOPPING_CART_VIEW;

//+ (NSString *)SHOPPING_STEP_CHECKOUT_VIEW;
+ (NSString *)SHOPPING_STEP_REVIEW_VIEW;
+ (NSString *)SHOPPING_STEP_RESULT_VIEW;

+ (NSString *)GENEALOGY_UNILEVEL_VIEW;
+ (NSString *)GENEALOGY_DUALTEAM_VIEW;
+ (NSString *)SETTING_VIEW;
+ (NSString *)COMMISSIONS_WEEKLY_VIEW;
+ (NSString *)COMMISSIONS_MONTHLY_VIEW;
+ (NSString *)COMMISSIONS_QUARTERLY_VIEW;
+ (NSString *)COMMISSIONS_RANK_VIEW;
+ (NSString *)COMMISSIONS_DUALTEAM_VIEW;
+ (NSString *)REPORTS_ORDERS_VIEW;
+ (NSString *)REPORTS_ORGANIZATIONS_VIEW;
+ (NSString *)REPORTS_RECENT_GROWTH_VIEW;
+ (NSString *)REPORTS_TOTAL_VIEW;
+ (NSString *)REPORTS_RETURNS_VIEW;

+ (NSString *)GIFT_CARD_VIEW;


#pragma mark - interactive actions
+ (NSString *)TAPPED_ADD_PRODUCT_TO_CART;
+ (NSString *)TAPPED_CLOSE_SHOPPING_CART;
+ (NSString *)TAPPED_LOGOUT;


#pragma mark - fatal events
+ (NSString *)SERVER_IS_DOWN;


@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *userID;

@end
