//
//  NetvoxUserInfo.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/23.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_OPTIONS(NSUInteger, connectType) {
    
    connectTypeNone            = 1 << 0,//无网络连接
    connectTypeLocal           = 1 << 1,//内网
    connectTypeWide            = 1 << 2//外网
    
};

//当前连接方式
typedef NS_ENUM(NSInteger,currentConnectType)
{
    currentConnectTypeNone,//无连接
    currentConnectTypeBoth,//2者同时连接
    currentConnectTypeSocket,//socket连接
    currentConnectTypeMqtt,//mqtt连接
};


//网络状态(字典key为status,值为NSNumber类型,1:wifi,1:蜂窝数据,2:无网络)
extern NSString *const kNetworkStatusNotification;
@class RulesModel;
@interface NetvoxUserInfo : NSObject

#define FGGetStringWithKeyFromTable(key, tbl) [[NetvoxUserInfo sharedInstance] getStringForKey:key withTable:tbl]
@property(nonatomic, strong)NSString *changeLanguage;



//用户名
@property (nonatomic,strong)NSString *userName;

//电话号码(一般和用户名一样)
@property (nonatomic,strong)NSString *phone;

//昵称
@property (nonatomic,strong)NSString *nickname;

//头像
@property (nonatomic,strong)NSString *photo;

//密码
@property (nonatomic,strong)NSString *pwd;

//家的名字
@property (nonatomic,strong)NSString *houseName;

//请求时间
@property (nonatomic,assign)float requstTime;

//文件上传时间
@property (nonatomic,assign)float updataRequestTime;

//内网ip
@property (nonatomic,strong)NSString *localip;

//网络连接状态
@property (nonatomic,assign)connectType netConnect;

//萤石摄像头accesstoken存取
@property (nonatomic,strong)NSString *ysAccessToken;

//打印控制
@property (nonatomic,assign)BOOL isPrint;

//云端请求头
@property (nonatomic,readonly)NSString *header;

//网络状态(0:wifi,1:蜂窝数据,2:无网络)
@property (nonatomic,readonly)int networkStatus;


//代理服务器IP
@property (nonatomic,strong) NSString *serverIp;

//代理服务器Port
@property (nonatomic,assign) int serverPort;

//云端服务器IP
@property (nonatomic,strong)NSString *proxyIp;

//云端服务器Port
@property (nonatomic,assign)int proxyPort;

//消息服务器IP
@property (nonatomic,strong)NSString *msgIp;

//消息服务器Port
@property (nonatomic,assign)int msgPort;

//当前houseIeee
@property (nonatomic,strong)NSString *currentHouseIeee;

//账号内的所有家信息
@property (nonatomic,strong)NSArray *houseArr;


//返回字段权限设置(该值设为YES,设备列表等请求会返回一些而外的数据)
@property (nonatomic,assign)BOOL requstBackAuthority;

//消息缓存天数(默认15天)
@property (nonatomic,assign)int msgSaveDays;

//设置内网是否采用socket请求(默认采用http请求,为YES的话采用socket请求)
@property (nonatomic,assign)BOOL isLocalSocketRes;

// 当前连接方式
@property (nonatomic,assign)currentConnectType currentConnectType;

//推送token
@property (nonatomic,strong)NSString *token;

//推送语音
@property (nonatomic,strong)NSString *language;

//是否启用ATS(默认不启用,ATS(在info.plist设置) 开启时,设置此参数为YES,所有的接口才支持ATS)
@property (nonatomic,assign)BOOL isUseATS;

//记录福志达句柄
@property (nonatomic,strong)NSMutableDictionary *mhandleDic;

//是否刚启动
@property (nonatomic,assign)BOOL isNotFirstIn;

@property(nonatomic,strong)RulesModel *  ruleManager;

//记录萤石的AppKey
@property(nonatomic,strong) NSString * ysAppKey;
//记录萤石的AppSecret
@property(nonatomic,strong) NSString * ysAppSecret;
//自动登录标记
@property(nonatomic,assign) BOOL isAutoLogin;
//是否是内网登陆 YES 内网  NO 外网
@property(nonatomic,assign) BOOL isLocalLogin;

//:MARK -- 应用版单独的信息
//账号内应用版所有家的信息
@property(nonatomic,strong) NSArray * applicationHouseArr;
/**
 应用版家的信息,因为应用版和通用版的家数组不太一样多了一层houses的数组,houses数组和通用版的是一样的,和houseArr
 */
@property(nonatomic,strong) NSArray * appHouses;

/**
 应用版有多包了一层.
**/
//模块
/**
 1001     网关地图
 2001     数据汇总
 2002     环境图表
 3001     告警消息
 3002     告警处理
 3003     异常设备
 4001     定位地图
 4002     实时定位
 4003     历史消息
 */
@property(nonatomic,strong) NSArray *  appModules;
//应用的id
@property(nonatomic,copy) NSString *  appid;
//应用的名称
@property(nonatomic,copy) NSString * appName;
//是否是默认应用或者是普通应用 0 默认  1 普通
@property(nonatomic,copy) NSString * appFlag;
//是否有lora单品 0 没有 1 有
@property(nonatomic,assign) NSNumber * appHas_lora;

//是否是应用首页退出是的话登陆后还是显示应用首页
@property(nonatomic,assign) BOOL isAppMain;

//单例
+(NetvoxUserInfo *)shareInstance;

//存储家信息
-(void)remHouseInfo:(NSDictionary *)houseInfoDic;

//切换家
-(BOOL)switchHouseWithHouseIeee:(NSString *)houseIeee;

//读取本地数据
+(void)getLocalData:(NetvoxUserInfo *)obj;

//更新本地数据
+(void)updateLocalData;

//删除个人信息
+(void)deleUserInfo;

//:MARK -- 应用版
/**
 存储应用版APP的家信息
 */
- (void)remApplicationHouse:(NSDictionary *)appHouseDic;
@end
