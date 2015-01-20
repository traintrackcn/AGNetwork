//
//  AGRemoteDataCoordinator.h
//  AboveGEM
//
//  Created by traintrackcn on 20/1/15.
//
//

#import <Foundation/Foundation.h>

@interface AGRemoteItemUnit : NSObject

+ (instancetype)instanceWithRequestType:(NSString *)requestType;

- (id)didGetResponseData:(id)responseData;
- (void)requestWithCompletion:(void(^)(id item))completion;

@property (nonatomic, strong) NSString *requestType;

@end
