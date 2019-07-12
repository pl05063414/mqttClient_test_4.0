//
//  SocketManager.h
//  NetvoxNetTest
//
//  Created by netvox-ios6 on 16/4/20.
//  Copyright © 2016年 netvox-ios6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetvoxGCDAsyncSocket.h"

//注:如无特殊说明userInfo,值为NSDictionary类型
//socket 接收到消息
extern NSString *const kSocketReciveCallbackMsgNotification;



@interface NetvoxSocketManager : NSObject<NetvoxGCDAsyncSocketDelegate>

//socket
@property(nonatomic,strong)NetvoxGCDAsyncSocket *callbackSocket;
//发送心跳计时器
@property (nonatomic, retain) NSTimer *connectTimer;
//host
@property (nonatomic,strong)NSString *socketHost;
//port
@property (nonatomic,assign)int socketPort;



//****************方法集******************
//单例
+(NetvoxSocketManager *)shareInstance;

//设置socket 连接host
-(void)setSocketHost:(NSString *)host;

//socket连接到服务器
-(void)socketConnectCallbackSocketCompletionHandler:(void (^)(NSDictionary *validateResult))result ;


////socket连接到服务器
//-(void)socketConnectToHost:(NSString *)host CompletionHandler:(void (^)(NSDictionary *validateResult))result ;

//socket断开连接
-(void)cutOffSocket;

//cgi请求
-(void)requstWithCGI:(NSString *)requstCGI seq:(NSString *)seq type:(int)type CompletionHandler:(void (^)(NSDictionary *result))result;



@end
