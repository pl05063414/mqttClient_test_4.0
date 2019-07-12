//
//  NetvoxUserInfo.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/23.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  用户数据放在netvoxUserInfo.plist文件里

#import "NetvoxUserInfo.h"
#import "NetvoxReachability.h"


//用户plist路径
#define userPath [NSString stringWithFormat:@"%@/netvoxUserInfo.plist",[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"]]

//文件夹路径
#define dirSandPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"]


NSString *const kNetworkStatusNotification = @"kNetworkStatusNotification";

@interface NetvoxUserInfo ()

//云端请求头
@property (nonatomic,strong)NSString *header;

//网络状态(0:wifi,1:蜂窝数据,2:无网络)
@property (nonatomic,assign)int networkStatus;

//网络状态
@property (nonatomic,strong)NetvoxReachability *reachR;

//语言库
@property(nonatomic,strong) NSBundle * bundle;

@end

@implementation NetvoxUserInfo

NSMutableDictionary *userDic;//用户数据

//单例
+(NetvoxUserInfo *)shareInstance
{
    static NetvoxUserInfo *obj = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        obj = [[self alloc]init];
        [self getCloudHeader:obj];
        [self getLocalData:obj];
        obj.mhandleDic = [NSMutableDictionary new];
        obj.houseArr = [NSArray array];
        obj.applicationHouseArr = [NSArray new];
        obj.appModules = [NSArray array];
        obj.appHouses = [NSArray array];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
            //        网络状态通知
            [notificationCenter addObserver:obj selector:@selector(reachabilityChanged:) name:kNetvoxReachabilityChangedNotification object:nil];
            
        
            obj.reachR = [NetvoxReachability reachabilityForInternetConnection];
            [obj changeAlongWithReachability:obj.reachR isPost:NO];
            [obj.reachR startNotifier];
        });
       
        
        
    });
    return obj;
}

#pragma mark -- 获取云端请求的头
+(void)getCloudHeader:(NetvoxUserInfo *)userInfo
{
    
    userInfo.header = @"http";
    if (userInfo.isUseATS) {
        NSDictionary *bundleDic =[[NSBundle mainBundle] infoDictionary];
        NSDictionary *ATSDic = [bundleDic objectForKey:@"NSAppTransportSecurity"];
        if (ATSDic) {
            BOOL ATS =[[ATSDic objectForKey:@"NSAllowsArbitraryLoads"] boolValue];
            if (!ATS) {
                userInfo.header = @"https";
            }
        }
    }
    
    }

