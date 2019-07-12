//
//  NetvoxMqtt.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/6/12.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import <Foundation/Foundation.h>

//注:如无特殊说明userInfo,值为NSDictionary类型
//socket 接收到消息
extern NSString *const kMqttReciveCallbackMsgNotification;

@interface NetvoxMqtt : NSObject



//单例
+(NetvoxMqtt *)shareInstance;

//设置参数
-(void)configWithHost:(NSString *)host port:(UInt32)port houseIeee:(NSString *)houseIeee userName:(NSString *)userName pwd:(NSString *)pwd;

//连接mqtt服务器
-(void)connectCompletionHandler:(void (^)(NSDictionary *validateResult))result ;

//断开mqtt服务器
-(void)disconnect;

//发送请求(发送消息)
-(void)sendUrl:(NSString *)url param:(NSString *)param seq:(NSString *)seq CompletionHandler:(void (^)(NSDictionary *result))result;

//上传文件
-(void)upLoadFileWithparam:(NSString *)param seq:(NSString *)seq CompletionHandler:(void (^)(NSDictionary *result))result;

@end
