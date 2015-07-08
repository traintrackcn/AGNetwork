//
//  DSRequestData.h
//  DirectSale
//
//  Created by Sean Guo on 7/16/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSRequest : NSMutableURLRequest


@property (nonatomic, retain) NSString* requestType;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDictionary *contentJSON;
@property (nonatomic, strong) NSData *contentBinary;


@property (nonatomic, assign) BOOL isForOrder;

//- (id) initWithRequestType:(NSString*) requestType;

+ (instancetype)instanceWithRequestType:(NSString *)requestType;

- (NSString *)url;
- (NSString *)key;
- (void)assemble;

- (void)assembleHeaderForPostingOrder;


@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *protocolVersion;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *serverUrl;

@property (nonatomic, assign) BOOL isThirdParty;
@property (nonatomic, assign) NSInteger timeout;



@end
