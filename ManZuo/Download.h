//
//  Download.h
//  DownloadS
//
//  Created by student on 14-2-20.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadDelegate <NSObject>
-(void)downloadFinishWithClass:(id)download;
@end

@interface Download : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic,weak) __weak id<DownloadDelegate> delegate;
@property (nonatomic,copy) NSString *downloadURL;
@property (nonatomic,strong) NSMutableData *resultData;
@property (nonatomic) int type;

- (void)downloadData;

@end
