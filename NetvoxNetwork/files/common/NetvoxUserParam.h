//
//  NetvoxUserParam.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/6/30.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  用户初始化模型

#import <Foundation/Foundation.h>

@interface NetvoxUserParam : NSObject

//用户名
@property (nonatomic,strong)NSString *user;

//密码
@property (nonatomic,strong)NSString *pwd;

//内网ip
@property (nonatomic,strong)NSString *localIp;

//推送token(用户不允许的话,可以不设)
@property (nonatomic,strong)NSString *token;

//推送语音设置(如果推送token未设置,该参数无效,默认推送语音为英文)
@property (nonatomic,strong)NSString *language;

//设置日志打印(默认为NO,不打印日志)
@property (nonatomic,assign)BOOL isPrint;

//额外返回权限(默认为NO;设为YES的话,设备详情列表等返回会返回额外的字段)
@property (nonatomic,assign)BOOL  isGetBackAuthority;

//设置请求超时时间(默认为15s)
@property (nonatomic,assign)float requestTime;

@property (nonatomic,assign)float updataRequestTime;

//内网请求是否为socket连接方式(默认为NO,http连接方式;YES为socket连接方式)
@property (nonatomic,assign)BOOL isLocalConnectSocket;

//是否启用ATS(默认不启用,ATS(在info.plist设置) 开启时,设置此参数为YES,所有的接口才支持ATS)
@property (nonatomic,assign)BOOL isUseATS;



@end
