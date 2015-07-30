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
#import "AGNetworkDefine.h"
#import "NSObject+Singleton.h"
//#import "UIImageView+AFNetworking.h"

#import "DSRequest.h"
#import "DSReachabilityManager.h"

#import "UIImageView+WebCache.h"
#import "UIImageView+AFNetworking.h"

#define kErrorCode @"code"



@interface AGRemoter(){
    int errorOcurredRecent;
    AFHTTPClient *client;
    NSMutableDictionary *imagesLoading;
}

@property (nonatomic, strong) UIImage *dummyImage;

@end


@implementation AGRemoter
@synthesize delegate;

+ (void)initialize{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
//    [AFImageRequestOperation addAcceptableContentTypes:
//     [NSSet setWithObjects:@"image/pjpeg",
//      @"binary/octet-stream",
//      nil]
//     ];
}

- (id)init
{
    self = [super init];
    if (self) {
        if (client == nil) {
            client = [AGHTTPClient instance];
            imagesLoading = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

+ (AGRemoter *)instanceWithDelegate:(id< AGRemoterDelegate>)aDelegate{
    AGRemoter *instance = [[AGRemoter alloc] init];
    [instance setDelegate:aDelegate];
    return instance;
}

- (void)cancelAllRequests{
    [client.operationQueue cancelAllOperations];
    [self cancelAllImageRequests];
}

#pragma mark - images request ops

- (NSString *)keyOfImageRequest:(NSURL *)url{
    return url.absoluteString;
}

- (void)setImageRequest:(NSURL *)url forImageView:(UIImageView *)imageView{
    NSString *key = [self keyOfImageRequest:url];
//    TLOG(@"key -> %@", key);
    [imagesLoading setObject:imageView forKey:key];
}

- (BOOL)isLoadingImageRequest:(NSURL *)url{
    NSString *key = [self keyOfImageRequest:url];
    if ([imagesLoading objectForKey:key] != nil) return YES;
    return NO;
}

- (BOOL)isLoadingAnyImageRequest{
    if (imagesLoading.allKeys.count > 0) return YES;
    return NO;
}

- (void)removeImageReqest:(NSURL *)url{
    NSString *key = [self keyOfImageRequest:url];
    [self removeImageReqestForKey:key];
}

- (UIImage *)dummyImage{
    if (!_dummyImage) {
        _dummyImage = [[UIImage alloc] init];
    }
    return _dummyImage;
}

- (void)removeImageReqestForKey:(NSString *)key{
//    TLOG(@"key -> %@", key);
    UIImageView *imgV = [imagesLoading objectForKey:key];
    @try {
//        TLOG(@"[imgV respondsToSelector:@selector(cancelImageRequestOperation)] -> %d",[imgV respondsToSelector:@selector(cancelImageRequestOperation)] );
        [imgV setImage:self.dummyImage];
        [imgV cancelImageRequestOperation];
        
        
    }@catch (NSException *exception) {
        TLOG(@"exception -> %@", exception);
        
    }
    
    @try {
        [imgV sd_cancelCurrentImageLoad];
    }
    @catch (NSException *exception) {
        TLOG(@"exception -> %@", exception);
    }
    
    [imagesLoading removeObjectForKey:key];
    
}

- (void)cancelAllImageRequests{
    if (imagesLoading.allKeys.count == 0) return;
//    TLOG(@"%@ ===== start",self);
    while (imagesLoading.allKeys.count > 0) {
        NSString *key = [imagesLoading.allKeys objectAtIndex:0];
        [self removeImageReqestForKey:key];
    }
//    TLOG(@"%@ ===== end", self);
}

#pragma mark -

- (void)send:(DSRequest *)req forOrder:(BOOL)isForOrder{
    [req setIsForOrder:isForOrder];
    [req assemble];
    //    [self saveRequestForCallback:req];
    TLOG(@"[Request] %@ %@ %@ %ld",[req method], [req URL].absoluteString, [req contentJSON],(unsigned long)[req contentBinary].length);
//    TLOG(@"[Request] header -> %@", req.allHTTPHeaderFields);
//    if (![AGNetworkConfig singleton].isOG){
//    TLOG(@"request headerFields -> %@", req.allHTTPHeaderFields);
//    }
    
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:req success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self operation:operation successfulWithResponse:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self operation:operation failedWithError:error];
    }];
    
    [client enqueueHTTPRequestOperation:operation];
    
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
    
    id responseData = [responseDataRaw objectForKey:@"response"];
    if (!responseData) {
        responseData = responseDataRaw;
    }
    
    
    [result setCode: operation.response.statusCode ];
    [result setRequest: (DSRequest *)[operation request] ];
    [result setResponseData: responseData ];
    [result setResponseHeaders:operation.response.allHeaderFields];
    
    [self processResult:result];
}

