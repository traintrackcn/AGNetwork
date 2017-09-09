//
//  LITCollectionLoader.m
//  AboveGEM
//
//  Created by Tao Yunfei on 22/08/2017.
//
//

#import "LITLoader.h"
#import "DARequestUniversal.h"

@interface LITLoader(){
    
}

@property (nonatomic, strong) void(^completion)(id data, id error);

@end

@implementation LITLoader

- (void)requestWithCompletion:(void (^)(id, id))completion{
    [self setCompletion:completion];
    
    if (self.cache) {
        [self completion:self.cache error:nil];
        return;
    }
    
    [DA_REQUEST_UNIVERSAL_INSTANCE requestWithCompletion:^(id data, id error) {
        [self requestCallback:data error:error];
    } method:self.method requestType:self.requestType requestBody:self.requestBody protocolVersion:self.protocolVersion];
    
}

- (void)requestCallback:(id)data error:(id)error{
    
    if (error) {
        [self completion:data error:error];
        return;
    }
    
    [self parse:data];
    
}

- (void)completion:(id)parsedData error:(id)error{
//    TLOG(@"self.completion -> %@", self.completion);
    if(self.completion) self.completion(parsedData, error);
}

- (void)parse:(id)data{
    if (_delegate && [_delegate respondsToSelector:@selector(parse:)]){
        [_delegate parse:data];
    }
}

#pragma mark - properties

- (NSString *)requestType{
    if (_delegate && [_delegate respondsToSelector:@selector(requestType)]){
        return [_delegate requestType];
    }
    return nil;
}

- (AGRemoteUnitMethod)method{
    if (_delegate && [_delegate respondsToSelector:@selector(method)]){
        return [_delegate method];
    }
    return AGRemoteUnitMethodGET;
}

- (id)requestBody{
    if (_delegate && [_delegate respondsToSelector:@selector(requestBody)]){
        return [_delegate requestBody];
    }
    return nil;
}

- (id)cache{
    if (_delegate && [_delegate respondsToSelector:@selector(cache)]){
        return [_delegate cache];
    }
    return nil;
}

- (id)protocolVersion{
    if (_delegate && [_delegate respondsToSelector:@selector(protocolVersion)]){
        return [_delegate protocolVersion];
    }
    return nil;
}

//- (id)requestForm{
//    if (_delegate && [_delegate respondsToSelector:@selector(requestForm)]){
//        return [_delegate requestForm];
//    }
//    return nil;
//}

@end