#pragma mark--家操作
//读取本地数据
+(void)getLocalData:(NetvoxUserInfo *)obj
{
     NSFileManager *manager = [NSFileManager defaultManager];
     userDic = nil;
     obj.userName = @"";
    obj.phone =@"";
    obj.pwd=nil;
    obj.houseName = nil;
    obj.localip = nil;
    obj.serverIp = nil;
    obj.serverPort = 8081;
    obj.proxyIp = nil;
    obj.proxyPort = 80;
    obj.msgIp = nil;
    obj.msgPort = 8081;
    obj.currentHouseIeee = @"";
    obj.houseArr = nil;
    obj.applicationHouseArr = nil;
    obj.nickname = @"";
    obj.phone = @"";
    obj.msgSaveDays = 15;
    obj.token = @"";
    obj.ysAppSecret = @"";
    obj.ysAppKey = @"";
    obj.appid = @"";
    obj.appName = @"";
    obj.appFlag = @"";
    obj.appModules = nil;
    obj.appHas_lora = nil;
    obj.appHouses = nil;
    //如果不存在则创建
    if(![manager fileExistsAtPath:dirSandPath]){
        
        [manager createDirectoryAtPath:dirSandPath withIntermediateDirectories:NO attributes:nil error:nil];
        
    }

    
    if ([manager fileExistsAtPath:userPath]) {
        
        userDic = [NSMutableDictionary dictionaryWithContentsOfFile:userPath];
        obj.userName = [userDic objectForKey:@"userName"];
        obj.nickname = [userDic objectForKey:@"nickname"];
        obj.photo = [userDic objectForKey:@"photo"];
        obj.phone =[userDic objectForKey:@"phone"];
        obj.pwd=[userDic objectForKey:@"pwd"];
        obj.houseName = [userDic objectForKey:@"houseName"];
        obj.localip = [userDic objectForKey:@"localip"];
        obj.serverIp = [userDic objectForKey:@"serverIp"];
        obj.serverPort = [[userDic objectForKey:@"serverPort"] intValue];
        obj.proxyIp = [userDic objectForKey:@"proxyIp"];
        obj.proxyPort = [[userDic objectForKey:@"proxyPort"] intValue];
        obj.msgIp = [userDic objectForKey:@"msgIp"];
        obj.msgPort = [[userDic objectForKey:@"msgPort"] intValue];
        obj.msgSaveDays = [[userDic objectForKey:@"msgSaveDays"] intValue];
        obj.currentHouseIeee = [userDic objectForKey:@"currentHouseIeee"];
        obj.houseArr = [userDic objectForKey:@"houseArr"];
        obj.applicationHouseArr = [userDic objectForKey:@"applicationHouseArr"];
        obj.ysAppSecret = [userDic objectForKey:@"ysAppSecret"];
        obj.ysAppKey = [userDic objectForKey:@"ysAppKey"];
        obj.appFlag = [userDic objectForKey:@"appFlag"];
        obj.appName = [userDic objectForKey:@"appName"];
        obj.appid = [userDic objectForKey:@"appid"];
        obj.appModules = [userDic objectForKey:@"appModules"];
        obj.appHas_lora = [userDic objectForKey:@"appHas_lora"];
        obj.appHouses = [userDic objectForKey:@"appHouses"];
        
    }
    
}
//更新本地数据
+(void)updateLocalData
{
    NSFileManager *manager = [NSFileManager defaultManager];
     if ([manager fileExistsAtPath:userPath]) {
         userDic = [NSMutableDictionary dictionaryWithContentsOfFile:userPath];
     }
    else
    {
        userDic = [[NSMutableDictionary alloc]initWithCapacity:5];

    }
    
    NetvoxUserInfo *obj = [NetvoxUserInfo shareInstance];
    
    //保存到字典
    
    if (obj.userName != nil) {
        [userDic setObject:obj.userName forKey:@"userName"];
    }
    
    if (obj.nickname != nil) {
        [userDic setObject:obj.nickname forKey:@"nickname"];
    }
    
    if (obj.photo != nil) {
        [userDic setObject:obj.photo forKey:@"photo"];
    }
    
    if (obj.phone != nil) {
        [userDic setObject:obj.phone forKey:@"phone"];
    }
    
    if (obj.pwd != nil) {
        [userDic setObject:obj.pwd forKey:@"pwd"];
    }
    
    if (obj.houseName != nil) {
        [userDic setObject:obj.houseName forKey:@"houseName"];
    }
    
    if (obj.localip != nil) {
        [userDic setObject:obj.localip forKey:@"localip"];
    }
    
    if (obj.serverIp != nil) {
        [userDic setObject:obj.serverIp forKey:@"serverIp"];
    }
    
    if (obj.serverPort  != 0) {
        [userDic setObject:[NSNumber numberWithInt:obj.serverPort] forKey:@"serverPort"];
    }
    
    if (obj.proxyIp != nil) {
        [userDic setObject:obj.proxyIp forKey:@"proxyIp"];
    }
    
    if (obj.proxyPort  != 0) {
        [userDic setObject:[NSNumber numberWithInt:obj.proxyPort] forKey:@"proxyPort"];
    }

    if (obj.msgIp != nil) {
        [userDic setObject:obj.msgIp forKey:@"msgIp"];
    }
    
    if (obj.msgPort  != 0) {
        [userDic setObject:[NSNumber numberWithInt:obj.msgPort] forKey:@"msgPort"];
    }
    
    if (obj.msgSaveDays  != 0) {
        [userDic setObject:[NSNumber numberWithInt:obj.msgSaveDays] forKey:@"msgSaveDays"];
    }
    
    if (obj.appHas_lora != nil) {
        [userDic setObject:obj.appHas_lora forKey:@"appHas_lora"];
    }
    
    if (obj.currentHouseIeee != nil) {
        [userDic setObject:obj.currentHouseIeee forKey:@"currentHouseIeee"];
    }
    
    if (obj.houseArr != nil) {
        [userDic setObject:obj.houseArr forKey:@"houseArr"];
    }
    
    if (obj.ysAppKey != nil) {
        [userDic setObject:obj.ysAppKey forKey:@"msgIp"];
    }
    if (obj.ysAppSecret != nil) {
        [userDic setObject:obj.ysAppSecret forKey:@"msgIp"];
    }
    
    if (obj.applicationHouseArr != nil) {
        [userDic setObject:obj.applicationHouseArr forKey:@"applicationHouseArr"];
    }
    if (obj.appModules != nil) {
        [userDic setObject:obj.appModules forKey:@"appModules"];
    }
    if (obj.appFlag != nil) {
        [userDic setObject:obj.appFlag forKey:@"appFlag"];
    }
    if (obj.appName != nil) {
        [userDic setObject:obj.appName forKey:@"appName"];
    }
    if (obj.appid != nil) {
        [userDic setObject:obj.appid forKey:@"appid"];
    }
    if (obj.appHouses != nil) {
        [userDic setObject:obj.appHouses forKey:@"appHouses"];
    }
     [userDic writeToFile:userPath atomically:YES];

    
}
//存储家信息
-(void)remHouseInfo:(NSDictionary *)houseInfoDic
{
    if (houseInfoDic && houseInfoDic[@"result"] && [houseInfoDic[@"result"] isKindOfClass:[NSArray class]]) {
        self.houseArr = houseInfoDic[@"result"];
//        if ([self.currentHouseIeee isEqualToString:@""]) {
//            if (self.houseArr.count !=0) {
//                NSDictionary *houseDic= self.houseArr[0];
//                self.currentHouseIeee = houseDic[@"house_ieee"];
//                
//            }
//        }
        if(self.houseArr.count == 0)
        {
            [NetvoxUserInfo shareInstance].currentHouseIeee = @"";
            [NetvoxUserInfo shareInstance].houseName = @"";
            [NetvoxUserInfo shareInstance].msgIp = @"";
            [NetvoxUserInfo shareInstance].serverIp = @"";
            
        }
//        [self switchHouseWithHouseIeee:self.currentHouseIeee];
        [self switchHouseWithHouseIeee:self.currentHouseIeee];
    }
}

