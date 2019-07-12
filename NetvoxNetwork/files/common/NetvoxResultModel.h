//
//  NetvoxResultModel.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/23.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  结果模型

#import <Foundation/Foundation.h>
#import "NetvoxGCDAsyncSocket.h"


@interface NetvoxResultModel : NSObject

typedef void (^ requstBlock)(NSDictionary *result);

//计时器
@property (nonatomic,strong)NSTimer * timer;

//请求时间
@property (nonatomic,assign)float requestTime;

//seq
@property (nonatomic,strong)NSString *seq;

//socket
@property (nonatomic,strong)NetvoxGCDAsyncSocket *socket;

//代码块
@property (nonatomic,copy)requstBlock resultReturn;

//存储callback data
@property (nonatomic,strong)NSMutableData *data;

//semaphore
@property (nonatomic,retain)dispatch_semaphore_t semaphore;

//请求url
@property (nonatomic,strong)NSString *url;

//请求type
@property (nonatomic,assign)int type;

//callback 验证手动断开标记
@property (nonatomic,assign)BOOL cutOffSingle;

//连接返回标记
@property (nonatomic,assign)BOOL linkSingle;

@end
