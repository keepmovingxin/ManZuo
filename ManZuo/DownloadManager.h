//
//  DownloadManager.h
//  DownloadS
//
//  Created by student on 14-2-20.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Download.h"

@interface DownloadManager : NSObject<DownloadDelegate>

+(DownloadManager *)sharedDownloadManager;
// 判断网络是否可用
- (BOOL)haveNet;
// 添加下载方法
-(void)addDownLoadWithURL:(NSString *)url andType:(int)type;
// 通过url这个key去取得对应的下载数据
-(NSArray *)loadDataWithUrl:(NSString *)url;
@end
