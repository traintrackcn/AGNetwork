//
//  DAFileLoader.m
//  AGNetwork
//
//  Created by Tao Yunfei on 5/19/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "DAFileLoader.h"
#import "AFHTTPRequestOperation.h"
#import "GlobalDefine.h"
//#import "AFHTTPClient.h"
@import UIKit;
#import "DAFileUtil.h"

@interface DAFileLoader(){
    
}

@end

@implementation DAFileLoader


- (void)REQUEST:(NSURL *)fileURL localURL:(NSURL *)localURL completion:(void(^)(id data, id error))completion{
    
    if ([DA_FILE_UTIL isExistLocalURL:localURL]) {
        NSData *data = [NSData dataWithContentsOfFile:localURL.absoluteString];
        TLOG(@"[in cache] %@", localURL.absoluteString);
        completion(data, nil);
        return;
    }
    
    
//    AFHTTPRequestOperation *operation = [self operationInstanceWithFileURL:fileURL localURL:localURL completion:completion];
//    [self.client enqueueHTTPRequestOperation:operation];
    
    AFHTTPRequestOperation *operation = [self operationInstanceWithFileURL:fileURL localURL:localURL completion:completion];
    [operation start];
}

- (AFHTTPRequestOperation *)operationInstanceWithFileURL:(NSURL *)fileURL localURL:(NSURL *)localURL completion:(void(^)(id, id))completion{
    NSMutableURLRequest* rq = [NSMutableURLRequest requestWithURL:fileURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:rq];
    
    //    NSString* path=[@"/PATH/TO/APP" stringByAppendingPathComponent: imageNameToDisk];
    NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:localURL.absoluteString append:NO];
    [operation setOutputStream:outputStream];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
        TLOG(@"file completed %@", localURL.absoluteString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
    
//    [operation start];
    return operation;
}



@end