//切换家
-(BOOL)switchHouseWithHouseIeee:(NSString *)houseIeee
{
    BOOL res = NO;
    
    int count = 0;
    for (NSDictionary *dic in self.houseArr) {
        NSString *name = dic[@"name"];
        NSString *house_ieee = dic[@"house_ieee"];
        NSString *cloud_server_ip = dic[@"cloud_server_ip"];
        int cloud_server_port = [dic[@"cloud_server_port"] intValue];
        
        NSString *msg_server_ip = dic[@"msg_server_ip"];
        
        int msg_server_port = [dic[@"msg_server_port"] intValue];
        if(count == 0)
        {
            self.houseName = name;
            self.currentHouseIeee = house_ieee;
            self.serverIp = cloud_server_ip;
            self.serverPort = cloud_server_port;
            self.msgIp = msg_server_ip;
            self.msgPort = msg_server_port;
        }
        if ([houseIeee isEqualToString:house_ieee]) {
            self.houseName = name;
            self.currentHouseIeee = house_ieee;
            self.serverIp = cloud_server_ip;
            self.serverPort = cloud_server_port;
            self.msgIp = msg_server_ip;
            self.msgPort = msg_server_port;
            res = YES;
            break;
        }
        count++;
 
    }
    
    for (NSDictionary *dic in self.applicationHouseArr) {
        
        
        self.appHouses = dic[@"houses"];
        for (NSDictionary * houseDic in self.appHouses) {
            
            NSString *name = houseDic[@"name"];
            NSString *house_ieee = houseDic[@"house_ieee"];
            NSString *cloud_server_ip = houseDic[@"cloud_server_ip"];
            int cloud_server_port = [houseDic[@"cloud_server_port"] intValue];
            
            NSString *msg_server_ip = houseDic[@"msg_server_ip"];
            
            int msg_server_port = [houseDic[@"msg_server_port"] intValue];
            
            if ([houseIeee isEqualToString:house_ieee]) {
                self.houseName = name;
                self.currentHouseIeee = house_ieee;
                self.serverIp = cloud_server_ip;
                self.serverPort = cloud_server_port;
                self.msgIp = msg_server_ip;
                self.msgPort = msg_server_port;
                NSString *appname = dic[@"name"];
                NSArray *modules = dic[@"modules"];
                NSNumber * flag = dic[@"flag"];
                NSNumber * hasLora = dic[@"has_lora"];
                NSNumber * appid = dic[@"appid"];
                self.appName = appname;
                self.appModules = modules;
                self.appFlag = [NSString stringWithFormat:@"%@",flag];
                self.appHas_lora = hasLora;
                self.appid = [NSString stringWithFormat:@"%@",appid];
                self.appHouses = dic[@"houses"];
                res = YES;
                
                break;
            }
            count++;
            
        }
        /*
        if (self.appHouses.count == 0) {
            self.houseName = @"";
            self.currentHouseIeee = @"";
            
            NSString *appname = dic[@"name"];
            NSArray *modules = dic[@"modules"];
            NSNumber * flag = dic[@"flag"];
            NSNumber * hasLora = dic[@"has_lora"];
            NSNumber * appid = dic[@"appid"];
            self.appName = appname;
            self.appModules = modules;
            self.appFlag = [NSString stringWithFormat:@"%@",flag];
            self.appHas_lora = hasLora;
            self.appid = [NSString stringWithFormat:@"%@",appid];
        }*/
        
    }
    
    
    //更新本地数据
    [NetvoxUserInfo updateLocalData];
    
    return res;
}

