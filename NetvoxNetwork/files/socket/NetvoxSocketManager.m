//
//  SocketManager.m
//  NetvoxNetTest
//
//  Created by netvox-ios6 on 16/4/20.
//  Copyright © 2016年 netvox-ios6. All rights reserved.
//  注:心跳时间最大25秒

#import "NetvoxSocketManager.h"
#import "NetvoxCommon.h"
#import "NetvoxResultModel.h"
#import "NetvoxUserInfo.h"


NSString *const kSocketReciveCallbackMsgNotification = @"kSocketReciveCallbackMsgNotification";

//心跳时间
#define HeartCountTime 20

@implementation NetvoxSocketManager
{
    NetvoxGCDAsyncSocket *requstSocket[500];//请求socket,暂时开500个用于循环使用,数据发出后立即释放
    int requestCount; //请求计数
    
   
    
   
}



#pragma mark--初始化
+(NetvoxSocketManager *)shareInstance
{
    static NetvoxSocketManager *sharedInstace = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        sharedInstace = [[self alloc]init];

        
    });
    
    return sharedInstace;
}

#pragma mark--callback
//设置socket 连接host
-(void)setSocketHost:(NSString *)host
{
    _socketHost=host;
}
//socket连接到服务器
-(void)socketConnectCallbackSocketCompletionHandler:(void (^)(NSDictionary *result))result
{
//    [self cutOffSocket];
    
    if (self.callbackSocket==nil) {
        self.callbackSocket=[[NetvoxGCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    NSError *error=nil;
//    self.socketHost=host;
    self.socketPort=5002;
    [self.callbackSocket connectToHost:self.socketHost onPort:self.socketPort withTimeout:10.0 error:&error];
    [self.connectTimer invalidate];
    self.connectTimer = nil;
    //socket 心跳包计时器，主线程上
    self.connectTimer = [NSTimer timerWithTimeInterval:HeartCountTime target:self selector:@selector(sendHeartBeat:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.connectTimer forMode:NSRunLoopCommonModes];
//    [self.connectTimer setFireDate:[NSDate distantFuture]];//定时器暂且停止
    
    
    
    NetvoxResultModel * model;
    
    if (self.callbackSocket.userData) {
        model = self.callbackSocket.userData;
        model.resultReturn = result;
    }
    else
    {
        model = [[NetvoxResultModel alloc]init];
        model.resultReturn = result;
        model.seq = @"1234";
        model.data = [[NSMutableData alloc]initWithCapacity:1];
        NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
        model.requestTime= user.requstTime;
        
        self.callbackSocket.userData = model;
        model.socket = self.callbackSocket;
    }
    
    model.linkSingle = NO;
    
    model.cutOffSingle = NO;
    //新线程创建请求计时器
    [NSThread detachNewThreadSelector:@selector(requestTimer:) toTarget:self withObject:model];

    
    
    
}

//socket断开连接
-(void)cutOffSocket
{
//    [NetvoxUserInfo shareInstance].cutOffType=SocketOfflineByUser ;
    [self.connectTimer invalidate];
    self.connectTimer = nil;
    
    NetvoxResultModel *model = self.callbackSocket.userData;
    if (model && !model.linkSingle) {
     model.resultReturn(@{@"seq":model.seq,@"status_code":@-405,@"result":@"socket disconnect"});
        [model.timer invalidate];
        model.timer = nil;
        model.linkSingle = YES;
    }
    
    if (model) {
        model.cutOffSingle = YES;
    }

    [self.callbackSocket disconnect];
    
}
//发送心跳
-(void)sendHeartBeat:(NSTimer *)timer
{

     [NetvoxCommon print:@"socket发送心跳"];
    NSData *aData = [NetvoxCommon dicToJsonData:@{@"id":[NetvoxCommon getMs],@"type":@0000000}];
    [self.callbackSocket writeData:aData withTimeout:-1 tag:1];
    [self.callbackSocket readDataWithTimeout:-1 tag:0];
}

#pragma mark--请求部分
//请求socket连接
-(NetvoxGCDAsyncSocket *)requstSocketConnect
{
    
    int currentCount=requestCount;
    requestCount++;
    if (requestCount==500) {
        requestCount=0;
    }
    
 
    
    if (requstSocket[currentCount]==nil) {
        requstSocket[currentCount]=[[NetvoxGCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    
    if (!requstSocket[currentCount].isConnected) {
        NSError *error=nil;
        //         isConnect5001=0;
        [requstSocket[currentCount] connectToHost:self.socketHost onPort:5001 withTimeout:10.0 error:&error];
        
       
        [NetvoxCommon print:(@"socket请求准备连接")];
    }
    
    return requstSocket[currentCount];
    
}

//cgi请求
-(void)requstWithCGI:(NSString *)requstCGI seq:(NSString *)seq type:(int)type CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxGCDAsyncSocket *currentSocket = [self requstSocketConnect];
    
    NetvoxResultModel * model = [[NetvoxResultModel alloc]init];
    model.seq = seq;
    model.resultReturn = result;
    model.data = [[NSMutableData alloc]initWithCapacity:1];
    model.semaphore = dispatch_semaphore_create(1);
    currentSocket.userData = model;
    model.socket = currentSocket;
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    model.requestTime= user.requstTime;
    
    
    
    //加上ip
    NSString *lastCGI = [NSString stringWithFormat:@"%@&ip=%@",requstCGI,self.socketHost];
    model.url = lastCGI;
    model.type = type;

    
    [NSThread detachNewThreadSelector:@selector(requestTimer:) toTarget:self withObject:model];

    
    
}


//发送数据构造
-(NSMutableData *)sendSocketWith:(int)type requstCGI:(NSString *)requstCGI
{
    NSMutableString *mutStr=[[NSMutableString alloc]initWithCapacity:1];
    [mutStr appendString:@"\n"];
    [mutStr appendString:@"\n"];
    
    NSData *dataSeperate=[mutStr dataUsingEncoding:NSUTF8StringEncoding];
    
    
    int rep_len = 0;
//    rep_len = sizeof(int);
    
    
    rep_len+=requstCGI.length;
    
    //分隔符
    NSMutableData *mutDataRequest=[[NSMutableData alloc]initWithCapacity:1];
    [mutDataRequest appendData:dataSeperate];
    
    //长度
    NSMutableString *comLenStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%d",rep_len]];
    while (comLenStr.length!=16) {
        [comLenStr appendString:@"\0"];
    }

    NSData *dataLen = [comLenStr dataUsingEncoding:NSUTF8StringEncoding];
    

    
    [mutDataRequest appendData:dataLen];
    
    //请求类型
    NSMutableString *comTypeStr = [NSMutableString stringWithString:[NSString stringWithFormat:@"%d",type]];
    while (comTypeStr.length!=16) {
        [comTypeStr appendString:@"\0"];
    }

    NSData *dataType = [comTypeStr dataUsingEncoding:NSUTF8StringEncoding];
    

    
    [mutDataRequest appendData:dataType];
    
    //参数
    NSData *requstData = [requstCGI dataUsingEncoding:NSUTF8StringEncoding];
    [mutDataRequest appendData:requstData];
    
    //crc16 校验
    int16_t checksum= [NetvoxCommon crc16With:mutDataRequest];
    int16_t swapped=CFSwapInt16(checksum);
    char *a=(char *)&swapped;
    NSMutableData *dataCRC=[[NSMutableData alloc]initWithData:mutDataRequest];
    [dataCRC appendBytes:a length:sizeof(unsigned short)];


    
    return dataCRC;

}

//粘包处理
-(void)dealWithNianBaoData:(NSData *)data socket:(NetvoxGCDAsyncSocket *)currentSocket
{
    
    //去除多余部分
    NSData *dataLen=[data subdataWithRange:NSMakeRange(2, 16)];
    NSString *lenStr=  [[NSString alloc] initWithData:dataLen encoding:NSUTF8StringEncoding];

    NSRange range=NSMakeRange(34, data.length-36);
    NSData *data2=[data subdataWithRange:range];
    
    NSString *responseString = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
    if (responseString && data.length==([lenStr intValue]+2+16*2+2) ) {
       
         [self returnResultWithData:data2 socket:currentSocket];
    }
    
    
}

-(void)returnResultWithData:(NSData *)data socket:(NetvoxGCDAsyncSocket *)currentSocket
{
    

    //将data转换成dic
    //去除制表符,防止概率性解析失败
//    NSString *responseString = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
//    responseString = [responseString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
//    responseString = [responseString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    responseString = [responseString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//    NSData *dData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];

    
//    if (error) {
//        NSLog(@"解析错误原因:%@",error);
//    }
    
   
    
    NetvoxResultModel *resultModel = currentSocket.userData;
    if (resultModel) {
        if (dic) {
            resultModel.resultReturn(dic);
            [resultModel.timer invalidate];
            
        }
        else
        {
            resultModel.resultReturn(@{@"seq":@"1234",@"status_code":@-410,@"result":@"Data parsing failed"});
            [resultModel.timer invalidate];
            
        }

        currentSocket.userData = nil;
    }
    
    //返回
    [currentSocket disconnect];
    

}



#pragma mark--GCDAsyncSocketDelegate
//连接成功
-(void)socket:(NetvoxGCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    
    
    if (sock == self.callbackSocket) {
       
        [NetvoxCommon print:(@"callbackSocket连接成功")];
        //callback
        //验证
        NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
        
        NSData *aData = [NetvoxCommon dicToJsonData:@{@"id":[NetvoxCommon getMs],@"type":@1000001,@"user":user.userName,@"token":[NetvoxCommon md5:user.pwd]}];
        [self.callbackSocket writeData:aData withTimeout:-1 tag:1];
        [self.callbackSocket readDataWithTimeout:-1 tag:0];

    }
    else
    {
        
        [NetvoxCommon print:(@"请求socket连接成功")];
        
        //发送数据
        NetvoxResultModel *model = sock.userData;
        [sock writeData:[self sendSocketWith:model.type requstCGI:model.url] withTimeout:10.0 tag:2];
        
        [sock readDataWithTimeout:-1 tag:2];
    }
    
    
   
}


//断开连接(在此可以做自动重连动作)
-(void)socketDidDisconnect:(NetvoxGCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock == self.callbackSocket) {
        
        NetvoxResultModel *resultModel = sock.userData;
        if (resultModel && !resultModel.linkSingle) {
            
            resultModel.linkSingle = YES;
        resultModel.resultReturn(@{@"seq":resultModel.seq,@"status_code":@-405,@"result":@"socket disconnect"});
            [resultModel.timer invalidate];
            
        }

        
        
        [NetvoxCommon print:[NSString stringWithFormat:@"callbacksocket断开连接,原因为:%@",err]];
        
        NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
//        //网络重连
        if ( resultModel && !resultModel.cutOffSingle && (user.currentConnectType == currentConnectTypeSocket)) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self socketConnectCallbackSocketCompletionHandler:^(NSDictionary *validateResult) {
                    
                }];
            });
        }
    }
    else
    {
//        NSString *socketAddr = [NSString stringWithFormat:@"%p",sock];
        
        NetvoxResultModel *resultModel = sock.userData;
        if (resultModel) {
            resultModel.resultReturn(@{@"seq":resultModel.seq,@"status_code":@-405,@"result":@"socket disconnect"});
            [resultModel.timer invalidate];
            sock.userData = nil;
        }
        
        [NetvoxCommon print:[NSString stringWithFormat:@"socket断开连接,原因为:%@",err]];

    }
   
    
}

-(void)socket:(NetvoxGCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    if (tag==0) {
        
//        NSLog(@"uploadsocket2+++++%p....%d",sock,sock.isConnected);
    }
    else if (tag==2)
    {
        
         [NetvoxCommon print:@"请求socket发送数据..."];
        
    }
    
}
//收到数据
-(void)socket:(NetvoxGCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
        if (sock == self.callbackSocket)
        {
            NSString *sStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

            [self.callbackSocket readDataWithTimeout:-1 tag:0];
       

            [NetvoxCommon print:[NSString stringWithFormat:@"callbackSocket收到数据：%@",sStr]];
        
            //将返回的数据转化成字典
            NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
            //验证成功则发送心跳 type = 1 心跳包， = 0不知道，=else callback
            if (dicData) {
                if ( [[dicData objectForKey:@"type"] intValue]==1  ) {
                    
                    if ([[dicData objectForKey:@"result"] isEqualToString:@"success"]) {
                        //如果验证通过,将当前连接方式设为socket连接
                        NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
                        if (user.currentConnectType == currentConnectTypeSocket) {
                            user.currentConnectType = currentConnectTypeSocket;
                        }

                        [self.connectTimer fire];
                    }
                    else
                    {
                        
                    }
                    
                    
                    NetvoxResultModel *resultModel = sock.userData;
                    if (resultModel && !resultModel.linkSingle) {
                        resultModel.linkSingle = YES;
                        resultModel.resultReturn(dicData);
                        [resultModel.timer invalidate];
                        
                    }

                   
                }
                else if ([[dicData objectForKey:@"type"] intValue]==0 )
                {
                    //心跳callback不用通知传出
                }
                else
                {
                    //callback
                    NSNotification *notice=[NSNotification notificationWithName:kSocketReciveCallbackMsgNotification object:nil userInfo:dicData];
                    [[NSNotificationCenter defaultCenter] postNotification:notice];
                    
                }

            }
            

    }
    else
    {
        
       
        [sock readDataWithTimeout:-1 tag:0];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NetvoxResultModel *model = (NetvoxResultModel *)sock.userData;
            if (model) {
                dispatch_semaphore_wait(model.semaphore, DISPATCH_TIME_FOREVER);
                //        NSMutableData *mutData = (NSMutableData *)sock.userData;
                [model.data appendData:data];
                sock.userData = model;
                [self dealWithNianBaoData:model.data  socket:sock];
                dispatch_semaphore_signal(model.semaphore);
            }
       

        });
        
        
    }
    
   
    
   }




#pragma mark--请求定时器

-(void)requestTimer:(NetvoxResultModel *)resultModel
{
 
    float delayRequestTime= resultModel.requestTime;
    NSTimer *requestTimer = [NSTimer timerWithTimeInterval:delayRequestTime target:self selector:@selector(requestTimeout:) userInfo:resultModel repeats:NO];
    
    resultModel.timer = requestTimer;
    
//    [ResultDic setObject:resultModel forKey:resultModel.socketAddr];
    //在新线程创一个runloop 循环并添加计时器
    [[NSRunLoop currentRunLoop] addTimer:requestTimer forMode:NSRunLoopCommonModes];
    //整个runloop停止条件，runloop停止，会退出当前线程
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:delayRequestTime+1]];
}
//xmpp 请求超时
-(void)requestTimeout:(NSTimer *)timer
{

    NetvoxResultModel *resultModel = [timer userInfo];
    if (resultModel.socket  == self.callbackSocket) {
        resultModel.linkSingle = YES;
    }
    else
    {
        resultModel.socket.userData = nil;
    }

    resultModel.resultReturn(@{@"seq":resultModel.seq,@"status_code":@-404,@"result":@"timeOut"});
    
    
    [timer invalidate];
    
    
}



@end
