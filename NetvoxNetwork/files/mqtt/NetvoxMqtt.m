//
//  NetvoxMqtt.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/6/12.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import "NetvoxMqtt.h"
#import "MQTTClient.h"
#import "NetvoxCommon.h"
#import "NetvoxResultModel.h"
#import "NetvoxUserInfo.h"


NSString *const kMqttReciveCallbackMsgNotification = @"kMqttReciveCallbackMsgNotification";

@interface NetvoxMqtt ()<MQTTSessionDelegate>
{
    //mqtt session
    MQTTSession *mqttSession;
    
    //host
    NSString *mqttHost;
    
    //mqtt port
    UInt32 mqttPort ;
    
    //请求topic(一般不注册该topic)
    NSString *mqttReqTopic;
    
    //接收topic
    NSString *mqttResTopic;
    
    //callback topic(根据需要注册)
    
    //系统级别的消息
    NSString *mqttLevel0Topic;
    
    //最最要的告警消息
    NSString *mqttLevel1Topic;
    
    //属性变化消息
    NSString *mqttLevel2Topic;
    
    //友好型提醒类消息(暂时不注册)
    NSString *mqttLevel3Topic;
    
    //预留(暂时不注册)
    NSString *mqttLevel4Topic;
    
    //预留(暂时不注册)
    NSString *mqttLevel5Topic;
    
    //用户消息
    NSString *mqttUserTopic;
    
    
    
    //clientId
    NSString *mqttClientId;
    
    //用户名
    NSString *mqttUser;
    
    //密码
    NSString *mqttPwd;
    
    //连接模型
    NetvoxResultModel * connectModel;
    
//    //mqtt连接状态
    MQTTSessionEvent mqttStatus;
    
}
@end

@implementation NetvoxMqtt

//请求模型暂存字典(key为seq,value为模型)
NSMutableDictionary *requestDic;

#pragma mark--初始化
+(NetvoxMqtt *)shareInstance
{
    static NetvoxMqtt *sharedInstace = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        sharedInstace = [[self alloc]init];
        requestDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    });
    
    return sharedInstace;
}


//设置参数
-(void)configWithHost:(NSString *)host port:(UInt32)port houseIeee:(NSString *)houseIeee userName:(NSString *)userName pwd:(NSString *)pwd
{
    mqttHost = host;
    mqttPort = port;
    mqttClientId =[NSString stringWithFormat:@"%@_IOS_%@",houseIeee,userName];
    mqttReqTopic = [NSString stringWithFormat:@"sh/%@/req/%@",houseIeee,userName];
    mqttResTopic = [NSString stringWithFormat:@"sh/%@/res/%@",houseIeee,userName];
    mqttLevel0Topic = [NSString stringWithFormat:@"sh/%@/msg/level0",houseIeee];
     mqttLevel1Topic = [NSString stringWithFormat:@"sh/%@/msg/level1",houseIeee];
     mqttLevel2Topic = [NSString stringWithFormat:@"sh/%@/msg/level2",houseIeee];
     mqttLevel3Topic = [NSString stringWithFormat:@"sh/%@/msg/level3",houseIeee];
     mqttLevel4Topic = [NSString stringWithFormat:@"sh/%@/msg/level4",houseIeee];
     mqttLevel5Topic = [NSString stringWithFormat:@"sh/%@/msg/level5",houseIeee];
    mqttUserTopic = [NSString stringWithFormat:@"sh/%@/msg/%@",houseIeee,userName];
    mqttUser = userName;
    mqttPwd = pwd;
}

