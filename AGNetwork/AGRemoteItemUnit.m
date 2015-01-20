//
//  AGRemoteDataCoordinator.m
//  AboveGEM
//
//  Created by traintrackcn on 20/1/15.
//
//

#import "AGRemoteItemUnit.h"
#import "AGRemoter.h"
#import "DSValueUtil.h"
#import "AGRemoterResult.h"
#import "AGRemoterResult.h"
#import "AGMonitor.h"
#import "GlobalDefine.h"

@interface AGRemoteItemUnit()<AGRemoterDelegate>{
    void(^requestCompletion)(id item);
}

@property (nonatomic, strong) AGRemoter *remoter;
@property (nonatomic, strong) id item;

@end

@implementation AGRemoteItemUnit


+ (instancetype)instanceWithRequestType:(NSString *)requestType{
    AGRemoteItemUnit *instance = [[AGRemoteItemUnit alloc] init];
    [instance setRequestType:requestType];
    return instance;
}

- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - properties

- (AGRemoter *)remoter{
    if ([DSValueUtil isNotAvailable:_remoter]) {
        _remoter = [AGRemoter instanceWithDelegate:self];
    }
    return _remoter;
}

#pragma mark - events

- (id)didGetResponseData:(id)responseData{
    return responseData;
}

#pragma mark - availability

- (BOOL)isItemAvailable{
    return [DSValueUtil isAvailable:self.item];
}

- (BOOL)isRemoterWorking{
    return [DSValueUtil isAvailable:requestCompletion];
}

#pragma mark - ops

- (void)waitAMomentForRemoterThenRequestWithCompletion:(void(^)(id item))completion{
    [self performSelector:@selector(requestWithCompletion:) withObject:completion afterDelay:1.0f];
//    TLOG(@"wait 1s ...");
}

#pragma mark - remote ops

- (void)requestWithCompletion:(void(^)(id item))completion{
//    TLOG(@"");
    
    if ([self isItemAvailable]) {
        requestCompletion = completion;
        [self executeBlock];
        return;
    }
    
    //processing another request, wait 1s
    if ([self isRemoterWorking]) {
        [self waitAMomentForRemoterThenRequestWithCompletion:completion];
        return;
    }
    
    requestCompletion = completion;
    [self.remoter GET: self.requestType];
}

- (void)requestCallback:(id)responseData{
//        TLOG(@"responseData -> %@", responseData);
    
    if ([DSValueUtil isNotAvailable:responseData]) {
        [self executeBlock];
        return;
    }
    
    @try {
        [self setItem:[self didGetResponseData:responseData]];
    }@catch (NSException *exception) {
        [AGMonitor logClientException:exception fnName:CURRENT_FUNCTION_NAME];
    }
    
    [self executeBlock];
}

- (void)executeBlock{
    if ([DSValueUtil isAvailable:requestCompletion]) {
        requestCompletion(self.item);
        requestCompletion = nil;
    }
    
    [self setRemoter:nil];
}

#pragma mark - AGRemoterDelegate

- (void)remoterDataReceived:(id)responseData requestType:(NSString *)requestType{
    if ([requestType isEqualToString:self.requestType]) {
        [self requestCallback:responseData];
    }
}

- (void)remoterErrorOccured:(AGRemoterResult *)result requestType:(NSString *)requestType{
    if ([requestType isEqualToString:self.requestType]) {
        [self requestCallback:nil];
    }
}

@end