- (void)operation:(AFHTTPRequestOperation *)operation failedWithError:(NSError *)error{
//    TLOG(@"operation.responseString -> %@",operation.responseString);
//    @try {
//        NSString *str = [operation.responseString substringWithRange:NSMakeRange(1427, 20)];
//        TLOG(@"str -> %@", str);
//    }
//    @catch (NSException *exception) {
//        
//    }
    
    AGRemoterResult *result = [self assembleResultForError:error];
    
    if (operation.isCancelled) {
        [result setCode:AGResultCodeOperationCancelled];
    }else{
        [result setCode: operation.response.statusCode ];
    }
    
    [result setRequest:(DSRequest *)[operation request] ];
    [self processResult:result];
}

- (AGRemoterResult *)assembleResultForError:(NSError *)error{
    AGRemoterResult *result = [AGRemoterResult instance];
    TLOG(@"error -> %@", error);
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
        [parsedError setFailingURL:[userInfo objectForKey:@"NSErrorFailingURLKey"]];
        [result setErrorParsed:parsedError];
        [result setErrorOrigin:error];
    }
    return result;
}

- (void)processResult:(AGRemoterResult *)result{
    DSRequest *request = (DSRequest *)result.request;
    
    NSInteger resultCode = [result code];
    NSString *resultStr = [NSString stringWithFormat:@"%ld",(long)resultCode];
    
    if (resultCode == 1) {
        resultStr = @"CANCELED";
    }else if(resultCode == 0){
        resultStr = @"TIMEOUT";
    }
    
    TLOG(@"[Response %@] %@ %@ ", resultStr.uppercaseString,[request method], [request URL]);
    
//    TLOG(@"result isError -> %d", result.isError);
    if ( [result isError]){
        [self dispatchRemoterErrorOccured:result];
    }else{
        [self dispatchRemoterDataReceived:result.responseData withRequest:(DSRequest *)result.request];
    }
    
}





#pragma mark - dispatchers

- (void)dispatchRemoterDataReceived:(id)responseData withRequest:(DSRequest *)request{
    
    @try {
        if (delegate&&[delegate respondsToSelector:@selector(remoterDataReceived:withRequestData:)]) {
            [delegate remoterDataReceived:responseData withRequestData:request];
        }
        
        if (delegate && [delegate respondsToSelector:@selector(remoterDataReceived:requestType:)]) {
            [delegate remoterDataReceived:responseData requestType:request.requestType];
        }
        
    }@catch (NSException *exception) {
        [AGMonitor logClientException:exception forRequest:request fnName:CURRENT_FUNCTION_NAME];
    }
    
    //universal data handler
    @try{
        if ([AGNetworkDefine singleton].dataReceivedBlock) {
            [AGNetworkDefine singleton].dataReceivedBlock(responseData, request);
        }
    }@catch (NSException *exception) {
        [AGMonitor logClientException:exception forRequest:request fnName:CURRENT_FUNCTION_NAME];
    }
}