#pragma mark--Mqtt 方法
//连接mqtt服务器
-(void)connectCompletionHandler:(void (^)(NSDictionary *validateResult))result
{
    [self disconnect];

    
    if ([mqttHost isEqualToString:@""]) {
        return;
    }
    
    if (mqttUser && mqttPwd && mqttHost) {
        if(mqttSession == nil)
        {
//            mqttSession = [[MQTTSession alloc]initWithClientId:mqttClientId userName:mqttUser password:mqttPwd];
//            [mqttSession setDelegate:self];
            MQTTCFSocketTransport * transport = [[MQTTCFSocketTransport alloc]init];
            transport.host = mqttHost;
            transport.port = mqttPort;
            
            mqttSession = [[MQTTSession alloc]init];
            mqttSession.transport = transport;
            [mqttSession setClientId:mqttClientId];
            [mqttSession setUserName:mqttUser];
            [mqttSession setPassword:mqttPwd];
            [mqttSession setDelegate:self];
            
        }
        
        
        
        if (!connectModel) {
            connectModel = [[NetvoxResultModel alloc]init];
            connectModel.seq= [NetvoxCommon getUuid];
            connectModel.data = [[NSMutableData alloc]initWithCapacity:1];
            NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
            connectModel.requestTime= user.requstTime;
        }
        
    
        connectModel.resultReturn = result;
        connectModel.linkSingle = NO;
        connectModel.cutOffSingle = NO;
        [NSThread detachNewThreadSelector:@selector(mqttRequestTimer:) toTarget:self withObject:connectModel];

        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [mqttSession connectToHost:mqttHost port:mqttPort];
            [mqttSession connectWithConnectHandler:^(NSError *error) {
                NSLog(@"%@", error);
            }];
        });
    }
}



//断开mqtt服务器
-(void)disconnect
{
//    mqttStatus = MQTTSessionEventConnectionClosed;
    if (connectModel && !connectModel.linkSingle) {
        
        [connectModel.timer invalidate];
        connectModel.timer = nil;
    connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-1,@"result":@"mqtt disconnect"});
//        [connectModel.timer invalidate];
//        connectModel.timer = nil;
        connectModel.linkSingle = YES;
    }
    
    if (connectModel) {
        connectModel.cutOffSingle = YES;
    }
    
    [mqttSession disconnect];
//    [mqttSession close];
}
//发送请求(发送消息)
-(void)sendUrl:(NSString *)url param:(NSString *)param seq:(NSString *)seq CompletionHandler:(void (^)(NSDictionary *result))result
{
//    while (mqttStatus == MQTTSessionEventConnecting) {
//         [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
    //掉线重连
    if(mqttStatus != MQTTSessionEventConnected)
    {
//        [mqttSession close];
        [mqttSession disconnect];
        [self connectCompletionHandler:^(NSDictionary *validateResult) {
            int statusCode = [validateResult[@"status_code"] intValue];
            if(statusCode == 88888)
            {
                result(@{@"seq":@"1234",@"status_code":@8888,@"result":@"mqtt reconnect success"});
                return ;
            }
            else
            {
                result(@{@"seq":@"1234",@"status_code":@1,@"result":@"mqtt reconnect failed"});
                return ;
            }
        }];
        return;
    }
    
    NetvoxResultModel * model = [[NetvoxResultModel alloc]init];
    model.seq = seq;
    model.resultReturn = result;
    model.data = [[NSMutableData alloc]initWithCapacity:1];
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    model.requestTime= user.requstTime;
    
    [NSThread detachNewThreadSelector:@selector(mqttRequestTimer:) toTarget:self withObject:model];
    
    NSData *data = [self getUrlDataWithUrl:url param:param];
//    [mqttSession publishData:data onTopic:mqttReqTopic];
    [mqttSession publishData:data onTopic:mqttReqTopic retain:YES qos:1];
}

