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


extern NSString *AGCPHome;
extern NSString *AGCPProfile;
extern NSString *AGCPProfileHomeAddressEditor;
extern NSString *AGCPProfileShippingAddressEditor;
extern NSString *AGCPProfileBillingAddressEditor;
extern NSString *AGCPProfileOnWebAddressEditor;
extern NSString *AGCPRegistrationBasic;
extern NSString *AGCPRegistrationStepChooseProduct;
extern NSString *AGCPRegistrationStepFillProfile;
extern NSString *AGCPRegistrationStepReview;
extern NSString *AGCPRegistrationStepResult;
extern NSString *AGCPAutoshipList;
extern NSString *AGCPAutoshipDetail;
extern NSString *AGCPAutoshipStepChooseProduct;
extern NSString *AGCPAutoshipStepReview;
extern NSString *AGCPAutoshipStepResult;
extern NSString *AGCPShoppingTaxonList;
extern NSString *AGCPShoppingProductList;
extern NSString *AGCPShoppingProductDetail;
extern NSString *AGCPShoppingCart;
extern NSString *AGCPShoppingStepReview;
extern NSString *AGCPShoppingStepResult;
extern NSString *AGCPGenealogyUnilevel;
extern NSString *AGCPGenealogyDualteam;
extern NSString *AGCPSetting;
extern NSString *AGCPCommissionWeekly;
extern NSString *AGCPCommissionMonthly;
extern NSString *AGCPCommissionQuartly;
extern NSString *AGCPCommissionRank;
extern NSString *AGCPCommissionDualteam;
extern NSString *AGCPReportOrder;
extern NSString *AGCPReportOrganization;
extern NSString *AGCPReportRecentGrowth;
extern NSString *AGCPReportTotal;
extern NSString *AGCPReportReturn;
extern NSString *AGCPGiftCardList;
extern NSString *AGCPGiftCardBoughtList;
extern NSString *AGCPGiftCardStepReview;
extern NSString *AGCPGiftCardStepResult;
extern NSString *AGCPServerIsDown;



@interface AGMonitor : NSObject

- (void)startWithFlurryAPIKey:(NSString *)flurryAPIKey;

#pragma mark - ops

+ (void)logClientException:(NSException *)exception forRequest:(DSRequest *)request;
+ (void)logClientException:(NSException *)exception;
+ (void)logServerExceptionWithResult:(AGRemoterResult *)result;
+ (void)logLoadIFrameFailedError:(NSError *)error;

+ (void)setDistributorID:(NSString *)distributorID;
+ (void)passCheckpoint:(NSString *)checkpointName;


@property (nonatomic, strong) NSString *appVersion;
@property (nonatomic, strong) NSString *userID;

@end
