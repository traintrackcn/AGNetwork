//
//  AGRemoter.m
//  DirectSale
//
//  Created by Sean Guo on 7/14/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//

#import "AGRemoter.h"
//#import "AGHTTPClient.h"
#import "AGRemoterResult.h"
#import "GlobalDefine.h"
//#import "AGFlurryMonitor.h"
#import "AGRemoterResultError.h"
#import "DSValueUtil.h"
#import "AGNetworkDefine.h"
#import "NSObject+Singleton.h"
//#import "UIImageView+AFNetworking.h"

#import "DSRequestInfo.h"
//#import "DSReachabilityManager.h"

#import "AGRequestBinary.h"
//#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFURLResponseSerialization.h"
//#import "AFJSONRequestOperation.h"

#define kErrorCode @"code"



@interface AGRemoter(){
    
}



@end


@implementation AGRemoter
@synthesize delegate;

+ (void)initialize{
//    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

+ (AGRemoter *)instanceWithDelegate:(id< AGRemoterDelegate>)aDelegate{
    AGRemoter *instance = [[AGRemoter alloc] init];
    [instance setDelegate:aDelegate];
    return instance;
}

#pragma mark - main ops

- (void)send:(DSRequestInfo *)requestInfo{
    
    [requestInfo assemble];
    
    //log without headers
    TLOG(@"[Request] %@ %@  %ld %@ ",[requestInfo method], [requestInfo URL].absoluteString, (unsigned long)[requestInfo requestBinary].data.length,  [requestInfo requestBody]);
    
    // log with headers
//    TLOG(@"[Request] %@ %@ %@ %ld %@ ",[requestInfo method], [requestInfo URL].absoluteString, [requestInfo allHTTPHeaderFields], (unsigned long)[requestInfo requestBinary].data.length,  [requestInfo requestBody]);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:requestInfo];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self operation:operation successfulWithResponse:responseObject];
        [self dequeue:operation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        TLOG(@"before failure callback");
        [self operation:operation failedWithError:error];
        [self dequeue:operation];
    }];
    
    
//    oper
    
    [self enqueue:operation];
    
    
}



#pragma mark -

- (void)operation:(AFHTTPRequestOperation *)operation successfulWithResponse:(id)responseDataRaw{
//    TLOG(@"operation.responseString -> %@",operation.responseString);
//    TLOG(@"responseDataRaw -> %@", responseDataRaw);
    NSDictionary *responseHeaders =  operation.response.allHeaderFields;
    AGRemoterResult *result = [AGRemoterResult instance];
    
//    TLOG(@"operation.request.allHeaderFields -> %@", operation.request.allHTTPHeaderFields);
    
    if (responseHeaders != nil) {
        NSString *serverCurrentTime = [responseHeaders objectForKey:@"X-SERVER-CURRENT-TIME"];
        if ([AGNetworkDefine singleton].serverCurrentTimeReceivedBlock) {
            [AGNetworkDefine singleton].serverCurrentTimeReceivedBlock(serverCurrentTime);
        }
    }
    
    id responseData;
    
    if ([responseDataRaw isKindOfClass:[NSDictionary class]]) {
        responseData = [responseDataRaw objectForKey:@"response"];
    }
    
    if (!responseData) responseData = responseDataRaw;
//    TLOG(@"before setCode");
    [result setCode: operation.response.statusCode ];
    [result setRequest: (DSRequestInfo *)[operation request] ];
    [result setResponseData: responseData ];
    [result setResponseHeaders:operation.response.allHeaderFields];
    
    [self processResult:result];
}

- (void)operation:(AFHTTPRequestOperation *)operation failedWithError:(NSError *)error{
    
//    TLOG(@"before assemble error");
    AGRemoterResult *result = [self assembleResultForError:error];
//    DSRequestInfo *request = (DSRequestInfo *)operation.request;
    
    if (operation.isCancelled) {
        [result setCode:1];
    }else{
        [result setCode: operation.response.statusCode ];
    }
//    TLOG(@"before print error detail");
    
//    if ([result isError] && ![result isTimeout]) TLOG(@"[Response Error] %@ %@ %@", [request method], [request URL], error);
    
    [result setRequest:(DSRequestInfo *)[operation request] ];
    [self processResult:result];
}

- (AGRemoterResult *)assembleResultForError:(NSError *)error{
    AGRemoterResult *result = [AGRemoterResult instance];
    
    if (error) {
        AGRemoterResultError *parsedError = [[AGRemoterResultError alloc] init];
        [parsedError updateWithOriginalErrorUserInfo:error.userInfo];
        [parsedError setResult:result];
        [result setErrorParsed:parsedError];
        [result setErrorOrigin:error];
        
    }
    return result;
}

