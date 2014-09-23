//
//  DSHTTPClient.m
//  og
//
//  Created by traintrackcn on 13-11-9.
//  Copyright (c) 2013 2ViVe. All rights reserved.
//

#import "AGHTTPClient.h"

//DSHTTPClient *__instanceDSHTTPClient;

@implementation AGHTTPClient

//+ (DSHTTPClient *)sharedInstance{
//    if (__instanceDSHTTPClient == nil) {
//        __instanceDSHTTPClient = [[DSHTTPClient alloc] initWithBaseURL: [NSURL URLWithString:@"nil"]];
//#ifdef DEBUG
//        [__instanceDSHTTPClient setAllowsInvalidSSLCertificate:YES];
//#endif
//        [__instanceDSHTTPClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
//    }
//    return __instanceDSHTTPClient;
//}

+ (instancetype)instance{
    return [[self.class alloc] init];
}

- (id)init {
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `sharedInstance:` instead.", NSStringFromClass([self class])] userInfo:nil];
    self = [super initWithBaseURL:[NSURL URLWithString:@"nil"]];
    if (self) {
#ifdef DEBUG
        [self setAllowsInvalidSSLCertificate:YES];
#endif
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    }
    return self;

}

- (BOOL)shouldTrustProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    // Load up the bundled certificate.
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"cert" ofType:@"der"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    CFDataRef certDataRef = (__bridge_retained CFDataRef)certData;
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
    
    // Establish a chain of trust anchored on our bundled certificate.
    CFArrayRef certArrayRef = CFArrayCreate(NULL, (void *)&cert, 1, NULL);
    SecTrustRef serverTrust = protectionSpace.serverTrust;
    SecTrustSetAnchorCertificates(serverTrust, certArrayRef);
    
    // Verify that trust.
    SecTrustResultType trustResult;
    SecTrustEvaluate(serverTrust, &trustResult);
    
    // Clean up.
    CFRelease(certArrayRef);
    CFRelease(cert);
    CFRelease(certDataRef);
    
    // Did our custom trust chain evaluate successfully?
    return trustResult == kSecTrustResultUnspecified;
}


- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(AFHTTPRequestOperation *, id))success
                                                    failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    AFHTTPRequestOperation *operation = [super HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
    
    // Indicate that we want to validate "server trust" protection spaces.
//    [operation setAuthenticationAgainstProtectionSpaceBlock:^BOOL(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace) {
//        return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//    }];
//    
//    // Handle the authentication challenge.
//    [operation setAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
//        if ([self shouldTrustProtectionSpace:challenge.protectionSpace]) {
//            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
//                 forAuthenticationChallenge:challenge];
//        } else {
//            [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
//        }
//    }];
    
//#ifdef _AFNETWORKING_PIN_SSL_CERTIFICATES_
//    TLOG(@"_AFNETWORKING_PIN_SSL_CERTIFICATES_");
//#else
//    [operation setAuthenticationAgainstProtectionSpaceBlock:^BOOL(NSURLConnection *connection, NSURLProtectionSpace *protectionSpace) {
//        TLOG(@"canAuthenticateAgainstProtectionSpace -> %@", protectionSpace.authenticationMethod);
//        return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
////        return YES;
//    }];
//    
//    [operation setAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
//        TLOG(@"didReceiveAuthenticationChallenge -> %@   %d", challenge.protectionSpace.authenticationMethod, challenge.previousFailureCount);
//        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//            [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//        }
//    }];
//#endif
    
    
   
    
    return operation;
}


//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
//        if ([trustedHosts containsObject:challenge.protectionSpace.host])
//            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}


@end
