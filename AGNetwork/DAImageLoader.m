//
//  DAImageLoader.m
//  AGNetwork
//
//  Created by Tao Yunfei on 5/19/16.
//  Copyright © 2016 AboveGEM. All rights reserved.
//

#import "DAImageLoader.h"
#import "AFHTTPClient.h"
#import "AFImageRequestOperation.h"
#import "GlobalDefine.h"
#import "DAFileUtil.h"

@interface DAImageLoader(){
    
}

@property (nonatomic, strong) UIImage *dummyImage;
//@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation DAImageLoader

#pragma mark - images request ops

- (UIImage *)dummyImage{
    if (!_dummyImage) {
        _dummyImage = [[UIImage alloc] init];
    }
    return _dummyImage;
}

- (UIActivityIndicatorView *)indicatorViewInstanceForImageView:(UIImageView *)imageView{
//    if (!_indicatorView) {
    CGFloat w = 40;
    CGFloat h = 40;
    CGFloat x = (imageView.frame.size.width-w)/2.0;
    CGFloat y = (imageView.frame.size.height-h)/2.0;
    UIActivityIndicatorView *v = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [v setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [v setBackgroundColor:RGBA(242, 242, 242, 1)];
    [v setTag:self.indicatorViewTag];
//    }
    return v;
}

- (NSInteger)indicatorViewTag{
    return 999;
}

#pragma mark -

- (void)REQUEST:(NSURL *)url forImageView:(UIImageView *)imageView placeholderImage:(UIImage *)placeholderImage{
    [imageView setImage:placeholderImage];
    //    TLOG(@"imageURL -> %@", imageURL);
    if (!url) return;
    
    UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[imageView viewWithTag:self.indicatorViewTag];
    
    if (indicatorView) {
        indicatorView = [self indicatorViewInstanceForImageView:imageView];
        [imageView addSubview:indicatorView];
    }
    
    [indicatorView startAnimating];
    
    __block UIImageView *v = imageView;
    [self REQUEST:url completion:^(id data, id error) {
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
        if (data) {
            [v setImage:data];
            [v setAlpha:0];
            [UIView animateWithDuration:.33 animations:^{
                [v setAlpha:1];
            }];
        }
    }];
}

- (void)REQUEST:(NSURL *)url completion:(void(^)(id, id))completion{
    NSURL *localURL = [DA_FILE_UTIL localURLWithDownloadURL:url];
    if ([DA_FILE_UTIL isExistLocalURL:localURL]) {
        UIImage *img = [UIImage imageWithContentsOfFile:localURL.absoluteString];
        completion(img, nil);
        return;
    }
    
    AFImageRequestOperation *item = [self operationInstanceWithURL:url completion:completion];
    [self.client enqueueHTTPRequestOperation:item];
}

#pragma mark -

- (AFImageRequestOperation *)operationInstanceWithURL:(NSURL *)url completion:(void(^)(id, id))completion{
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
    AFImageRequestOperation *item = [[AFImageRequestOperation alloc] initWithRequest:req];
    [item setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSURL *localURL = [DA_FILE_UTIL localURLWithDownloadURL:url];
        [DA_FILE_UTIL writeImage:responseObject toLocalURL:localURL];
        
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
    return item;
}

@end
