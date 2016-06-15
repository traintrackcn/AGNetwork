//
//  NSObject+ImageLoader.m
//  Distributors
//
//  Created by Tao Yunfei on 6/15/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "NSObject+ImageLoader.h"
#import "NSObject+ObjPool.h"
#import "GlobalDefine.h"

@implementation NSObject (ImageLoader)

- (DAImageLoader *)imageLoader{
    NSString *key = CURRENT_FUNCTION_NAME;
    DAImageLoader *item = [self.objPool objectForKey:key];
    if (!item){
        item = [DAImageLoader instance];
        [self.objPool setObject:item forKey:key];
    }
    return item;
}

@end
