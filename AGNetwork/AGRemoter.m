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
#import "AGMonitor.h"
#import "AGRemoterResultError.h"
#import "DSValueUtil.h"
#import "AGNetworkConfig.h"
#import "NSObject+Singleton.h"
#import "UIImageView+AFNetworking.h"
#import "DSRequest.h"

#define kErrorCode @"code"



@interface AGRemoter(){
    int errorOcurredRecent;
    AFHTTPClient *client;
    NSMutableArray *imageViewsInRequest;
}

@end


@implementation AGRemoter
@synthesize delegate;

+ (void)initialize{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [AFImageRequestOperation addAcceptableContentTypes:
     [NSSet setWithObject:@"binary/octet-stream"]];
}

- (id)init
{
    self = [super init];
    if (self) {
        if (client == nil) {
            client = [AGHTTPClient instance];
            imageViewsInRequest = [NSMutableArray array];
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
    
    while (imageViewsInRequest.count > 0) {
        UIImageView *imgV = [imageViewsInRequest objectAtIndex:0];
//        [imgV cancelImageRequestOperation];
//        [imageViewsInRequest removeObject:imgV];
        [self removeInRequestImageView:imgV];
    }
}

- (void)removeInRequestImageView:(UIImageView *)imageView{
    [imageView cancelImageRequestOperation];
    [imageViewsInRequest removeObject:imageView];
    
//    TLOG(@"imageViewsInRequest count -> %lu", (unsigned long)imageViewsInRequest.count);
}

#pragma mark -

- (void)send:(DSRequest *)req{
    [req assemble];
    //    [self saveRequestForCallback:req];
    TLOG(@"[Request] %@ %@ %@ %ld",[req method], [req URL].absoluteString, [req contentJSON],[req contentBinary].length);
    
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
    AGRemoterResult *result = [self parseError:error];
    
    if (operation.isCancelled) {
        [result setCode:AGResultCodeOperationCancelled];
    }else{
        [result setCode: operation.response.statusCode ];
    }
    
    [result setRequest: [operation request] ];
    [self processResult:result];
}

- (AGRemoterResult *)parseError:(NSError *)error{
    AGRemoterResult *result = [AGRemoterResult instance];
    
    
//    TLOG(@"error -> %@", error);
    //    TLOG(@"operation.hasStatusCode -> %d error -> %@", operation.hasAcceptableStatusCode, error);
    
    if ([DSValueUtil isAvailable:error]) {
        AGRemoterResultError *parsedError = [[AGRemoterResultError alloc] init];
        NSDictionary *userInfo = error.userInfo;
        NSString *recoverySuggestionStr = [userInfo objectForKey:@"NSLocalizedRecoverySuggestion"];
        if ([DSValueUtil isAvailable:recoverySuggestionStr ]) {
            NSData *recoverySuggestionData = [recoverySuggestionStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *recoverySuggestionObj  = [NSJSONSerialization JSONObjectWithData:recoverySuggestionData options:NSJSONReadingAllowFragments error:nil];
            NSDictionary *meta = [recoverySuggestionObj objectForKey:@"meta"];
            id errorRaw = [meta objectForKey:@"error"];
            [parsedError updateWithRaw:errorRaw];
        }
        [parsedError setLocalizedDesc:[userInfo objectForKey:@"NSLocalizedDescription"]];
        [parsedError setFailingUrl:[userInfo objectForKey:@"NSErrorFailingURLKey"]];
        [result setErrorParsed:parsedError];
        [result setErrorOrigin:error];
    }
    return result;
}

- (void)processResult:(AGRemoterResult *)result{
    DSRequest *request = (DSRequest *)result.request;
    TLOG(@"[Response %ld] %@ %@ ", (long)[result code],[request method], [request url]);
    if ( [result isError]){
//        TLOG(@"[Response error] -> %@", result.error);
        // process usual error
        
        [self dispatchRemoterErrorOccured:result];
        
        //log erver side exceptions to flurry
        if (result.code != AGResultCodeOperationCancelled) {
            [AGMonitor logServerExceptionWithResult:result];
        }
        
    }else{
        [self dispatchRemoterDataReceived:result.responseData withRequest:(DSRequest *)result.request];
    }
    
}





#pragma mark - dispatchers

- (void)dispatchRemoterDataReceived:(id)responseData withRequest:(DSRequest *)request{
    if (delegate&&[delegate respondsToSelector:@selector(remoterDataReceived:withRequestData:)]) {
        @try {
            [delegate remoterDataReceived:responseData withRequestData:request];
            
            if ([DSValueUtil isAvailable:[AGNetworkConfig singleton].dataReceivedBlock]) {
                [AGNetworkConfig singleton].dataReceivedBlock(responseData, request);
            }
            
            
        }@catch (NSException *exception) {
            [AGMonitor logClientException:exception forRequest:request];
        }
    }
}

- (void)dispatchRemoterErrorOccured:(AGRemoterResult *)result{
    if ([delegate respondsToSelector:@selector(remoterErrorOccured:)]) {
        @try {
            [delegate remoterErrorOccured:result];
            if ([DSValueUtil isAvailable:[AGNetworkConfig singleton].errorOccuredBlock]) {
                [AGNetworkConfig singleton].errorOccuredBlock(result);
            }
            
        }@catch (NSException *exception) {
            DSRequest *request = (DSRequest *)result.request;
            [AGMonitor logClientException:exception forRequest:request];
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


- (NSString *)defaultProtocolVersion{
    return [AGNetworkConfig singleton].defaultProtocolVersion;
}

- (NSString *)defaultServerUrl{
    return [AGNetworkConfig singleton].defaultServerUrl;
}

#pragma mark -

- (DSRequest *)assembleDefaultRequestWithRequestType:(NSString *)requestType{
    DSRequest *req = [DSRequest instanceWithRequestType:requestType];
    [req setProtocolVersion: self.defaultProtocolVersion];
    [req setServerUrl: self.defaultServerUrl];
    [req setToken:[AGNetworkConfig singleton].token];
    return req;
}

#pragma mark -

- (void)REQUEST:(NSURL *)imageURL forImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:imageURL];
    
    __block UIImageView *imgV = imageView;
    
    [imageViewsInRequest addObject:imageView];
    
    [imageView setImageWithURLRequest:req placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [imgV setImage:image];
        [self removeInRequestImageView:imgV];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        TLOG(@"response.MIMEType -> %@", response.MIMEType);
        AGRemoterResult *result = [self parseError:error];
        [result setRequest:request];
        [result setCode:response.statusCode];
        
        [AGMonitor logServerExceptionWithResult:result];
        [self removeInRequestImageView:imgV];
        
    }];
}

- (void)GET:(NSString *)requestType protocolVersion:(NSString *)protocolVersion{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setProtocolVersion:protocolVersion];
    [self send:req];
}

- (void)GET:(NSString *)requestType userInfo:(id)userInfo{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setUserInfo:userInfo];
    [self send:req];
}

- (void)GET:(NSString *)requestType{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [self send:req];
}

- (void)POST:(NSString *)requestType binaryData:(NSData *)binaryData{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setContentBinary:binaryData];
    [self send:req];
}

- (void)POST:(NSString *)requestType requestBody:(id)requestBody{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setContentJSON:requestBody];
    [self send:req];
}

- (void)PUT:(NSString *)requestType requestBody:(id)requestBody{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setContentJSON:requestBody];
    [req setMethod:@"PUT"];
    [self send:req];
}

- (void)DELETE:(NSString *)requestType requestBody:(id)requestBody{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setContentJSON:requestBody];
    [req setMethod:@"DELETE"];
    [self send:req];
}


@end
