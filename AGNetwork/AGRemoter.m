//
//  AGRemoter.m
//  DirectSale
//
//  Created by Sean Guo on 7/14/12.
//  Copyright (c) 2012 Voxeo. All rights reserved.
//

#import "AGRemoter.h"
#import "AGHTTPClient.h"
#import "AGRemoterResult.h"
#import "GlobalDefine.h"
#import "AGRemoteMonitor.h"
#import "AGRemoterResultError.h"
#import "DSValueUtil.h"

#define kErrorCode @"code"



@interface AGRemoter(){
    int errorOcurredRecent;
    AFHTTPClient *client;
}

@end


@implementation AGRemoter
@synthesize delegate;

+ (void)initialize{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
}

- (id)init
{
    self = [super init];
    if (self) {
        if (client == nil) {
            client = [AGHTTPClient instance];
        }
    }
    return self;
}

+ (AGRemoter *)instanceWithDelegate:(id< AGRemoterDelegate>)aDelegate{
    AGRemoter *r = [[AGRemoter alloc] init];
    [r setDelegate:aDelegate];
    return r;
}

- (void)cancelAllRequests{
//    TLOG(@"");
    [client.operationQueue cancelAllOperations];
}


#pragma mark -

- (void)execute:(DSRequest *)req{
    [req assemble];
    //    [self saveRequestForCallback:req];
    TLOG(@"[Request] %@ %@ %@",[req method], [req URL].absoluteString, [req contentJSON]);
    
    [client enqueueHTTPRequestOperation:
     [client HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self operation:operation successfulWithResponse:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self operation:operation failedWithError:error];
    }]
     ];
    
}


#pragma mark -

- (void)operation:(AFHTTPRequestOperation *)operation successfulWithResponse:(id)responseDataRaw{
    NSDictionary *responseHeaders =  operation.response.allHeaderFields;
    AGRemoterResult *result = [AGRemoterResult instance];
    
//    TLOG(@"operation.request.allHeaderFields -> %@", operation.request.allHTTPHeaderFields);
    
    if (responseHeaders != nil) {
        NSString *serverCurrentTime = [responseHeaders objectForKey:@"X-SERVER-CURRENT-TIME"];
//        [[AGSession singleton] setServerCurrentTime:serverCurrentTime];
        [self dispatchRemoterGetServerCurrentTime:serverCurrentTime];
    }
    
    
    [result setCode: operation.response.statusCode ];
    [result setRequest: (DSRequest *)[operation request] ];
    [result setResponseData: [responseDataRaw objectForKey:@"response"] ];
    [result setResponseHeaders:operation.response.allHeaderFields];
    
    [self processResult:result];
}

- (void)operation:(AFHTTPRequestOperation *)operation failedWithError:(NSError *)error{
    AGRemoterResult *result = [AGRemoterResult instance];
    
//    TLOG(@"operation.hasStatusCode -> %d error -> %@", operation.hasAcceptableStatusCode, error);
    
    if ([DSValueUtil isAvailable:error]) {
        NSString *recoverySuggestionStr = [error.userInfo objectForKey:@"NSLocalizedRecoverySuggestion"];
        if ([DSValueUtil isAvailable:recoverySuggestionStr ]) {
            NSData *recoverySuggestionData = [recoverySuggestionStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *recoverySuggestion  = [NSJSONSerialization JSONObjectWithData:recoverySuggestionData options:NSJSONReadingAllowFragments error:nil];
            NSDictionary *meta = [recoverySuggestion objectForKey:@"meta"];
            id errorRaw = [meta objectForKey:@"error"];
            AGRemoterResultError *error = [[AGRemoterResultError alloc] initWithRaw:errorRaw];
            [result setError: error];
        }
    }
    
    if (operation.isCancelled) {
        [result setCode:AGResultCodeOperationCancelled];
    }else{
        
        [result setCode: operation.response.statusCode ];
    }
    
    [result setRequest: (DSRequest *)[operation request] ];
    [self processResult:result];
}



- (void)processResult:(AGRemoterResult *)result{
    DSRequest *request = result.request;
    TLOG(@"[Response %ld] %@ %@ ", (long)[result code],[request method], [request url]);
    if ( [result isError]){
//        TLOG(@"[Response error] -> %@", result.error);
        // process usual error
        
        [self dispatchRemoterErrorOccured:result];
        
        //log erver side exceptions to flurry
        if (result.code != AGResultCodeOperationCancelled) {
            [AGRemoteMonitor logServerExceptionWithResult:result forRequest:request];
        }
        
    }else{
        [self dispatchRemoterDataReceived:result.responseData withRequest:result.request];
    }
    
}





#pragma mark - dispatchers

- (void)dispatchRemoterDataReceived:(id)responseData withRequest:(DSRequest *)request{
    if (delegate&&[delegate respondsToSelector:@selector(remoterDataReceived:withRequestData:)]) {
        @try {
            [delegate remoterDataReceived:responseData withRequestData:request];
        }@catch (NSException *exception) {
            [AGRemoteMonitor logClientException:exception forRequest:request];
        }
    }
}

- (void)dispatchRemoterErrorOccured:(AGRemoterResult *)result{
    if ([delegate respondsToSelector:@selector(remoterErrorOccured:)]) {
        @try {
            [delegate remoterErrorOccured:result];
        }@catch (NSException *exception) {
            DSRequest *request = result.request;
            [AGRemoteMonitor logClientException:exception forRequest:request];
        }
    }
}


- (void)dispatchRemoterGetServerCurrentTime:(NSString *)serverCurrentTime{
    if ([delegate respondsToSelector:@selector(remoterGetServerCurrentTime:)]) {
        [delegate remoterGetServerCurrentTime:serverCurrentTime];
        TLOG(@"serverCurrentTime -> %@", serverCurrentTime);
    }
}


//- (void)processErrorShoppingServiceUnavailable{
//    [[DSServiceManager sharedInstance] closeShopping];
//}


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

- (void)GET:(NSString *)requestType{
    DSRequest *req = [[DSRequest alloc] initWithRequestType:requestType];
    [self execute:req];
}

- (void)POST:(NSString *)requestType requestBody:(id)requestBody{
    DSRequest *req = [[DSRequest alloc] initWithRequestType:requestType];
    [req setContentJSON:requestBody];
    [self execute:req];
}

- (void)PUT:(NSString *)requestType requestBody:(id)requestBody{
    DSRequest *req = [[DSRequest alloc] initWithRequestType:requestType];
    [req setContentJSON:requestBody];
    [req setMethod:@"PUT"];
    [self execute:req];
}

- (void)DELETE:(NSString *)requestType requestBody:(id)requestBody{
    DSRequest *req = [[DSRequest alloc] initWithRequestType:requestType];
    [req setContentJSON:requestBody];
    [req setMethod:@"DELETE"];
    [self execute:req];
}


@end
