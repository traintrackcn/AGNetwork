//
//  AGRemoterResultError.m
//  AboveGEM
//
//  Created by traintrackcn on 19/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGRemoterError.h"
#import "DSValueUtil.h"
#import "GlobalDefine.h"
#import "AFURLResponseSerialization.h"


@interface AGRemoterError(){

}

@property (nonatomic, strong) id recoverySuggestion;
@property (nonatomic, strong) id message;
@property (nonatomic, strong) id stack;
@property (nonatomic, strong) id data;

@end

@implementation AGRemoterError

#pragma mark - parsers

- (void)parseErrorRaw:(id)errorRaw{
    
    [self setRaw:errorRaw];
    
    if ([self isAvailableForKey:@"error-code"]) {
        [self setType:[self stringForKey:@"error-code"]];
    }
    
    if ([self isAvailableForKey:@"code"]) {
        [self setType:[self stringForKey:@"code"]];
    }
    
    if ([self isAvailableForKey:@"message"]) {
        [self setMessage:[self stringForKey:@"message"]];
    }
    
    if ([self isAvailableForKey:@"developer-message"]) {
        [self setDevelopMessage:[self stringForKey:@"developer-message"]];
    }
    
    if ([self isAvailableForKey:@"developerMessage"]){
        [self setDevelopMessage:[self stringForKey:@"developerMessage"]];
    }
    
    if ([self isAvailableForKey:@"errorMessage"]){
        [self setMessage:[self stringForKey:@"errorMessage"]];
    }
    
    if ([self isAvailableForKey:@"errorStack"]){
        [self setStack:[self objectForKey:@"errorStack"]];
    }
    
    if ([self isAvailableForKey:@"errorData"]){
        [self setData:[self objectForKey:@"errorData"]];
        
//        if ([self.data isKindOfClass:[NSString class]]){
//            NSString *jsonStr = self.data;
////            jsonStr  = [NSString stringWithFormat:@"{\"errorData\":%@}", jsonStr];
//            jsonStr = [self JSONString:jsonStr];
////            jsonStr = [self appendQuotationMarksForKeysAndValuesInString:jsonStr];
////            jsonStr = @"({\"code\":\"InvalidPhone\",\"field\":\"phone\",\"message\":\"Wrong phone format, 10 digits needed.\"},{\"code\":\"InvalidAddress\",\"field\":\"\"})";
//            TLOG(@"jsonStr -> %@", jsonStr);
//            NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//            NSError *error = nil;
//            id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
//            
//            if(error) {
//                NSLog(@"error -> %@", error);
//            }
//            
////            TLOG(@"jsonData -> %@ jsonObj -> %@",jsonData,  jsonObj);
//            
//            [self setData:jsonObj];
//        }
//        
    }
    
}


//-(NSString *)JSONString:(NSString *)aString {
//    NSMutableString *s = [NSMutableString stringWithString:aString];
//    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@" = " withString:@":" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@";\\n        " withString:@"," options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\\n        " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@";\\n    " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    [s replaceOccurrencesOfString:@"\\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    
//    if ([[s substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"("]){
//        [s replaceCharactersInRange:NSMakeRange(0, 1) withString:@"["];
//    }
//    
//    if ([[s substringWithRange:NSMakeRange(s.length-1, 1)] isEqualToString:@")"]){
//        [s replaceCharactersInRange:NSMakeRange(s.length-1, 1) withString:@"]"];
//    }
//    
//    [s replaceOccurrencesOfString:@"\\\"" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
//    
//    return [NSString stringWithString:s];
//}

//- (NSString *)appendQuotationMarksForKeysAndValuesInString:(NSString *)str{
//    
//    NSString *result;
//    
//    result = [self stringBetweenString:@"{" andString:@":" inString:str];
//    while (result) {
//        TLOG(@"result -> %@", result);
//        result = [self stringBetweenString:@"{" andString:@":" inString:str];
//        str = [str stringByReplacingOccurrencesOfString:result withString:[NSString stringWithFormat:@"\"%@\"", result]];
//    }
//    
//    return str;
//
//}

//- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end inString:(NSString *)str{
//    NSScanner* scanner = [NSScanner scannerWithString:str];
//    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
//    [scanner scanUpToString:start intoString:NULL];
//    if ([scanner scanString:start intoString:NULL]) {
//        NSString* result = nil;
//        if ([scanner scanUpToString:end intoString:&result]) {
//            return result;
//        }
//    }
//    return nil;
//}

- (void)parseResponseRaw:(id)responseRaw{
//    TLOG(@"responseRaw -> %@", responseRaw);
    if ([responseRaw objectForKey:@"message"]){
        [self setMessage:[responseRaw objectForKey:@"message"]];
    }
}

- (void)parseError:(NSError *)error{
    
    id userInfo = error.userInfo;
    
    [self setLocalizedDesc:[userInfo objectForKey:@"NSLocalizedDescription"]];
    [self setFailingURL:[userInfo objectForKey:@"NSErrorFailingURLKey"]];
    
    NSString *recoverySuggestionStr = [userInfo objectForKey:@"NSLocalizedRecoverySuggestion"];
    NSData *recoverySuggestionData;
    
    if (recoverySuggestionStr) {
        recoverySuggestionData = [recoverySuggestionStr dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        recoverySuggestionData = [userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
    }
    
    
    if (recoverySuggestionData){
        [self setRecoverySuggestion:[NSJSONSerialization JSONObjectWithData:recoverySuggestionData options:NSJSONReadingAllowFragments error:nil]];
        
        //if error in meta
        if (self.errorRaw) {
            [self parseErrorRaw:self.errorRaw];
        }
//        else{
//            [self updateWithRaw:self.recoverySuggestion];
//        }
    }
}


#pragma mark - properties

- (id)metaRaw{
    return [self.recoverySuggestion objectForKey:@"meta"];
}

- (id)errorRaw{
    return [self.metaRaw objectForKey:@"error"];
}

- (id)request{
    return [self.recoverySuggestion objectForKey:@"request"];
}

- (id)headers{
    return [self.request objectForKey:@"headers"];
}

- (id)response{
    return [self.recoverySuggestion objectForKey:@"response"];
}


#pragma mark - util


- (NSArray *)messages{
    NSMutableArray *msgs = [NSMutableArray array];
    
    //append message for users
    if (self.message) {
        [msgs addObjectsFromArray:[self.message componentsSeparatedByString:@"\\n"]];
    }
    
//    TLOG(@"self.data -> %@ self.data.class -> %@", self.data, [self.data class]);
    if (self.data){
        NSArray *arr = (NSArray *)self.data;
        for (NSInteger i = 0; i<arr.count; i++) {
            id raw = [arr objectAtIndex:i];
//            TLOG(@"raw -> %@", raw);
            if ([raw objectForKey:@"message"]){
                [msgs addObject:[raw objectForKey:@"message"]];
            }
        }
    }
    
    if (msgs.count == 0) { //if no message for users, append message for developers
        if (self.localizedDesc) [msgs addObject:self.localizedDesc];
        if (self.developMessage){
            if (![self.developMessage isEqualToString:@""]) [msgs addObject:self.developMessage];
        }
        if (self.stack) [msgs addObject:self.stack];
        if (self.data) [msgs addObject:self.data];
    }

    return msgs;
}

@end
