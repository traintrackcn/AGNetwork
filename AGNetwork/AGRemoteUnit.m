//
//  AGRemoteDataCoordinator.m
//  AboveGEM
//
//  Created by traintrackcn on 20/1/15.
//
//

#import "AGRemoteUnit.h"
#import "AGRemoter.h"
#import "DSValueUtil.h"
#import "AGRemoterResult.h"
//#import "AGFlurryMonitor.h"
#import "GlobalDefine.h"
#import "AGNetworkDefine.h"

@interface AGRemoteUnit()<AGRemoterDelegate>{
    void(^requestCompletion)(id data, id error);
}

@property (nonatomic, strong) AGRemoter *remoter;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) id error;



@end

@implementation AGRemoteUnit

+ (instancetype)instance{
    AGRemoteUnit *instance = [[AGRemoteUnit alloc] init];
    return instance;
}

+ (instancetype)instanceWithRequestType:(NSString *)requestType{
    AGRemoteUnit *instance = [AGRemoteUnit instance];
    [instance setRequestType:requestType];
    return instance;
}

+ (instancetype)instanceWithMethod:(AGRemoteUnitMethod)method requestType:(NSString *)requestType requestBody:(id)requestBody {
    AGRemoteUnit *instance = [[AGRemoteUnit alloc] init];
    [instance setRequestType:requestType];
    [instance setRequestBody:requestBody];
    [instance setMethod:method];
    return instance;
}

- (void)dealloc{
//    TLOG(@"%@",self);
    [self cancel];
}

#pragma mark - properties

- (NSString *)methodStr{
    if (self.method == AGRemoteUnitMethodDELETE) return @"DELETE";
    if (self.method == AGRemoteUnitMethodPOST) return @"POST";
    if (self.method == AGRemoteUnitMethodPUT) return @"PUT";
    return @"GET";
}

- (AGRemoter *)remoter{
    if (!_remoter) {
        _remoter = [AGRemoter instanceWithDelegate:self];
        
    }
    return _remoter;
}


#pragma mark - events

- (id)processResponseData:(id)responseData{
    return responseData;
}

#pragma mark - availability

- (BOOL)isDataCached{
    return [DSValueUtil isAvailable:self.data];
}

- (BOOL)isRequesting{
    return [DSValueUtil isAvailable:_remoter];
}

#pragma mark - ops

- (void)waitAMomentForRemoterThenRequestWithCompletion:(void(^)(id data, id error))completion{
    [self performSelector:@selector(requestWithCompletion:) withObject:completion afterDelay:1.0f];
//    TLOG(@"wait 1s ...");
}

#pragma mark - remote ops

- (void)requestWithCompletion:(void(^)(id data, id error))completion{

    
//    TLOG(@"completion -> %@", completion);
    
    if ([self isDataCached]) {
        requestCompletion = completion;
        [self executeBlock];
        return;
    }
    
    //processing another request, wait 1s
    if ([self isRequesting]) {
        [self waitAMomentForRemoterThenRequestWithCompletion:completion];
        return;
    }
    
    requestCompletion = completion;
    
    TLOG(@"self.thirdPartyUrl -> %@", self.thirdPartyUrl);
    
    
    if (self.requestBinary) {
        NSString *methodStr = [self methodStr];
        [self.remoter REQUEST:self.requestType method:methodStr requestBody:self.requestBody requestBinary:self.requestBinary forOrder:self.forOrder protocolVersion:self.protocolVersion];
         return;
    }
    
    
    
    if (self.method == AGRemoteUnitMethodPOST) {
        if (self.thirdPartyUrl) {
            [self.remoter POST3:self.thirdPartyUrl requestBody:self.requestBody];
        }else{
            [self.remoter POST:self.requestType requestBody:self.requestBody forOrder:self.forOrder protocolVersion:self.protocolVersion];
        }
    }else if (self.method == AGRemoteUnitMethodDELETE){
        [self.remoter DELETE:self.requestType requestBody:self.requestBody];
    }else if (self.method == AGRemoteUnitMethodPUT){
        [self.remoter PUT:self.requestType requestBody:self.requestBody];
    }else if(self.method == AGRemoteUnitMethodGET){ //AGRemoteUnitMethodGET
        
        if (self.thirdPartyUrl) {
            [self.remoter GET3:self.thirdPartyUrl];
        }else if (self.protocolVersion) {
            [self.remoter GET:self.requestType protocolVersion:self.protocolVersion];
        }else{
            [self.remoter GET: self.requestType];
        }
    }
}

- (void)executeBlock{
    if ([DSValueUtil isAvailable:requestCompletion]) {
        @try {
//            TLOG(@"requestCompletion -> %@ %@", requestCompletion, [self.data raw]);
            requestCompletion(self.data, self.error);
        }
        @catch (NSException *exception) {
            TLOG(@"exception -> %@", exception);
        }
        
        
    }
    
    if (self.cacheEnabled) {
        [self requestFlowEnd];
    }else{
        [self reset];
    }
    
}

- (void)requestFlowEnd{
    [self setRemoter:nil];
    [self setError:nil];
    requestCompletion = nil;
}

- (void)reset{
    [self setData:nil];
    [self requestFlowEnd];
}

- (void)cancel{
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; //also cancel in queue requests
    [_remoter cancelAllRequests];
}

#pragma mark - AGRemoterDelegate

- (void)remoterDataReceived:(id)responseData requestType:(NSString *)requestType{
    
//    TLOG(@"requestType %@ self.requestType %@", requestType, self.requestType);
    
//    if ([requestType isEqualToString:self.requestType]) {
        @try {
            [self setData:[self processResponseData:responseData]];
        }@catch (NSException *exception) {
//            [AGFlurryMonitor logClientException:exception fnName:CURRENT_FUNCTION_NAME];
        }
        [self executeBlock];
//    }
    
}

- (void)remoterErrorOccured:(AGRemoterResult *)result requestType:(NSString *)requestType{
//    TLOG(@"");
//    if ([requestType isEqualToString:self.requestType]) {
        [self setError:result.errorParsed];
        [self executeBlock];
//    }
    
}

@end