- (void)dispatchRemoterErrorOccured:(AGRemoterResult *)result{
    
    @try {
        if ([delegate respondsToSelector:@selector(remoterErrorOccured:)]) {
            [delegate remoterErrorOccured:result];
        }
        
        if ([delegate respondsToSelector:@selector(remoterDataReceived:requestType:)]) {
            [delegate remoterErrorOccured:result requestType:result.request.requestType];
        }
        
    }@catch (NSException *exception) {
        DSRequest *request = (DSRequest *)result.request;
        [AGMonitor logClientException:exception forRequest:request fnName:CURRENT_FUNCTION_NAME];
    }
    
    //universal error handler
    @try {
        if ([AGNetworkDefine singleton].errorOccuredBlock) {
            [AGNetworkDefine singleton].errorOccuredBlock(result);
        }
    }@catch (NSException *exception) {
        [AGMonitor logClientException:exception forRequest:result.request fnName:CURRENT_FUNCTION_NAME];
    }
    
    //Monitor actions
    if(result.code == AGResultCodeInvalidConnection){
        if ([DSReachabilityManager singleton].isInternetReachable) {
            
            if ([DSReachabilityManager singleton].isHostReachable) {
                [AGMonitor passCheckpoint:AGCPServerIsOops];
            }else if (![DSReachabilityManager singleton].isHostReachable) {
                [AGMonitor passCheckpoint:AGCPServerIsDown];
            }
            
            [AGMonitor logServerExceptionWithResult:result];

        }
    }
    
    if (result.code != AGResultCodeInvalidAuthentication
        && result.code != AGResultCodeInvalidConnection
        && result.code != AGResultCodeOperationCancelled) {
        [AGMonitor logServerExceptionWithResult:result];

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


- (NSString *)defaultProtocolVersion{
    return [AGNetworkDefine singleton].defaultProtocolVersion;
}

- (NSString *)defaultServerUrl{
    return [AGNetworkDefine singleton].defaultServerUrl;
}

#pragma mark -

- (DSRequest *)assembleDefaultRequestWithRequestType:(NSString *)requestType{
    DSRequest *req = [DSRequest instanceWithRequestType:requestType];
    [req setProtocolVersion: self.defaultProtocolVersion];
    [req setServerUrl: self.defaultServerUrl];
    [req setToken:[AGNetworkDefine singleton].token];
    return req;
}

#pragma mark -

- (void)REQUEST:(NSURL *)imageURL forImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage{
    [imageView setImage:placeholderImage];
    TLOG(@"imageURL -> %@", imageURL);
    if ([DSValueUtil isNotAvailable:imageURL]) return;
    
    NSInteger lTag = 999;
    UIActivityIndicatorView *l = (UIActivityIndicatorView *)[imageView viewWithTag:lTag];
    
    if ([DSValueUtil isNotAvailable:l]) {
        //loading icon
        CGFloat w = 40;
        CGFloat h = 40;
        CGFloat x = (imageView.frame.size.width-w)/2.0;
        CGFloat y = (imageView.frame.size.height-h)/2.0;
        l = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [l setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [l setBackgroundColor:RGBA(242, 242, 242, 1)];
        [l setTag:lTag];
    }
    
    [imageView addSubview:l];
    [l startAnimating];
    
    
    __block UIImageView *v = imageView;
    [self REQUEST:imageURL completion:^(UIImage *image, NSError *error, NSInteger cacheType) {
        [l stopAnimating];
        [l removeFromSuperview];
        if ([DSValueUtil isAvailable:image]) {
            [v setImage:image];
            
            if (cacheType == 0) {
                [v setAlpha:0];
                [UIView animateWithDuration:.33 animations:^{
                    [v setAlpha:1];
                }];
            }
            
            
        }
        
        
    }];
}


- (void)REQUEST:(NSURL *)imageURL completion:(void(^)(UIImage *image, NSError *error, NSInteger cacheType))completion{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:imageURL];
    UIImageView *v = [[UIImageView alloc] init];
    
    [self setImageRequest:imageURL forImageView:v];
    [v sd_setImageWithURL:imageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
//        TLOG(@"cache type -> %ld", cacheType);
        
        if ([DSValueUtil isAvailable:error]) {
            AGRemoterResult *result = [self assembleResultForError:error];
            [result setRequest:(DSRequest *)req];
//            [AGMonitor logServerExceptionWithResult:result];
        }
        
        if([DSValueUtil isAvailable:completion]) completion(image, error, cacheType);
        [self removeImageReqest:imageURL];
        
    }];
}

- (void)GET3:(NSURL *)thirdPartyUrl{
    DSRequest *req = [[DSRequest alloc] initWithURL:thirdPartyUrl];
    [req setIsThirdParty:YES];
    [self send:req forOrder:NO];
}

- (void)GET:(NSString *)requestType protocolVersion:(NSString *)protocolVersion{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setProtocolVersion:protocolVersion];
    [self send:req forOrder:NO];
}

- (void)GET:(NSString *)requestType userInfo:(id)userInfo{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setUserInfo:userInfo];
    [self send:req forOrder:NO];
}

- (void)GET:(NSString *)requestType{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [self send:req forOrder:NO];
}

- (void)POST:(NSString *)requestType binaryData:(NSData *)binaryData{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setContentBinary:binaryData];
    [self send:req forOrder:NO];
}


- (void)POST:(NSString *)requestType requestBody:(id)requestBody forOrder:(BOOL)isForOrder{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setContentJSON:requestBody];
    [self send:req forOrder:isForOrder];
}

- (void)POST:(NSString *)requestType requestBody:(id)requestBody{
    [self POST:requestType requestBody:requestBody forOrder:NO];
}

- (void)PUT:(NSString *)requestType requestBody:(id)requestBody{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
    [req setContentJSON:requestBody];
    [req setMethod:@"PUT"];
    [self send:req forOrder:NO];
}

- (void)DELETE:(NSString *)requestType requestBody:(id)requestBody{
    DSRequest *req = [self assembleDefaultRequestWithRequestType:requestType];
//    TLOG(@"requestBody -> %@", requestBody);
    if (!requestBody) {
        requestBody = @{};
    }
    [req setContentJSON:requestBody];
    [req setMethod:@"DELETE"];
    [self send:req forOrder:NO];
}


@end
