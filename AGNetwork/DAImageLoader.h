//
//  DAImageLoader.h
//  AGNetwork
//
//  Created by Tao Yunfei on 5/19/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "DANetworkLoader.h"
#import <UIKit/UIKit.h>
#import "NSObject+Singleton.h"

#define DA_IMAGE_LOADER [DAImageLoader singleton]

@interface DAImageLoader : DANetworkLoader

#pragma mark -
- (void)REQUEST:(NSURL *)imageURL forImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage;
- (void)REQUEST:(NSURL *)url completion:(void(^)(id, id))completion;

@end
