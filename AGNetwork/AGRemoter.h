//
//  AGRemoter.h
//  DirectSale
//
//  Created by Sean Guo on 7/14/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "DSRequest.h"

@class AGRemoterResult;

@protocol AGRemoterDelegate <NSObject>

@required
- (void)remoterDataReceived:(id)responseData withRequestData:(DSRequest *)request;
@optional
- (void)remoterErrorOccured:(AGRemoterResult *)result;
- (void)remoterGetServerCurrentTime:(NSString *)serverCurrentTime;

@end


@interface AGRemoter : NSObject



+ (AGRemoter *)instanceWithDelegate:(id < AGRemoterDelegate>)aDelegate;
- (void)execute:(DSRequest*)requestData;
//+ (void)cancelAllRequests;
- (void)cancelAllRequests;

#pragma mark - 
- (void)GET:(NSString *)requestType;
- (void)POST:(NSString *)requestType requestBody:(id)requestBody;
- (void)PUT:(NSString *)requestType requestBody:(id)requestBody;
- (void)DELETE:(NSString *)requestType requestBody:(id)requestBody;

@property (nonatomic, weak) id < AGRemoterDelegate> delegate;


@end