//存储应用版APP的家信息
- (void)remApplicationHouse:(NSDictionary *)appHouseDic
{
    if (appHouseDic && appHouseDic[@"result"] && [appHouseDic[@"result"] isKindOfClass:[NSArray class]]) {
        self.applicationHouseArr = appHouseDic[@"result"];
        //        if ([self.currentHouseIeee isEqualToString:@""]) {
        //            if (self.houseArr.count !=0) {
        //                NSDictionary *houseDic= self.houseArr[0];
        //                self.currentHouseIeee = houseDic[@"house_ieee"];
        //
        //            }
        //        }
        if(self.applicationHouseArr.count == 0)
        {
            [NetvoxUserInfo shareInstance].currentHouseIeee = @"";
            [NetvoxUserInfo shareInstance].houseName = @"";
            [NetvoxUserInfo shareInstance].msgIp = @"";
            [NetvoxUserInfo shareInstance].serverIp = @"";
            
        }
        [self switchHouseWithHouseIeee:self.currentHouseIeee];
    }
}


#pragma mark-- 网络状态监听
//网络状态变化
-(void)reachabilityChanged:(NSNotification *)noti
{
    
    
    NetvoxReachability *reach = [noti object];
    
    //    NSParameterAssert([reach isKindOfClass:[Reachability class]]);
    if ([reach isKindOfClass:[NetvoxReachability class]]) {
        [self changeAlongWithReachability:reach isPost:YES];
    }
    
    
}

//网络判断
-(void)changeAlongWithReachability:(NetvoxReachability *)reach isPost:(BOOL)isPost
{
    NetvoxNetworkStatus sta = [reach currentReachabilityStatus];
    switch (sta) {
        case ReachableViaWiFi:
            //wifi
            self.networkStatus = 0;
            if (self.isLocalLogin) {
                self.currentConnectType = currentConnectTypeSocket;
            }else{
                self.currentConnectType = currentConnectTypeMqtt;
            }
            
           
            break;
        case ReachableViaWWAN:
            //蜂窝数据
            self.netConnect = connectTypeWide;
            self.networkStatus = 1;
            self.currentConnectType = currentConnectTypeMqtt;
            
            break;
            
        default:
            //无网络
            self.networkStatus = 2;
            self.netConnect = connectTypeNone;
            self.currentConnectType = currentConnectTypeNone;
            break;
    }
    
    //发送通知
    if (isPost) {
        NSNotification *notice=[NSNotification notificationWithName:kNetworkStatusNotification object:nil userInfo:@{@"status":[NSNumber numberWithInt:self.networkStatus]}];
        [[NSNotificationCenter defaultCenter] postNotification:notice];
    }
   
}
//删除个人信息
+(void)deleUserInfo
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:userPath])
    {
        [manager removeItemAtPath:userPath error:nil];
    }
    if ([manager fileExistsAtPath: dirSandPath]) {
        [manager removeItemAtPath:dirSandPath error:nil];
    }
    [NetvoxUserInfo getLocalData:[NetvoxUserInfo shareInstance]];
}



@end
