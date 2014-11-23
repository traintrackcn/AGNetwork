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

@class AGRemoterResult;

@protocol AGRemoterDelegate <NSObject>

@required
- (void)remoterDataReceived:(id)responseData withRequestData:(DSRequest *)request;
@optional
- (void)remoterErrorOccured:(AGRemoterResult *)result;
//- (void)remoterGetServerCurrentTime:(NSString *)serverCurrentTime;

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

- (void)GET:(NSString *)requestType;
- (void)GET:(NSString *)requestType protocolVersion:(NSString *)protocolVersion;
- (void)GET:(NSString *)requestType userInfo:(id)userInfo;
- (void)POST:(NSString *)requestType requestBody:(id)requestBody;
- (void)POST:(NSString *)requestType requestBody:(id)requestBody forOrder:(BOOL)isForOrder;
- (void)POST:(NSString *)requestType binaryData:(NSData *)binaryData;
- (void)PUT:(NSString *)requestType requestBody:(id)requestBody;
- (void)DELETE:(NSString *)requestType requestBody:(id)requestBody;

@property (nonatomic, weak) id < AGRemoterDelegate> delegate;


@end
