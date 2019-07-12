//
//  NetvoxCallback.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/23.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import "NetvoxCallback.h"
#import "NetvoxSocketManager.h"
#import "NetvoxMqtt.h"
#import "NetvoxUserInfo.h"
#import "NetvoxDb.h"


NSString *const kCallbackReciveMsgNotification = @"kCallbackReciveMsgNotification";

@implementation NetvoxCallback

+(NetvoxCallback *)shareInstance
{
    static NetvoxCallback *sharedInstace = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        sharedInstace = [[self alloc]init];
        NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
        //        接收socket callback消息通知
        [notificationCenter addObserver:sharedInstace selector:@selector(receiveSocketCallbackMsgNotice:) name:kSocketReciveCallbackMsgNotification object:nil];
        [notificationCenter addObserver:sharedInstace selector:@selector(receiveMqttCallbackMsgNotice:) name:kMqttReciveCallbackMsgNotification object:nil];
        [notificationCenter addObserver:sharedInstace selector:@selector(receiveNetworkStatusNotice:) name:kNetworkStatusNotification object:nil];
        
    });
    
    return sharedInstace;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//mqtt calback 接收
-(void)receiveMqttCallbackMsgNotice:(NSNotification *)notification
{
    NSDictionary *msg=notification.userInfo;
    [NetvoxCallback dealWithCallback:msg];
}

//socket callback 接收
-(void)receiveSocketCallbackMsgNotice:(NSNotification *)notification
{
    NSDictionary *msg=notification.userInfo;
    [NetvoxCallback dealWithCallback:msg];
}
//callback 处理
+(void)dealWithCallback:(NSDictionary *)msg
{
    //    NSLog(@"callback消息处理:%@",msg)
     dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSString *type = [NSString stringWithFormat:@"%d",[[msg objectForKey:@"type"] intValue]];
    //告警消息处理
    if ([type intValue] == 20001 || [type intValue] == 30001 || [type intValue] == 40001) {
        [NetvoxCallback saveWarnMsg:msg];
    }
    NSNotification *notice=[NSNotification notificationWithName:kCallbackReciveMsgNotification object:type userInfo:msg];
    [[NSNotificationCenter defaultCenter] postNotification:notice];
    });
}

//存储告警消息
+(void)saveWarnMsg:(NSDictionary *)msg
{
   
    [NetvoxDb insert:TABLE_MSG data:msg];
    
}



#pragma mark--监听type设置
//object 监听type设置
+(NSString *)type:(int)type
{
    return [NSString stringWithFormat:@"%d",type];
}

#pragma mark--网络状态监听
-(void)receiveNetworkStatusNotice:(NSNotification *)notification
{
    NSDictionary *msg=notification.userInfo;
    int status = [msg[@"status"] intValue];
    [[NetvoxMqtt shareInstance] disconnect];
    [[NetvoxSocketManager shareInstance] cutOffSocket];
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    switch (status) {
        case 0:
        {//wifi(该情况,同时连接内外网callback,直到有一种方式可以连接上)
//            NSLog(@"wifi");
            if (user.isLocalLogin) {
                [[NetvoxSocketManager shareInstance] socketConnectCallbackSocketCompletionHandler:^(NSDictionary *validateResult) {
                    if ([validateResult[@"status_code"] intValue] == 0) {
                        user.currentConnectType = currentConnectTypeSocket;
                        user.netConnect = connectTypeLocal;
                        
                    }
                    else
                    {
                        [[NetvoxMqtt shareInstance] disconnect];
                    }
                }];
            }
            else{
                [[NetvoxMqtt shareInstance] connectCompletionHandler:^(NSDictionary *validateResult) {
                    if ([validateResult[@"status_code"] intValue] == 88888) {
                        user.currentConnectType = currentConnectTypeMqtt;
                        user.netConnect = connectTypeWide;
                    }
                    else
                    {
                        [[NetvoxSocketManager shareInstance] cutOffSocket];
                    }
                    
                }];
            }
  
        }
            
            break;
        case 1:
            //蜂窝数据
//            NSLog(@"蜂窝数据");
            [[NetvoxMqtt shareInstance] connectCompletionHandler:^(NSDictionary *validateResult) {
                
            }];
            
            break;
            
        default:
            //无网络
//          NSLog(@"无网络");
            
            break;
    }

}
@end
