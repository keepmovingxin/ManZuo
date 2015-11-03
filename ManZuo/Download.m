//
//  Download.m
//  DownloadS
//
//  Created by student on 14-2-20.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import "Download.h"

@implementation Download

- (void)downloadData
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:_downloadURL]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}

#pragma mark - NSURLConnectionData Delegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // 初始化_data
    _resultData  = [[NSMutableData alloc] init];
    [_resultData setLength:0];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 下载中追加数据
    [_resultData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 下载完成
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // 调用代理方法
    [_delegate downloadFinishWithClass:self];
    NSLog(@"下载成功");
}

@end