- (void)processResult:(AGRemoterResult *)result{
    DSRequestInfo *request = (DSRequestInfo *)result.request;
    
    TLOG(@"[Response %@] %@ %@ ", result.type.uppercaseString,[request method], [request URL]);
//    TLOG(@"result isError -> %d", result.isError);
    if ( [result isError]){
        TLOG(@"[Response Error] %@ %@ %@", [request method], [request URL], result.errorOrigin);
        [self dispatchRemoterErrorOccured:result];
    }else{
        [self dispatchRemoterResultReceived:result];
    }
    
}

#pragma mark - dispatchers

- (void)dispatchRemoterResultReceived:(AGRemoterResult *)result{
    id responseData = result.responseData;
    DSRequestInfo *request = (DSRequestInfo *)result.request;
    NSString *requestType = request.requestType;
    
    @try {
//        if (delegate&&[delegate respondsToSelector:@selector(remoterDataReceived:withRequestData:)]) {
//            [delegate remoterDataReceived:responseData withRequestData:request];
//        }
        
        if (delegate && [delegate respondsToSelector:@selector(remoterDataReceived:requestType:)]) {
            [delegate remoterDataReceived:responseData requestType:requestType];
        }
        
        if (delegate && [delegate respondsToSelector:@selector(remoterResultReceived:requestType:)]) {
            [delegate remoterResultReceived:result requestType:requestType];
        }
        
    }@catch (NSException *exception) {
//        [AGFlurryMonitor logClientException:exception forRequest:request fnName:CURRENT_FUNCTION_NAME];
    }
    
    //universal data handler
    @try{
        if ([AGNetworkDefine singleton].dataReceivedBlock) {
            [AGNetworkDefine singleton].dataReceivedBlock(responseData, request);
        }
    }@catch (NSException *exception) {
//        [AGFlurryMonitor logClientException:exception forRequest:request fnName:CURRENT_FUNCTION_NAME];
    }
}

- (void)dispatchRemoterErrorOccured:(AGRemoterResult *)result{
    TLOG(@"");
    @try {
//        if ([delegate respondsToSelector:@selector(remoterErrorOccured:)]) {
//            [delegate remoterErrorOccured:result];
//        }
        
        if ([delegate respondsToSelector:@selector(remoterErrorOccured:requestType:)]) {
            [delegate remoterErrorOccured:result requestType:result.request.requestType];
        }
        
    }@catch (NSException *exception) {
//        DSRequest *request = (DSRequest *)result.request;
//        [AGFlurryMonitor logClientException:exception forRequest:request fnName:CURRENT_FUNCTION_NAME];
    }
    
    //universal error handler
    @try {
        if ([AGNetworkDefine singleton].errorOccuredBlock) {
            [AGNetworkDefine singleton].errorOccuredBlock(result);
        }
    }@catch (NSException *exception) {
//        [AGFlurryMonitor logClientException:exception forRequest:result.request fnName:CURRENT_FUNCTION_NAME];
    }
    
    //Monitor actions
    if([result isInvalidAuthentication]){
//        if ([DSReachabilityManager singleton].isInternetReachable) {
//            
//            if ([DSReachabilityManager singleton].isHostReachable) {
////                [AGFlurryMonitor passCheckpoint:CHECKPOINT_SERVER_IS_OOPS];
//            }else if (![DSReachabilityManager singleton].isHostReachable) {
////                [AGFlurryMonitor passCheckpoint:CHECKPOINT_SERVER_IS_DOWN];
//            }
//            
////            [AGFlurryMonitor logServerExceptionWithResult:result];
//
//        }
    }
    
    if (![result isInvalidAuthentication]
        && ![result isInvalidConnection]
        && ![result isCanceled]) {
//        [AGFlurryMonitor logServerExceptionWithResult:result];

    }
}


#pragma mark - error msg assemblers

- (NSString *)assembleErrorDetailForErrorCode:(int)errorCode errorMsg:(NSString *)errorMsg requestUrl:(NSString *)requestUrl{

    NSMutableString *result = [[NSMutableString alloc] init];
    
    if (errorCode!=0) {
        [result appendFormat:@"ErrorCode = %d", errorCode];
    }
    
    if (errorMsg) {
        [result appendFormat:@"\nErrorMessage = %@", errorMsg];
    }
    
    return result;

}

#pragma mark -


- (void)REQUEST:(NSString *)requestType method:(NSString *)method requestBody:(id)requestBody requestBinary:(AGRequestBinary *)requestBinary randomRequestId:(BOOL)randomRequestId protocolVersion:(NSString *)protocolVersion{
    DSRequestInfo *req = [DSRequestInfo instance];
    [req setRequestType:requestType];
    [req setRequestBinary:requestBinary];
    [req setRequestBody:requestBody];
    [req setMethod:method];
    [req setProtocolVersion:protocolVersion];
    [req setRandomRequestId:randomRequestId];
    [self send:req];
}



@end
