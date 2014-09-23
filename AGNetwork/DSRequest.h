//
//  DSRequestData.h
//  DirectSale
//
//  Created by Sean Guo on 7/16/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//

@interface DSRequest : NSMutableURLRequest


@property (nonatomic, retain) NSString* requestType;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSDictionary *contentJSON;
@property (nonatomic, strong) NSData *contentBinary;

- (id) initWithRequestType:(NSString*) requestType;

- (NSString *)url;
- (NSString *)key;
- (void)assemble;

//- (BOOL)isTypeOfGetOrderInfo;


@property (nonatomic, strong) NSString *method;

@property (nonatomic, strong) NSString *protocolVersion;





@end
