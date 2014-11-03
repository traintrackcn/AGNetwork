//
//  AGRemoterResultError.h
//  AboveGEM
//
//  Created by traintrackcn on 19/8/14.
//  Copyright (c) 2014 2ViVe. All rights reserved.
//

#import "AGModel.h"

@interface AGRemoterResultError : AGModel

@property (nonatomic, strong) id raw;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *developMessage;
//@property (nonatomic, strong) NSArray *failures;
@property (nonatomic, strong) NSString *localizedDesc;
@property (nonatomic, strong) NSURL *failingURL;

@end
