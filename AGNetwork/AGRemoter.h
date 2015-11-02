//
//  AGRemoter.h
//  DirectSale
//
//  Created by Sean Guo on 7/14/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DSRequest.h"
//#import "UIImageView+WebCache.h"
//#import "UIImageView+AFNetworking.h"

@class AGRemoterResult;

@protocol AGRemoterDelegate <NSObject>

@optional
- (void)remoterDataReceived:(id)responseData withRequestData:(DSRequest *)request NS_DEPRECATED_IOS(7_0, 7_1,"Use - remoterDataReceived:requestType:");
- (void)remoterErrorOccured:(AGRemoterResult *)result NS_DEPRECATED_IOS(7_0, 7_1,"Use - remoterErrorOccured:requestType:");


- (void)remoterErrorOccured:(AGRemoterResult *)result requestType:(NSString *)requestType;
- (void)remoterDataReceived:(id)responseData requestType:(NSString *)requestType;

@end


@interface AGRemoter : NSObject



+ (AGRemoter *)instanceWithDelegate:(id < AGRemoterDelegate>)aDelegate;
- (void)send:(DSRequest *)req forOrder:(BOOL)isForOrder;
- (void)cancelAllRequests;
- (void)cancelAllImageRequests;
- (BOOL)isLoadingAnyImageRequest;
- (void)removeImageReqest:(NSURL *)url;
- (AGRemoterResult *)assembleResultForError:(NSError *)error;

#pragma mark - 
- (void)REQUEST:(NSURL *)imageURL forImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage;
- (void)REQUEST:(NSURL *)imageURL completion:(void(^)(UIImage *image, NSError *error, NSInteger cacheType))completion;

- (void)GET3:(NSURL *)thirdPartyUrl;
- (void)GET:(NSString *)requestType;
- (void)GET:(NSString *)requestType protocolVersion:(NSString *)protocolVersion;
- (void)GET:(NSString *)requestType userInfo:(id)userInfo;
- (void)POST3:(NSURL *)thirdPartyUrl requestBody:(id)requestBody;
- (void)POST:(NSString *)requestType requestBody:(id)requestBody;
- (void)POST:(NSString *)requestType requestBody:(id)requestBody forOrder:(BOOL)isForOrder;
- (void)POST:(NSString *)requestType binaryData:(NSData *)binaryData;
- (void)PUT:(NSString *)requestType requestBody:(id)requestBody;
- (void)DELETE:(NSString *)requestType requestBody:(id)requestBody;

@property (nonatomic, weak) id < AGRemoterDelegate> delegate;


@end