//上传文件
-(void)upLoadFileWithparam:(NSString *)param seq:(NSString *)seq CompletionHandler:(void (^)(NSDictionary *result))result
{
    if(mqttStatus != MQTTSessionEventConnected)
    {
        result(@{@"seq":@"1234",@"status_code":@1,@"result":@"failed"});
        return ;
    }
    
    NetvoxResultModel * model = [[NetvoxResultModel alloc]init];
    model.seq = seq;
    model.resultReturn = result;
    model.data = [[NSMutableData alloc]initWithCapacity:1];
//    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    model.requestTime= 30;
    [NSThread detachNewThreadSelector:@selector(mqttRequestTimer:) toTarget:self withObject:model];
    NSData * data = [self getUpdataUrlDataWithParam:param];
//    [mqttSession publishData:data onTopic:mqttReqTopic];
    [mqttSession publishData:data onTopic:mqttReqTopic retain:YES qos:1];
}
//订阅主题
-(void)subscribe:(NSString *)topic
{
//    [mqttSession subscribeTopic:topic];
    [mqttSession subscribeToTopic:topic atLevel:0];
}
#pragma mark--数据处理
//发送请求拼装
-(NSData *)getUrlDataWithUrl:(NSString *)url param:(NSString *)param
{
    NSString * urlParam = [NSString stringWithFormat:@"%@%@",url,param];
    NSData * urlParamData = [urlParam dataUsingEncoding:NSUTF8StringEncoding];
    NSData *gzipData = [NetvoxCommon gzipCompress:urlParamData];
    NSString * gzipStrTemp1 = [NSString stringWithFormat:@"%@",gzipData];

    NSString * gzipStrTemp2 = [gzipStrTemp1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * gzipStrTemp3 = [gzipStrTemp2 stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString * gzipStr = [gzipStrTemp3 stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    
    NSString *requstStr = [NSString stringWithFormat:@"{\"data_type\":1,\"data\":\"%@\"}",gzipStr];
    NSData *data = [requstStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

//上传文间请求拼接
-(NSData *)getUpdataUrlDataWithParam:(NSString *)param
{
    NSString * urlParam = [NSString stringWithFormat:@"%@",param];
    NSData * urlParamData = [urlParam dataUsingEncoding:NSUTF8StringEncoding];
    NSData *gzipData = [NetvoxCommon gzipCompress:urlParamData];
    NSString * gzipStrTemp1 = [NSString stringWithFormat:@"%@",gzipData];
    
    NSString * gzipStrTemp2 = [gzipStrTemp1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * gzipStrTemp3 = [gzipStrTemp2 stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString * gzipStr = [gzipStrTemp3 stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    
    NSString *requstStr = [NSString stringWithFormat:@"{\"data_type\":10001,\"data\":\"%@\"}",gzipStr];
    NSData *data = [requstStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

#pragma mark --mqtt delegate
/*
//收到登录状态callback
-(void)session:(MQTTSession *)session handleEvent:(MQTTSessionEvent)eventCode
{
    mqttStatus = eventCode;

    switch (eventCode) {
        case MQTTSessionEventConnected:
        {
            [NetvoxCommon print:@"MQTT connected"];
            
            if (!connectModel.linkSingle) {
             connectModel.linkSingle = YES;
             
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@88888,@"result":@"success"});
                
//                [ connectModel.timer invalidate];
//                connectModel.timer = nil;
                
             
            }
            
            //如果验证通过,将当前连接方式设为socket连接
            NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
            if (user.currentConnectType == currentConnectTypeMqtt) {
                user.currentConnectType = currentConnectTypeMqtt;
            }

            
           


//            [self subscribe:mqttReqTopic];
            [self subscribe:mqttResTopic];
            [self subscribe:mqttLevel0Topic];
            [self subscribe:mqttLevel1Topic];
            [self subscribe:mqttLevel2Topic];
            [self subscribe:mqttUserTopic];
        }
            break;
        case MQTTSessionEventConnectionRefused:
        {
            [NetvoxCommon print:@"MQTT connection refused"];
            if ( !connectModel.linkSingle) {
                 connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"MQTT connection refused"});
                
//                [ connectModel.timer invalidate];
//                connectModel.timer = nil;
                
                
            }
            
          


           
        }
            break;
        case MQTTSessionEventConnectionClosed:
        {
            [NetvoxCommon print:@"MQTT connection closed"];
            if ( !connectModel.linkSingle) {
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                
                 connectModel.linkSingle = YES;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"MQTT connection closed"});
                
//                [ connectModel.timer invalidate];
//                connectModel.timer = nil;
                
                
                
            }
            
           

        }
            break;
        case MQTTSessionEventConnectionError:
        {
            [NetvoxCommon print:@"MQTT connection error"];
            [NetvoxCommon print:@"MQTT recoonnecting..."];
            
            
            if ( !connectModel.linkSingle) {
                
                 connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"MQTT connection error"});
                
//                [ connectModel.timer invalidate];
//                connectModel.timer = nil;
                
                
                
            }
            
       

           
//            NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
//
//            if ( connectModel && !connectModel.cutOffSingle && (user.currentConnectType == currentConnectTypeBoth || user.currentConnectType == currentConnectTypeMqtt)) {
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                
//                [mqttSession connectToHost:mqttHost port:mqttPort];
//                
//            });
//            }
            
        }
            break;
        case MQTTSessionEventProtocolError:
        {
            [NetvoxCommon print:@"protocol error"];
            if ( !connectModel.linkSingle) {
                
                 connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"protocol error"});
                
//                [ connectModel.timer invalidate];
//                connectModel.timer = nil;
                
                
                
            }
            
           

           
        }
            break;
            
        default:
        {
            if ( !connectModel.linkSingle) {
                
                 connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"unknow error"});
                
//                [ connectModel.timer invalidate];
//                connectModel.timer = nil;
                
                
                
            }
            
           


        }
            break;
    }
}



//收到mqtt消息
-(void)session:(MQTTSession *)session newMessage:(NSData *)data onTopic:(NSString *)topic
{
    
    NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
  
    [NetvoxCommon print:[NSString stringWithFormat:@"收到消息,topic 是%@,msg:%@",topic,msg]];
    
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if (dic) {
        NSString *strData = dic[@"data"];
        NSData * gzipDataTemp = [NetvoxCommon convertHexStrToData:strData];
        if(gzipDataTemp )
        {
            
        NSData * gzipData = [NetvoxCommon gzipDecompress:gzipDataTemp];
     
        NSMutableDictionary *dicR = [NSJSONSerialization JSONObjectWithData:gzipData options:NSJSONReadingAllowFragments error:nil];
        //data_type 消息类型
        int data_type = [dic[@"data_type"] intValue];
        
        if (dicR) {
            switch (data_type) {
                case 1000001: 
                {
                    //请求结果
                    NSString *seq = dicR[@"seq"];
                    NetvoxResultModel *model = requestDic[seq];
                    if (model) {
                        
                        [ model.timer invalidate];
                        
                        model.resultReturn(dicR);
                        
//                        [ model.timer invalidate];
                        
                        [requestDic removeObjectForKey:model.seq];
                    }
                }
                    break;
                    
                default:
                    //callback
                {
                    NSNotification *notice=[NSNotification notificationWithName:kMqttReciveCallbackMsgNotification object:nil userInfo:dicR];
                    [[NSNotificationCenter defaultCenter] postNotification:notice];
                }
                    break;
            }
            
        }
        
        
        [NetvoxCommon print:[NSString stringWithFormat:@"%@",dicR]];
    }
    }
    
    
    
}
*/

//收到登录状态callback
//新版本走这里
- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error
{
    mqttStatus = eventCode;
    
    switch (eventCode) {
        case MQTTSessionEventConnected:
        {
            [NetvoxCommon print:@"MQTT connected"];
            
            if (!connectModel.linkSingle) {
                connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@88888,@"result":@"success"});
                
            }
            
            //如果验证通过,将当前连接方式设为socket连接
            NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
            if (user.currentConnectType == currentConnectTypeMqtt) {
                user.currentConnectType = currentConnectTypeMqtt;
            }
            [self subscribe:mqttResTopic];
            [self subscribe:mqttLevel0Topic];
            [self subscribe:mqttLevel1Topic];
            [self subscribe:mqttLevel2Topic];
            [self subscribe:mqttUserTopic];
        }
            break;
        case MQTTSessionEventConnectionRefused:
        {
            [NetvoxCommon print:@"MQTT connection refused"];
            if ( !connectModel.linkSingle) {
                connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"MQTT connection refused"});

            }
        }
            break;
        case MQTTSessionEventConnectionClosed:
        {
            [NetvoxCommon print:@"MQTT connection closed"];
            if ( !connectModel.linkSingle) {
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                
                connectModel.linkSingle = YES;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"MQTT connection closed"});

            }

        }
            break;
        case MQTTSessionEventConnectionError:
        {
            [NetvoxCommon print:@"MQTT connection error"];
            [NetvoxCommon print:@"MQTT recoonnecting..."];
            
            
            if ( !connectModel.linkSingle) {
                
                connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"MQTT connection error"});
                
            }
            
        }
            break;
        case MQTTSessionEventProtocolError:
        {
            [NetvoxCommon print:@"protocol error"];
            if ( !connectModel.linkSingle) {
                
                connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"protocol error"});

            }

        }
            break;
        default:
        {
            if ( !connectModel.linkSingle) {
                
                connectModel.linkSingle = YES;
                
                [ connectModel.timer invalidate];
                connectModel.timer = nil;
                connectModel.resultReturn(@{@"seq":connectModel.seq,@"status_code":@-406,@"result":@"unknow error"});
                
            }

        }
            break;
    }
}
// 接收到消息回调
- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    
    [NetvoxCommon print:[NSString stringWithFormat:@"收到消息,topic 是%@,msg:%@",topic,msg]];
    
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if (dic) {
        NSString *strData = dic[@"data"];
        NSData * gzipDataTemp = [NetvoxCommon convertHexStrToData:strData];
        if(gzipDataTemp )
        {
            
            NSData * gzipData = [NetvoxCommon gzipDecompress:gzipDataTemp];
            
            NSMutableDictionary *dicR = [NSJSONSerialization JSONObjectWithData:gzipData options:NSJSONReadingAllowFragments error:nil];
            //data_type 消息类型
            int data_type = [dic[@"data_type"] intValue];
            
            if (dicR) {
                switch (data_type) {
                    case 1000001:
                    {
                        //请求结果
                        NSString *seq = dicR[@"seq"];
                        NetvoxResultModel *model = requestDic[seq];
                        if (model) {
                            
                            [ model.timer invalidate];
                            
                            model.resultReturn(dicR);
                            
                            //                        [ model.timer invalidate];
                            
                            [requestDic removeObjectForKey:model.seq];
                        }
                    }
                        break;
                        
                    default:
                        //callback
                    {
                        NSNotification *notice=[NSNotification notificationWithName:kMqttReciveCallbackMsgNotification object:nil userInfo:dicR];
                        [[NSNotificationCenter defaultCenter] postNotification:notice];
                    }
                        break;
                }
                
            }
            
            
            [NetvoxCommon print:[NSString stringWithFormat:@"%@",dicR]];
        }
    }
}



#pragma mark--请求定时器

-(void)mqttRequestTimer:(NetvoxResultModel *)resultModel
{
    float delayRequestTime= resultModel.requestTime;
    NSTimer *requestTimer = [NSTimer timerWithTimeInterval:delayRequestTime target:self selector:@selector(mqttRequestTimeout:) userInfo:resultModel repeats:NO];
    
    resultModel.timer = requestTimer;
    
    if (connectModel != resultModel && resultModel != nil) {
        [requestDic setObject:resultModel forKey:resultModel.seq];
    }
    
    
    [[NSRunLoop currentRunLoop] addTimer:requestTimer forMode:NSRunLoopCommonModes];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:delayRequestTime+1]];
}
//xmpp 请求超时
-(void)mqttRequestTimeout:(NSTimer *)timer
{
    
    NetvoxResultModel *resultModel = [timer userInfo];
    
    resultModel.resultReturn(@{@"seq":resultModel.seq,@"status_code":@-404,@"result":@"timeOut"});

    [timer invalidate];
    
    if (resultModel != connectModel) {
        [requestDic removeObjectForKey:resultModel.seq];
    }
    else
    {
        connectModel.linkSingle = YES;
    }
    
    
    
}

@end
