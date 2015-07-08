//
//  AGRemoteDataCoordinator.h
//  AboveGEM
//
//  Created by traintrackcn on 20/1/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AGRemoteUnitMethod) {
    AGRemoteUnitMethodGET,
    AGRemoteUnitMethodPOST,
    AGRemoteUnitMethodPUT,
    AGRemoteUnitMethodDELETE
};

@interface AGRemoteUnit : NSObject

+ (instancetype)instance;
+ (instancetype)instanceWithRequestType:(NSString *)requestType;
+ (instancetype)instanceWithMethod:(AGRemoteUnitMethod)method requestType:(NSString *)requestType requestBody:(id)requestBody;

- (id)processResponseData:(id)responseData;
- (void)requestWithCompletion:(void(^)(id data, id error))completion;
- (void)reset;
- (void)cancel;

- (BOOL)isRequesting;
- (BOOL)isDataCached;

@property (nonatomic, assign) AGRemoteUnitMethod method;
@property (nonatomic, strong) NSString *requestType;
@property (nonatomic, strong) id requestBody;
@property (nonatomic, strong) NSString *protocolVersion;

@property (nonatomic, strong) NSURL *thirdPartyUrl;

@property (nonatomic, assign) BOOL isForOrder;
@property (nonatomic, assign) BOOL cacheEnabled;

@end
