//
//  DSRequestData.h
//  DirectSale
//
//  Created by Sean Guo on 7/16/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AGRequestBinary;
@interface DSRequest : NSMutableURLRequest

+ (instancetype)instanceWithRequestType:(NSString *)requestType;
+ (instancetype)instanceWithThirdPartyUrl:(NSURL *)thirdPartyUrl;

//- (NSString *)url;
- (NSString *)key;
- (void)assemble;


@property (nonatomic, strong) NSDictionary *requestBody;
@property (nonatomic, strong) AGRequestBinary *requestBinary;

@property (nonatomic, retain) NSString *requestType;
@property (nonatomic, strong) NSDictionary *userInfo;


@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *protocolVersion;
@property (nonatomic, strong) NSString *serverUrl;

@property (nonatomic, assign) BOOL forOrder;
@property (nonatomic, assign) BOOL isThirdParty;






@end
