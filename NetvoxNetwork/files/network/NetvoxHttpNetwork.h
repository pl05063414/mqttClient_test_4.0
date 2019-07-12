//
//  NetvoxHttpNetwork.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/24.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  http/https协议的网络请求

#import <Foundation/Foundation.h>


@interface NetvoxHttpNetwork : NSObject

//get请求
+(void)get:(NSString *)url parameters:(NSDictionary *)parameters isYS:(BOOL)isYS CompletionHandler:(void (^)(NSDictionary *results))results;


//post 请求
+(void)post:(NSString *)url parameters:(NSDictionary *)parameters isYS:(BOOL)isYS CompletionHandler:(void (^)(NSDictionary *results))results;

//post 传输数据请求(iOS8 以上系统,minetype:image/png,image/jpeg,application/x-tar) 
//post 传输数据请求(iOS8 以上系统)
+(void)post:(NSString *)url parameters:(NSDictionary *)parameters nameArray:(NSArray *)nameArray formDataArray:(NSArray *)dataArray mimeTypeArray:(NSArray *)mimeTypeArray progress:( void (^)(NSProgress *progress))progress isYS:(BOOL)isYS CompletionHandler:(void (^)(NSDictionary *results))results;

@end
