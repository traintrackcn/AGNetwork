//
//  AGRequestBinaryParam.h
//  AGNetwork
//
//  Created by Tao Yunfei on 3/2/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "AGModel.h"

@interface AGRequestBinary : AGModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSData *data;


@end
