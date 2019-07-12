//
//  NetvoxHttpNetwork.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/24.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import "NetvoxHttpNetwork.h"
#import "NetvoxAFNetworking.h"
#import "NetvoxUserInfo.h"
#import "NetvoxCommon.h"

@implementation NetvoxHttpNetwork

//get请求
+(void)get:(NSString *)url parameters:(NSDictionary *)parameters isYS:(BOOL)isYS CompletionHandler:(void (^)(NSDictionary *results))results
{
    NetvoxAFHTTPSessionManager * manager = [NetvoxAFHTTPSessionManager manager];
    manager.requestSerializer = [NetvoxAFHTTPRequestSerializer serializer];
    
    manager.responseSerializer = [NetvoxAFHTTPResponseSerializer serializer];
    
     url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    manager.responseSerializer.acceptableContentTypes  = [NSSet setWithObjects:@"application/xml",@"text/xml",@"text/plain",@"application/json",@"text/html",@"text/javascript",nil];
    
//    manager.requestSerializer.timeoutInterval = [NetvoxUserInfo shareInstance].requstTime;
    manager.requestSerializer.timeoutInterval = 30;
    NSString *code = isYS ? @"code" : @"status_code";
    id codeFail = isYS ? @"-404" : @-404;
    id codeParseFail = isYS ? @"-410" : @-410;
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *checkStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *dic;
        if ([checkStr rangeOfString:@"({"].location != NSNotFound) {
            //内网请求
            dic = [NetvoxCommon screenData:checkStr];
        }
        else
        {
            //其他请求
            dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        }
        
        
        if (dic) {
           results(dic);
        }
        else
        {
            results(@{@"seq":@"1234",code:codeParseFail,@"result":@"Data parsing failed"});
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
       results(@{@"seq":@"1234",code:codeFail,@"result":@"fail"});
        
    }];
}


//post 请求
+(void)post:(NSString *)url parameters:(NSDictionary *)parameters isYS:(BOOL)isYS CompletionHandler:(void (^)(NSDictionary *results))results
{
    NetvoxAFHTTPSessionManager * manager = [NetvoxAFHTTPSessionManager manager];
    manager.requestSerializer = [NetvoxAFHTTPRequestSerializer serializer];
//    manager.requestSerializer.timeoutInterval = [NetvoxUserInfo shareInstance].requstTime;
    manager.responseSerializer = [NetvoxAFHTTPResponseSerializer serializer];
    
     url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    manager.responseSerializer.acceptableContentTypes  = [NSSet setWithObjects:@"application/xml",@"text/xml",@"text/plain",@"application/json",@"text/html",nil];
    manager.requestSerializer.timeoutInterval = [NetvoxUserInfo shareInstance].requstTime;
    NSString *code = isYS ? @"code" : @"status_code";
    id codeFail = isYS ? @"-404" : @-404;
    id codeParseFail = isYS ? @"-410" : @-410;
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *checkStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *dic;
        if ([checkStr rangeOfString:@"({"].location != NSNotFound) {
            //内网请求
            dic = [NetvoxCommon screenData:checkStr];
        }
        else
        {
            //其他请求
            dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        }

        if (dic) {
            results(dic);
        }
        else
        {
            results(@{@"seq":@"1234",code:codeParseFail,@"result":@"Data parsing failed"});
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        results(@{@"seq":@"1234",code:codeFail,@"result":@"fail"});
        
    }];
}


//post 传输数据请求(iOS8 以上系统)
+(void)post:(NSString *)url parameters:(NSDictionary *)parameters nameArray:(NSArray *)nameArray formDataArray:(NSArray *)dataArray mimeTypeArray:(NSArray *)mimeTypeArray progress:( void (^)(NSProgress *progress))progress isYS:(BOOL)isYS CompletionHandler:(void (^)(NSDictionary *results))results
{
    NetvoxAFHTTPSessionManager * manager = [NetvoxAFHTTPSessionManager manager];
    manager.requestSerializer = [NetvoxAFHTTPRequestSerializer serializer];
//    manager.requestSerializer.timeoutInterval = [NetvoxUserInfo shareInstance].requstTime;
    manager.responseSerializer = [NetvoxAFHTTPResponseSerializer serializer];
    
    //    if (!parameters) {
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //    }
    
    manager.responseSerializer.acceptableContentTypes  = [NSSet setWithObjects: @"application/xml",@"text/xml",@"text/plain",@"application/json",@"text/html",nil];
    manager.requestSerializer.timeoutInterval = [NetvoxUserInfo shareInstance].requstTime;
    NSString *code = isYS ? @"code" : @"status_code";
    id codeFail = isYS ? @"-404" : @-404;
    id codeParseFail = isYS ? @"-410" : @-410;
    
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<NetvoxAFMultipartFormData>  _Nonnull formData) {
        
        //        [formData appendPartWithFormData:data name:name];
        for (int i = 0; i<nameArray.count; i++) {
            NSData *data = dataArray[i];
            NSString *name = nameArray[i];
            NSString *mimeType = mimeTypeArray[i];
            [formData appendPartWithFileData:data name:name fileName:name mimeType:mimeType];
        }
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (dic) {
            results(dic);
        }
        else
        {
            results(@{@"seq":@"1234",code:codeParseFail,@"result":@"Data parsing failed"});
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        results(@{@"seq":@"1234",code:codeFail,@"result":@"fail"});
    }];
    
    
}




@end
