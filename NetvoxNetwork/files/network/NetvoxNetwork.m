//
//  NetvoxNetwork.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/22.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  注:写请求的时候,参数请按字母顺序排序,以便于加密

#import "NetvoxNetwork.h"
#import "NetvoxCommon.h"
#import "NetvoxSocketManager.h"
#import "NetvoxUserInfo.h"
#import "NetvoxCallback.h"
#import "NetvoxHttpNetwork.h"
#import "NetvoxDb.h"
#import "NetvoxMqtt.h"
#import "NetvoxNetworkModel.h"


//沙盒路径
#define NtxSandPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"]
#define houseAndUserName @"214976189@qq.com"
#define overseasName @"rd158@netvox.com.cn"
@implementation NetvoxNetwork

#pragma mark--SDK 设置

//设置调试打印(默认不打印)
+(void)setPrint:(BOOL)isPrint
{
    [NetvoxUserInfo shareInstance].isPrint = isPrint;
}
#pragma mark-- 本地存储数据获取
//获取摄像头本地缓存的accessToken(需要做过获取摄像头accessToken的请求)
+(NSString *)getYSAccessToken
{
    return [NetvoxUserInfo shareInstance].ysAccessToken;
}
//删除文件夹多余的文件
+(void)deleteMoreFiles
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:NtxSandPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *fileName in enumerator) {
        if ([fileName isEqualToString:@"netvoxUserInfo.plist"]) {
            
        }
    }
}

//返回文件夹路径
+(NSString *)getDirectoryPath
{
    return NtxSandPath;
}
#pragma mark--参数设置
//初始化
+(void)initWithUserParam:(NetvoxUserParam *)param CompletionHandler:(void (^)(NSDictionary *result))result
{
    //参数判断
    if (!param.user) {
        result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"please set userName"});
        
        return;
    }
    
    if (!param.pwd) {
        result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"please set pwd"});
        
        return;
    }
    
    if (!param.localIp) {
        result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"please set localIp"});
        
        return;
    }
    
    if (!param.token) {
        param.token = @"";//推送的token没设的话,赋予空字符串
    }

    
    if (!param.language) {
        param.language = @"en";//默认推送语音为英文
    }

    
    if (param.requestTime<=0) {
        
        param.requestTime = 15.0;//默认请求15s
        
    }
    
    if(param.updataRequestTime<=0)
    {
        param.updataRequestTime = 30;
    }

    
    //用户参数
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    user.userName = param.user;
    user.pwd = param.pwd;
    user.requstTime = param.requestTime;
    user.updataRequestTime = param.updataRequestTime;
    user.localip = param.localIp;
    user.language=param.language;
    user.token = param.token;
    user.isPrint = param.isPrint;
    user.isLocalSocketRes = param.isLocalConnectSocket;
    user.requstBackAuthority = param.isGetBackAuthority;
    user.isUseATS = param.isUseATS;
    
    user.netConnect = connectTypeLocal;//暂时写内网
    
    //callback
    [NetvoxCallback shareInstance];
    
    //设置socket 连接ip
    [[NetvoxSocketManager shareInstance] setSocketHost:param.localIp];
    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        //获取用户信息
//        [NetvoxNetwork getUserInfoCompletionHandler:^(NSDictionary *result) {
//            if ([result[@"status_code"] intValue] == 0) {
//                [NetvoxDb shareInstance];
//            }
//        }];
//    });
    
    result(@{@"seq":@"1234",@"status_code":@0,@"result":@"success"});
}

// 连接到家（只有外网可用，内网无效，外网做设备控制，获取设备列表前需要调用该接口，调用登陆接口默认连接第一个家）
+(void)connectToHouse:(NSString *)houseIeee CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    if (user.netConnect == connectTypeWide) {
        //外网的时候可以切换家
        BOOL res = [user switchHouseWithHouseIeee:houseIeee];
        if (res) {
            [NetvoxNetwork connectMqttCompletionHandler:result];
        }
        else
        {
            result(@{@"seq":@"1234",@"status_code":@1,@"result":@"switch failed"});

        }
    }
    else
    {
        result(@{@"seq":@"1234",@"status_code":@1,@"result":@"failed:is not wide net"});
    }
}

//连接mqtt
+(void)connectMqttCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxMqtt  *mqtt = [NetvoxMqtt shareInstance];
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    [mqtt disconnect];
    [mqtt configWithHost:user.msgIp port:user.msgPort houseIeee:user.currentHouseIeee userName:user.userName pwd:user.pwd];
    [mqtt connectCompletionHandler:^(NSDictionary *validateResult) {
        [NetvoxCommon print:[NSString stringWithFormat:@"mqtt 连接结果:%@",validateResult]];
        result(validateResult);
        
    }];

    
}

//设置请求超时时间(默认为15s)
+(void)setRequstTime:(float)time
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    user.requstTime = time;
}

//返回字段权限设置(该值设为YES,设备列表等请求会返回一些而外的数据)
+(void)setRequstBackAuthority:(BOOL)authority
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    user.requstBackAuthority = authority;
}

//获取时间戳(精确到毫秒)
+(NSString *)getTimestamp
{
    return [NetvoxCommon getMs];
}

//设置内网请求方式(默认采用http请求,为YES的话采用http请求,为NO的话采用socket请求)
+(void)setLocalRequstType:(BOOL)isUseHttp
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    user.isLocalSocketRes = !isUseHttp;
}

////清除缓存
//+(NSString*)getCacheSize
//{
//    
//    NSDate* begin = [NSDate date];
//    
//    
//    NSFileManager* fm = [NSFileManager defaultManager];
//    __block NSError* error = nil;
//    
//    __block NSUInteger fileSize = 0;
//    
//    dispatch_queue_t queue =dispatch_get_global_queue(0, 0);
//    
//    //获取Books的缓存
//    dispatch_sync(queue, ^{
//        NSArray* subFiles = [fm subpathsAtPath:BOOKHEADERPath([LoginPlugin share].userID)];
//        NSLog(@"subpath = %@",subFiles);
//        for (NSString* fileName in subFiles) {
//            if ([fileName hasSuffix:@"png"]||[fileName hasSuffix:@"jpg"]) {
//                NSDictionary* dic = [fm attributesOfItemAtPath:BOOKPATH([LoginPlugin share].userID,fileName) error:&error];
//                NSUInteger size = (error ? 0:[dic fileSize]);
//                fileSize += size;
//            }
//        }
//    });
//    
//    
//    NSString* cacheString = [NSString stringWithFormat:@"%.1fM",fileSize/(1024.0*1024)];
//    NSTimeInterval time = [begin timeIntervalSinceNow];
//    NSLog(@"便利文件耗费时间:%lf",time/60.0);
//    return cacheString;
//}

////获取告警缓存
//+(NSString*)getMsgCacheSize
//{
//    NSFileManager* fm = [NSFileManager defaultManager];
//    __block NSError* error = nil;
//    
//    __block NSUInteger fileSize = 0;
//    
//    NSString *sandPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSString *dbName = [NSString stringWithFormat:@"%@.sqlite",[NetvoxUserInfo shareInstance].phone];
//    NSString *fileName=[sandPath stringByAppendingPathComponent:dbName];
//    
//    NSDictionary* dic = [fm attributesOfItemAtPath:fileName error:&error];
//    NSUInteger size = (NSUInteger)(error ? 0:[dic fileSize]);
//    fileSize += size;
//    
//    NSString* cacheString = [NSString stringWithFormat:@"%.1fM",fileSize/(1024.0*1024)];
//    
//     return cacheString;
//}
////清除告警缓存(传0则表示立即删除)
//+(BOOL)clearMsgCacheWithDays:(int)days
//{
//    BOOL res = NO;
//    
//    
//    return res;
//}
#pragma mark--数据库处理方法
//获取本地设备列表
+(NSDictionary *)getLocalDeviceList:(NSString *)roomid devicetype:(NSString *)devicetype pagenum:(int)pagenum pagesize:(int)pagesize seq:(NSString *)seq
{
    NSMutableArray *requestArr =[[NSMutableArray alloc]initWithCapacity:1];
    NSMutableArray *addArr =[[NSMutableArray alloc] initWithCapacity:1];
    [addArr addObject:@{@"key":@"house_ieee",@"value":[NetvoxUserInfo shareInstance].currentHouseIeee,@"op":@"="}];
    if ([roomid intValue] != -1) {
        
        [addArr addObject:@{@"key":@"roomid",@"value":roomid,@"op":@"="}];
    }
    
    if (devicetype && ![devicetype isEqualToString:@""]) {
        
         [addArr addObject:@{@"key":@"devicetype",@"value":devicetype,@"op":@"="}];
    }
    
    //默认按升序取出
    NSDictionary *orderDic = @{@"key":@"uid",@"op":@"asc"};
    
    NSDictionary *limitDic = @{@"index":[NSString stringWithFormat:@"%d",pagenum],@"size":[NSString stringWithFormat:@"%d",pagesize]};
    
    NSArray *queryArr =[NetvoxDb query:TABLE_DEVICE addArr:addArr orArr:nil orderDic:orderDic limitDic:limitDic];
    for (NSDictionary *queryDic in queryArr) {
        NSString *uid =queryDic[@"uid"];
        NSString *name =queryDic[@"name"];
        NSString *devicetype =queryDic[@"devicetype"];
        NSString *udeviceid =queryDic[@"udeviceid"];
        NSString *roomid =queryDic[@"roomid"];
        NSString *status =queryDic[@"status"];
        NSString *pic =queryDic[@"pic"];
        NSString *fre = queryDic[@"fre"];
        
        NSDictionary *requstDic =@{@"id":uid,@"name":name,@"devicetype":devicetype,@"udeviceid":udeviceid,@"roomid":roomid,@"status":status,@"pic":pic};
        if ([NetvoxUserInfo shareInstance].requstBackAuthority) {
            requstDic =@{@"id":uid,@"name":name,@"devicetype":devicetype,@"udeviceid":udeviceid,@"roomid":roomid,@"status":status,@"pic":pic,@"fre":fre};
        }
        
        
        [requestArr addObject:requstDic];
    }
    
    return @{@"seq":seq,@"status_code":@0,@"result":requestArr};
}
//获取本地设备列表详情
+(NSDictionary *)getLocalDeviceListDetail:(NSString *)roomid devicetype:(NSString *)devicetype dev_ids:(NSArray *)dev_ids pagenum:(int)pagenum pagesize:(int)pagesize seq:(NSString *)seq
{
    NSMutableArray *requestArr =[[NSMutableArray alloc]initWithCapacity:1];
    NSMutableArray *addArr =[[NSMutableArray alloc] initWithCapacity:1];
    [addArr addObject:@{@"key":@"house_ieee",@"value":[NetvoxUserInfo shareInstance].currentHouseIeee,@"op":@"="}];
    if ([roomid intValue] != -1) {
        
        [addArr addObject:@{@"key":@"roomid",@"value":roomid,@"op":@"="}];
    }
    
    if (devicetype && ![devicetype isEqualToString:@""]) {
        
        [addArr addObject:@{@"key":@"devicetype",@"value":devicetype,@"op":@"="}];
    }
    
    //或条件
    NSMutableArray *orArr;
    if (dev_ids.count ==1 && [dev_ids[0] intValue]!=-1 ){
        if (!orArr) {
            orArr =[[NSMutableArray alloc] initWithCapacity:1];
        }
        for (NSString *uid in dev_ids) {
            [orArr addObject:@{@"key":@"uid",@"value":uid,@"op":@"="}];
        }
    }

    
    //默认按升序取出
    NSDictionary *orderDic = @{@"key":@"uid",@"op":@"asc"};
    
    NSDictionary *limitDic = @{@"index":[NSString stringWithFormat:@"%d",pagenum],@"size":[NSString stringWithFormat:@"%d",pagesize]};
    
    NSArray *queryArr =[NetvoxDb query:TABLE_DEVICE addArr:addArr orArr:orArr orderDic:orderDic limitDic:limitDic];
    for (NSDictionary *queryDic in queryArr) {
        NSString *uid =queryDic[@"uid"];
        NSString *name =queryDic[@"name"];
        NSString *devicetype =queryDic[@"devicetype"];
        NSString *udeviceid =queryDic[@"udeviceid"];
        NSString *roomid =queryDic[@"roomid"];
        NSString *status =queryDic[@"status"];
        NSString *pic =queryDic[@"pic"];
        NSString *fre = queryDic[@"fre"];
        
        
        
        NSDictionary *requstDic =@{@"id":uid,@"name":name,@"devicetype":devicetype,@"udeviceid":udeviceid,@"roomid":roomid,@"status":status,@"pic":pic,@"details":[NetvoxNetwork getDetails:queryDic]};
        
        if ([NetvoxUserInfo shareInstance].requstBackAuthority) {
            requstDic =@{@"id":uid,@"name":name,@"devicetype":devicetype,@"udeviceid":udeviceid,@"roomid":roomid,@"status":status,@"pic":pic,@"fre":fre,@"details":[NetvoxNetwork getDetails:queryDic]};
        }
        
        [requestArr addObject:requstDic];
    }
    
    return @{@"seq":seq,@"status_code":@0,@"result":requestArr};
}

//设备详情details 获取
+(NSDictionary *)getDetails:(NSDictionary *)queryDic
{
    NSMutableDictionary *detailsDic =[[NSMutableDictionary alloc]initWithCapacity:1];
    
    // 定制状态下,detail 多返回uid 字段
    NSArray *blackArr;
      if ([NetvoxUserInfo shareInstance].requstBackAuthority)
        {
            blackArr = @[@"name",@"devicetype",@"udeviceid",@"roomid",@"status",@"pic",@"update_flag",@"house_ieee",@"fre"];
        }
       else
       {
            blackArr = @[@"uid",@"name",@"devicetype",@"udeviceid",@"roomid",@"status",@"pic",@"update_flag",@"house_ieee",@"fre"];
       }
    
    //comport_param字典 baudrate  parity stopbit
    NSMutableDictionary * comport_param = [[NSMutableDictionary alloc]initWithCapacity:1];
    for (NSString *key in queryDic) {
        NSString *value = queryDic[key];
        if ([NetvoxNetwork isInDetails:key value:value blackArr:blackArr]) {
            
            if (([key isEqualToString:@"baudrate"] && value.length != 0) || ([key isEqualToString:@"parity"] && value.length != 0) || ([key isEqualToString:@"stopbit"] && value.length != 0))
            {
                [comport_param setObject:value forKey:key];
            }
            else{
                [detailsDic setObject:value forKey:key];
            }
            
            
            if([key isEqualToString:@"colormode"] && value.length != 0)
            {
                NSMutableArray *colorModeArray = [NSMutableArray new];
                NSArray * colorStrArray = [value componentsSeparatedByString:@",,"];
                for (NSString * tempModeStr in colorStrArray)
                {
                    NSArray *strArr = [tempModeStr componentsSeparatedByString:@":"];
                    NSMutableDictionary *colorDic = [NSMutableDictionary new];
                    [colorDic setValue:strArr[0] forKey:@"id"];
                    [colorDic setValue:strArr[1] forKey:@"name"];
                    
                    [colorModeArray addObject:colorDic];
                }
                
                [detailsDic setObject:colorModeArray forKey:key];
            }
            
            if([key isEqualToString:@"sunlight_level"] && value.length != 0)
            {
                NSMutableArray *sunlight_levelArray = [NSMutableArray new];
                NSArray * sunlightStrArray = [value componentsSeparatedByString:@",,"];
                for (NSString * sunModeStr in sunlightStrArray)
                {
                    NSArray *strArr = [sunModeStr componentsSeparatedByString:@":"];
                    NSMutableDictionary *sunDic = [NSMutableDictionary new];
                    [sunDic setValue:strArr[0] forKey:@"end"];
                    [sunDic setValue:strArr[1] forKey:@"level"];
                    [sunDic setValue:strArr[2] forKey:@"start"];
                    [sunlight_levelArray addObject:sunDic];
                }
                
                [detailsDic setObject:sunlight_levelArray forKey:key];
            }
            //lora设备
//            if ([key isEqualToString:@"attributes"] && value.length != 0) {
//                NSLog(@"值 --   %@",value);
//            }

            if([key isEqualToString:@"attributes"] && value.length != 0)
            {
                
                NSString * attributes = value;
                NSMutableArray * attributesArray = [NSMutableArray arrayWithCapacity:1];
                if (![attributes isEqualToString:@""])
                {
                    NSArray * array = [attributes componentsSeparatedByString:@",,"];
                    for (NSString * str in array) {
                        NSDictionary * dic = [NetvoxCommon dictionaryWithJsonString:str];
                        [attributesArray addObject:dic];
                    }
                }
                
                
                /*
                NSMutableArray *attributesArray = [NSMutableArray new];
                NSArray * attributesStrArray = [value componentsSeparatedByString:@",,"];
                for (NSString * tempAttrStr in attributesStrArray)
                {
                    NSString * replace = [[[tempAttrStr stringByReplacingOccurrencesOfString:@"(\n)" withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    
                    NSArray *strArr = [replace componentsSeparatedByString:@":"];
                    NSMutableDictionary *attrDic = [NSMutableDictionary new];
                    [attrDic setValue:strArr[0] forKey:@"id"];
                    [attrDic setValue:strArr[1] forKey:@"unit"];
                    [attrDic setValue:strArr[2] forKey:@"name_cn"];
                    [attrDic setValue:strArr[3] forKey:@"name_en"];
                    [attrDic setValue:strArr[4] forKey:@"data_type"];
                    [attrDic setValue:strArr[5] forKey:@"rule_attr"];
                    [attrDic setValue:strArr[6] forKey:@"value"];
                    [attrDic setValue:strArr[7] forKey:@"actor"];
                    [attrDic setValue:strArr[8] forKey:@"enum_val"];
                    [attrDic setValue:strArr[9] forKey:@"home_page"];
                    [attrDic setValue:strArr[10] forKey:@"home_devices"];
                    [attrDic setValue:strArr[11] forKey:@"name_tw"];
                    [attrDic setValue:strArr[12] forKey:@"attr"];
                    [attributesArray addObject:attrDic];
                }*/
                
                [detailsDic setObject:attributesArray forKey:key];
            }
            
            
        }
    }
    if (comport_param.count != 0) {
        [detailsDic setObject:comport_param forKey:@"comport_param"];
    }
    
    return detailsDic;
}

//值是否添加
+(BOOL)isInDetails:(NSString *)key value:(NSString *)value blackArr:(NSArray *)blackArr
{
    BOOL res = NO;
    if (![value isEqualToString:@""] && ![NetvoxNetwork isContain:key arr:blackArr ]) {
        res=YES;
    }
    
    return res;
}

//是否包含某个字符串(arr内容为字符串)
+(BOOL)isContain:(NSString *)key arr:(NSArray *)arr
{
    
    for (int i = 0; i < [arr count]; i ++) {
        if ([key isEqualToString:[arr objectAtIndex:i]]) {
            return YES;
        }
    }
    return NO;
}

//获取房间列表
+(NSDictionary *)getLocalRoomList:(NSString *)seq
{
    NSMutableArray *requestArr =[[NSMutableArray alloc]initWithCapacity:1];
    
    NSArray *queryArr =[NetvoxDb query:TABLE_ROOM addArr:nil orArr:nil orderDic:nil limitDic:nil];
    for (NSDictionary *queryDic in queryArr) {
        NSString *uid =queryDic[@"uid"];
        NSString *name =queryDic[@"name"];
        NSString *picture =queryDic[@"picture"];
        NSDictionary *requstDic =@{@"id":uid,@"name":name,@"picture":picture};
        
        [requestArr addObject:requstDic];
    }
    
    return @{@"seq":seq,@"status_code":@0,@"result":requestArr};

}

//环境报表 设备数据表
+(NSDictionary *)getReportWithHouseIeee:(NSString *)houseIeee time:(NSString *)time seq:(NSString *)seq
{

    NSMutableArray * addArr = [NSMutableArray arrayWithCapacity:1];
    [addArr addObject:@{@"key":@"request_time",@"value":time,@"op":@"="}];
    
    //按照时间取出
    NSDictionary * orderDic = @{@"key":@"request_time",@"op":@"asc"};
    
    NSMutableDictionary * querDic = [NetvoxDb query:TABLE_REPORT addArr:addArr orderDic:orderDic];
   

    
    return querDic;
    
    
}




#pragma mark--内外网统一发送接口

//请求分发接口
+(void)sendWithParam:(NetvoxNetworkModel *)model CompletionHandler:(void (^)(NSDictionary *aResult))aResult
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NSString *timestamp=[NetvoxCommon getMs];
        NSString *seq = [NetvoxCommon getUuid];
        
        switch (model.networkType) {
            case netvoxNetworkTypeYSHttpGet:
            {
                //萤石 get(一般不用)
                [NetvoxHttpNetwork get:model.url parameters:model.params isYS:YES CompletionHandler:aResult];
            }
                break;
            case netvoxNetworkTypeYSHttpPost:
            {
                //萤石 post
                [NetvoxHttpNetwork post:model.url parameters:model.params isYS:YES CompletionHandler:aResult];
            }
                break;
                
            case netvoxNetworkTypeHttpGet:
            {
                //http get(一般不用)
                if (!model.user.proxyIp) {
            aResult(@{@"seq":@"1234",@"status_code":@1,@"result":@"failed"});
                    
                    return ;
                }
                
                NSString *param =  [NSString stringWithFormat:@"data=%@&seq=%@&timestamp=%@&user=%@",model.param,seq,timestamp,model.user.userName];
                NSString *sign = model.isNotEncrypt ? @"AAA": [NetvoxCommon md5:[NSString stringWithFormat:@"%@&%@",param,model.user.pwd]];
                NSDictionary *params = model.isNotEncrypt ? @{@"seq":seq,@"data":model.param,@"timestamp":timestamp,@"sign":sign}: @{@"seq":seq,@"data":model.param,@"timestamp":timestamp,@"user":model.user.userName,@"sign":sign};
                [NetvoxHttpNetwork get:model.url parameters:params isYS:NO CompletionHandler:aResult];
                
            }
                break;
            case netvoxNetworkTypeHttpPost:
            {
                //http post
                if (!model.user.proxyIp) {
                    aResult(@{@"seq":@"1234",@"status_code":@1,@"result":@"failed"});
                    
                    return ;
                }

                
                NSString *param = [NSString stringWithFormat:@"data=%@&seq=%@&timestamp=%@&user=%@",model.param,seq,timestamp,model.user.userName];
                NSString *sign = model.isNotEncrypt ? @"AAA": [NetvoxCommon md5:[NSString stringWithFormat:@"%@&%@",param,model.user.pwd]];
                NSDictionary *params = model.isNotEncrypt ? @{@"seq":seq,@"data":model.param,@"timestamp":timestamp,@"sign":sign,@"user":model.user.userName}: @{@"seq":seq,@"data":model.param,@"timestamp":timestamp,@"user":model.user.userName,@"sign":sign};
                [NetvoxHttpNetwork post:model.url parameters:params isYS:NO CompletionHandler:aResult];
            }
                break;
            case netvoxNetworkTypeUpload:
            {
                //上传到云端
                if (!model.user.proxyIp && model.isNotEncrypt == false) {
                    aResult(@{@"seq":@"1234",@"status_code":@1,@"result":@"failed"});
                    return ;
                }

                
                NSString *param = [NSString stringWithFormat:@"data=%@&seq=%@&timestamp=%@&user=%@",model.param,seq,timestamp,model.user.userName];
                NSString *sign = model.isNotEncrypt ? @"AAA": [NetvoxCommon md5:[NSString stringWithFormat:@"%@&%@",param,model.user.pwd]];
                NSString *sendCGI = [NSString stringWithFormat:@"%@&sign=%@",param,sign];
                NSString *sendURL = [NSString stringWithFormat:@"%@?%@",model.url,sendCGI];
                [NetvoxHttpNetwork post:sendURL parameters:nil nameArray:model.fileNameArray formDataArray:model.formDataArray mimeTypeArray:model.mimeTypeArray progress:model.progress isYS:NO CompletionHandler:aResult];
            }
                break;
            case netvoxNetworkTypeCGIUpload:
            {
                // CGI上传文件
                switch (model.user.netConnect)
                {
                    case connectTypeLocal:
                    {
                        NSString *param = [NSString stringWithFormat:@"data=%@&seq=%@&timestamp=%@&user=%@",model.param,seq,timestamp,model.user.userName];
                        NSString *sign = model.isNotEncrypt ? @"AAA": [NetvoxCommon md5:[NSString stringWithFormat:@"%@&%@",param,model.user.pwd]];
                        NSString *sendCGI = [NSString stringWithFormat:@"%@&sign=%@&file=%@",param,sign,model.file];
                        
                        if (model.user.isLocalSocketRes || (model.user.isUseATS && [model.user.header isEqualToString:@"https"])) {
                            [[NetvoxSocketManager shareInstance] requstWithCGI:sendCGI seq:seq type:model.type CompletionHandler:aResult];
                        }
                        else
                        {
                            //http 请求(get)
                            [NetvoxHttpNetwork get:[NSString stringWithFormat:@"http://%@/cgi-bin%@%@",model.user.localip,model.url,sendCGI] parameters:nil isYS:NO CompletionHandler:aResult];
                        }

                    }
                        break;
                    case connectTypeWide:
                    {
                        if (!model.user.msgIp || [model.user.msgIp isEqualToString:@""])
                        {
                            aResult(@{@"seq":@"1234",@"status_code":@1,@"result":@"failed msgIp is nil"});
                            
                            return ;
                        }
                        
                        NSString *param = [NSString stringWithFormat:@"{\"seq\":\"%@\",\"user\":\"%@\",\"file_hex\":\"%@\"}",seq,model.user.userName,model.file];
                        
                        [[NetvoxMqtt shareInstance] upLoadFileWithparam:param seq:seq CompletionHandler:aResult];
                    }
                        break;
                    default: //无网络连接
                    {
                       aResult(@{@"seq":@"1234",@"status_code":@-407,@"result":@"no internet"});
                    }
                        break;
                }
                break;
            }
            default:
            {
                // CGI
                
                NSString *param = [NSString stringWithFormat:@"data=%@&seq=%@&timestamp=%@&user=%@",model.param,seq,timestamp,model.user.userName];
                NSString *sign = model.isNotEncrypt ? @"AAA": [NetvoxCommon md5:[NSString stringWithFormat:@"%@&%@",param,model.user.pwd]];
                NSString *sendCGI = [NSString stringWithFormat:@"%@&sign=%@",param,sign];
           
                switch (model.user.netConnect) {
                    case connectTypeLocal:
                        //本地连接
                    {
                        if (model.user.isLocalSocketRes || (model.user.isUseATS && [model.user.header isEqualToString:@"https"])) {
                            [[NetvoxSocketManager shareInstance] requstWithCGI:sendCGI seq:seq type:model.type CompletionHandler:aResult];
                        }
                        else
                        {
                            //http 请求(get)
                            [NetvoxHttpNetwork get:[NSString stringWithFormat:@"http://%@/cgi-bin%@%@",model.user.localip,model.url,sendCGI] parameters:nil isYS:NO CompletionHandler:aResult];
                        }
                    }
                        break;
                    case connectTypeWide:
                        //外网连接
                        if (!model.user.msgIp || [model.user.msgIp isEqualToString:@""]) {
                            aResult(@{@"seq":@"1234",@"status_code":@1,@"result":@"failed msgIp is nil"});
                            
                            return ;
                        }
                        [[NetvoxMqtt shareInstance] sendUrl:model.url param:sendCGI seq:seq CompletionHandler:aResult];
                        break;
                        
                        
                    default:
                        //无网络连接
                    {
                        aResult(@{@"seq":@"1234",@"status_code":@-407,@"result":@"no internet"});
                        
                    }
                        break;
                }
                
                
                
            }
                break;
        }
       
        
    }];
}

#pragma mark--网关接口

#pragma mark-- 网关接口:设备操作

// 获取设备列表(cache 是否读缓存,暂未实现,用户名,密码先写死,先按内网的写)
+(void)getDeviceListWithRoomid:(NSString *)roomid devicetype:(NSString *)devicetype pagenum:(int)pagenum pagesize:(int)pagesize cache:(BOOL)cache CompletionHandler:(void (^)(NSDictionary *result))result
{
   
    NSString *fDevicetype= @"";
    
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list_details\",\"roomid\":\"%@\"%@,\"dev_ids\":[%@],\"pagenum\":%d,\"pagesize\":%d}",@"-1",fDevicetype,[NetvoxCommon strToJsonStr:@[@"-1"]],0,INT32_MAX];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;

    
    int count =0;
    if (cache) {
        //查询缓存中是否有
        count =[NetvoxDb queryCount:TABLE_DEVICE addArr:nil orArr:nil];
        if (count!=0) {
            result([NetvoxNetwork getLocalDeviceList:roomid devicetype:devicetype pagenum:pagenum pagesize:pagesize seq:@"1234"]);
        }
    }
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        
        
        //        if (!cache || count == 0) {
        if ([aResult[@"status_code"] intValue] !=0) {
            result(aResult);
        }
        else
        {
            [NetvoxDb update:TABLE_DEVICE data:aResult];
            result([NetvoxNetwork getLocalDeviceList:roomid devicetype:devicetype pagenum:pagenum pagesize:pagesize seq:aResult[@"seq"]]);
        }

    }];
    

}

//获取设备列表详情(dev_ids 数组元素请传NSString类型)
+(void)getDeviceListDetailWithRoomid:(NSString *)roomid devicetype:(NSString *)devicetype dev_ids:(NSArray *)dev_ids pagenum:(int)pagenum pagesize:(int)pagesize cache:(BOOL)cache CompletionHandler:(void (^)(NSDictionary *result))result
{
  
    NSString *fDevicetype= @"";

    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list_details\",\"roomid\":\"%@\",\"devicetype\":\"%@\",\"dev_ids\":[%@],\"pagenum\":%d,\"pagesize\":%d}",roomid,devicetype,[NetvoxCommon strToJsonStr:@[@"-1"]],pagenum,pagesize];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;

 
    int count =0;
    if (cache) {
        //查询缓存中是否有
        count =[NetvoxDb queryCount:TABLE_DEVICE addArr:nil orArr:nil];
        if (count!=0) {
            result([NetvoxNetwork getLocalDeviceListDetail:roomid devicetype:devicetype dev_ids:dev_ids pagenum:pagenum pagesize:pagesize seq:@"1234"]);
        }
    }
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        
        //判断是否是Ipv6 假数据
        if ([NetvoxCommon isIpv6] && [user.userName isEqualToString: houseAndUserName]) {
            NSDictionary * dic = [NetvoxNetwork backDicForIpv6:@"" andaResult:aResult andRequest:@"list"];
            result(dic);
            return;
            
            
        }
        
        
        //        if (!cache || count == 0) {
        if ([aResult[@"status_code"] intValue] !=0
//            || [user.currentHouseIeee containsString:@"00137A10"]
            ) {
            result(aResult);
        }
        else
        {
            [NetvoxDb update:TABLE_DEVICE data:aResult];
            NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"];
             NSLog(@"%@",path);

            result([NetvoxNetwork getLocalDeviceListDetail:roomid devicetype:devicetype dev_ids:dev_ids pagenum:pagenum pagesize:pagesize seq:aResult[@"seq"]]);
        }

    }];
    
    
}

//获取单个设备详情
+(void)getDeviceDetailWithDev_id:(NSString *)dev_id CompletionHandler:(void (^)(NSDictionary *result))result
{
  
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"details\",\"dev_id\":\"%@\"}",dev_id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        //判断是否是Ipv6 假数据
        if ([NetvoxCommon isIpv6] && [user.userName isEqualToString: houseAndUserName]) {
            result([NetvoxNetwork backDicForIpv6:dev_id andaResult:aResult andRequest:@"device"] );
            return;
        }
        
        result(aResult);
    }];
    
}

//设备开加网操作
+(void)opennetWithTime:(int)time CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"opennet\",\"time\":%d}",time];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
   
}

//设备搜索（UDP）广播
+(void)searchDeviceWithDeviceType:(NSString *)deviceType Time:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"udp_dev_search\",\"devicetype\":\"%@\",\"time\":\"%@\"}",deviceType,time];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//添加设备(udeviceid ,ext为可选参数,ext字典key为sn和verify,如@{@"sn":@"1234",@"verify_code":@"434"}
+(void)addDeviceWithIeee:(NSString *)ieee devicetype:(NSString *)devicetype udeviceid:(NSString *)udeviceid ext:(NSDictionary *)ext CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    //可选参数devicetype
    NSString *fdevicetype= !devicetype ? @"" : [NSString stringWithFormat:@",\"devicetype\":\"%@\"",devicetype];
    
    
    //可选参数 ext
    NSString *fext= @"";
    if (ext && [ext isKindOfClass:[NSDictionary class]]) {
        NSString *sn = ext[@"sn"];
        NSString *verify_code = ext[@"verify_code"];
        fext = [NSString stringWithFormat:@",\"ext\":{\"sn\":\"%@\",\"verify_code\":\"%@\"}",sn,verify_code];
    }
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"adddev\",\"ieee\":\"%@\"%@,\"udeviceid\":\"%@\"%@}",ieee,fdevicetype,udeviceid,fext];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}

//删除设备
+(void)deleteDeviceWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"deldev\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}

//添加预置点
+(void)addPresetpointWithId:(NSString *)Id name:(NSString *)name desc:(NSString *)desc createTime:(NSString *)createTime CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"add_presetpoint\",\"id\":\"%@\",\"name\":\"%@\",\"desc\":\"%@\",\"create_time\":\"%@\"}",Id,name,desc,createTime];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
   
}

//修改预置点
+(void)modifyPresspointWithId:(NSString *)Id name:(NSString *)name desc:(NSString *)desc CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"update_presetpoint\",\"id\":\"%@\",\"name\":\"%@\",\"desc\":\"%@\"}",Id,name,desc];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//删除预置点
+(void)deletePresetpointWithId:(NSString *)Id name:(NSString *)name CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"del_presetpoint\",\"id\":\"%@\",\"name\":\"%@\"}",Id,name];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}
//获取预置点列表
+(void)getPresetpointListWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list_presetpoint\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}

//修改设备信息
+(void)updateDevInfoWithId:(NSString *)Id name:(NSString *)name roomid:(NSString *)rooomid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    //可选参数name
    NSString *fname= !name ? @"" : [NSString stringWithFormat:@",\"name\":\"%@\"",name];

    //可选参数rooomid
    NSString *frooomid= !rooomid ? @"" : [NSString stringWithFormat:@",\"roomid\":\"%@\"",rooomid];

    NSString *str=[NSString stringWithFormat:@"{\"op\":\"update_devinfo\",\"id\":\"%@\"%@%@}",Id,fname,frooomid];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}
//设备开操作
+(void)onWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"on\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设备关操作
+(void)offWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"off\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//设备置反操作
+(void)toggleWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"toggle\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//调节设备级别
+(void)setlevelWithId:(NSString *)Id level:(int)level CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"setlevel\",\"id\":\"%@\",\"level\":%d}",Id,level];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设备背板亮度设置
+(void)setbglevelWithId:(NSString *)Id level:(int)level CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"setbglevel\",\"id\":\"%@\",\"level\":%d}",Id,level];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//设置彩灯颜色(transTime 为可选参数,不设置请传-1)
+(void)setcolorWithId:(NSString *)Id r:(int)r g:(int)g b:(int)b transTime:(int)transTime CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数transTime
    NSString *ftransTime= (transTime == -1) ? @"" : [NSString stringWithFormat:@",\"trans_time\":%d",transTime];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"setcolor\",\"id\":\"%@\",\"r\":%d,\"g\":%d,\"b\":%d%@}",Id,r,g,b,ftransTime];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}
//设置彩灯色温(transTime 为可选参数,不设置请传-1)
+(void)setcolortempWithId:(NSString *)Id level:(int)level transTime:(int)transTime CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数transTime
    NSString *ftransTime= (transTime == -1) ? @"" : [NSString stringWithFormat:@",\"trans_time\":%d",transTime];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"setcolortemp\",\"id\":\"%@\",\"level\":%d%@}",Id,level,ftransTime];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}
//获取彩灯模式列表
+(void)getColorModeWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list_colormode\",\"dev_id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}


//新增修改彩灯模式(或修改）modelId = -1为新增 colorArr里存字典，{r:x,g:x,b:x,duration:x}
+(void)addColorModeWithId:(NSString *)Id ModeId:(NSString *)modeId Name:(NSString *)name ColorArr:(NSArray *)arr CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *content= @"";
    if (![arr isKindOfClass:[NSArray class]] || arr.count <1 || ![arr[0] isKindOfClass:[NSDictionary class]] ) {
        
        result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"content error"});
        return;
    }
    else
    {
        NSMutableString *mutStr = [[NSMutableString alloc]initWithString:@"["];
        for (NSDictionary * dic in arr) {
            [mutStr appendString:@"{"];
            NSString * r = [dic valueForKey:@"r"];
            NSString * g = [dic valueForKey:@"g"];
            NSString * b = [dic valueForKey:@"b"];
            NSString * duration = [dic objectForKey:@"duration"];
            if(r == nil || g == nil || b == nil || duration == nil)
            {
                result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"r、g、b、duration error"});
                return;
            }
            else
            {
                [mutStr appendFormat:@"\"r\":%d,\"g\":%d,\"b\":%d,\"duration\":%d",[r intValue],[g intValue],[b intValue],[duration intValue]];
            }
            [mutStr appendFormat:@"},"];
        }
        
        [mutStr replaceCharactersInRange:NSMakeRange(mutStr.length-1, 1) withString:@"]"];
        content = mutStr;
    }
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"setcolormode\",\"dev_id\":\"%@\",\"id\":%@,\"name\":\"%@\",\"content\":%@}",Id,modeId,name,content];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//删除彩灯模式
+(void)deleteColorModeWithId:(NSString *)Id ModeId:(NSString *)modeId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"del_colormode\",\"dev_id\":\"%@\",\"id\":%@}",Id,modeId];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}



//应用彩灯模式
+(void)applyColorModeWithId:(NSString *)Id ModeId:(NSString *)modeId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"apply_colormode\",\"dev_id\":\"%@\",\"id\":%@}",Id,modeId];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//设备响铃
+(void)ringWithId:(NSString *)Id sound:(NSString *)sound CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"ring\",\"id\":\"%@\",\"sound\":\"%@\"}",Id,sound];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//设备停止操作
+(void)stopWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"stop\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//开门操作
+(void)openDoorWithId:(NSString *)Id userId:(NSString *)userId pwd:(NSString *)pwd CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"opendoor\",\"id\":\"%@\",\"userid\":\"%@\",\"password\":\"%@\"}",Id,userId,pwd];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//读取温控器开关状态
+ (void)getThermostatOnoffStatusWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_thermostat_onoff_status\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设置温控器温度
+ (void)setThermostatTemperatureWithId:(NSString *)Id temperature:(NSString *)temperature CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_thermostat_temperature\",\"id\":\"%@\",\"temperature\":\"%@\"}",Id,temperature];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//读取温控器温度
+ (void)getThermostatTemperatureWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\" get_thermostat_temperature\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设置温控器风量
+ (void)setThermostatWindspeedWithId:(NSString *)Id windspeed:(NSString *)windspeed CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_thermostat_windspeed\",\"id\":\"%@\",\"windspeed\":\"%@\"}",Id,windspeed];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//读取温控器风量
+ (void)getThermostatWindspeedWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_thermostat_windspeed\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//温控器模式设置 模式(cool/heat/fanonly)
+ (void)setThermostatModeWithId:(NSString *)Id mode:(NSString *)mode CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_thermostat_mode\",\"id\":\"%@\",\"mode\":\"%@\"}",Id,mode];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}



//发送IR命令
+(void)sendIrWithId:(NSString *)Id irData:(NSString *)irdata CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"sendir\",\"id\":\"%@\",\"irdata\":\"%@\"}",Id,irdata];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//设备退出学习模式 传真实设备id
+(void)quitIrLearnWithDevId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"stop\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//下载IR数据
+(void)downloadIRDataWithBrandId:(NSString *)brandId ModelId:(NSString *)modelId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"download_irdev_data\",\"brandid\":\"%@\",\"modelid\":\"%@\"}",brandId,modelId];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//测试IR设备按键 Irdevice IR设备类型    Irseq key对应的IR序号
+(void)testIRKeyWithDevid:(NSString *)devId Irdevice:(NSString *)irdevice Irseq:(NSString *)irseq  CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"test_irdev_key\",\"irdevice\":\"%@\",\"z211_devid\":\"%@\",\"irseq\":\"%@\"}",irdevice,devId,irseq];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//点击IR设备按键
+(void)clickIRDevWithVirtualDevid:(NSString *)devId Irseq:(NSString *)irseq  CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"click_irdev_key\",\"devid\":\"%@\",\"irseq\":\"%@\"}",devId,irseq];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//确认IR设备有效
+(void)checkIRDevWithDevid:(NSString *)devId Irdevice:(NSString *)irdevice CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"confirm_irdev\",\"irdevice\":\"%@\",\"z211_devid\":\"%@\"}",irdevice,devId];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取IR设备按键
+(void)getIRKeyWithVirtualDevid:(NSString *)devId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list_irdev_key\",\"devid\":\"%@\"}",devId];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//新增IR设备
+(void)addIRDevWithDevid:(NSString *)devId Irdevice:(NSString *)irdevice CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"add_irdev\",\"irdevice\":\"%@\",\"z211_devid\":\"%@\"}",irdevice,devId];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//新增IR设备按键 Devid虚拟设备id   Irseq 可以对应irsq  Tag 标签
+(void)addIRKeyWithVirtualDevid:(NSString *)devId Irseq:(NSString *)irseq Tag:(NSString *)tag CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"add_irdev_key\",\"devid\":\"%@\",\"irseq\":\"%@\",\"tag\":\"%@\"}",devId,irseq,tag];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//删除IR设备按键
+(void)deleteIRKeyWithVirtualDevid:(NSString *)devId Irseq:(NSString *)irseq CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"del_irdev_key\",\"devid\":\"%@\",\"irseq\":\"%@\"}",devId,irseq];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//学习IR设备按键  Devid 传虚拟设备id
+(void)learnIRKeyWithVirtualDevid:(NSString *)devId Irseq:(NSString *)irseq CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"learn_irdev_key\",\"devid\":\"%@\",\"irseq\":\"%@\"}",devId,irseq];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//IR设备分享
+(void)shareIRDevWithVirtualDevid:(NSString *)devId Brandid:(NSString *)brandid Modelid:(NSString *)modelid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"share_irdev\",\"devid\":\"%@\",\"brandid\":\"%@\",\"modelid\":\"%@\"}",devId,brandid,modelid];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//接受IR设备分享
+(void)recieveIRShareWithDevid:(NSString *)devId Share_code:(NSString *)code CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"recv_irdev\",\"z211_devid\":\"%@\",\"share_code\":\"%@\"}",devId,code];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//新增485设备
+(void)addSpdeviceWithUdeviceid:(NSArray *)udevice Spdevice:(NSString *)spdevice CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数timer
    NSMutableString *devid = [[NSMutableString alloc]init];
    
    if (udevice && udevice.count!=0) {
        [devid appendString:@",\"udeviceid\":["];
        
        for (NSString *str in udevice) {
            
            [devid appendFormat:@"\"%@\",",str];
        }
        
        if ([[devid substringFromIndex:devid.length-1] isEqualToString:@","]) {
            [devid replaceCharactersInRange:NSMakeRange(devid.length-1, 1) withString:@"]"];
        }
        else
        {
            [devid appendString:@"]"];
        }
        
    }
    
    NSString *str = [NSString stringWithFormat:@"{\"op\":\"add_spdevice\"%@,\"spdevice\":\"%@\"}",devid,spdevice];
    NSString *url = [NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取485按键设备
+(void)getListSpdevkeyWithDevid:(NSString *)devId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str = [NSString stringWithFormat:@"{\"op\":\"list_spdev_key\",\"devid\":\"%@\"}",devId];
    NSString *url = [NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//点击485设备按键(不包括大金空调)
+(void)clickSpdevKeyWithDevid:(NSString *)devId FuncId:(NSString *)funcId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str = [NSString stringWithFormat:@"{\"op\":\"click_spdev_key\",\"devid\":\"%@\",\"func_id\":\"%@\"}",devId,funcId];
    NSString *url = [NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//点击发送指令(大金空调)
+(void)sendSpdevCommandWithDevid:(NSString *)devId cmdType:(NSString *)cmdType command:(NSString *)command CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str = [NSString stringWithFormat:@"{\"op\":\"send_spdev_command\",\"devid\":\"%@\",\"cmd_type\":\"%@\",\"command\":\"%@\"}",devId,cmdType,command];
    NSString *url = [NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//布防
+(void)armCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"arm\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}



//撤防
+(void)disarmCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"disarm\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//播放
+(void)mediaPlayWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"play\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//暂停
+(void)mediaPauseWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"pause\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//调节音量
+(void)mediaVolumeWithId:(NSString *)Id andVolume:(int)volume CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_volume\",\"id\":\"%@\",\"volume\":%d}",Id,volume];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//调节进度
+(void)mediaProgressWithId:(NSString *)Id andProgress:(int)progress CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_progress\",\"id\":\"%@\",\"progress\":%d}",Id,progress];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//上一首
+(void)mediaPreWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"media_pre\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//下一首
+(void)mediaNextWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"media_next\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取当前媒体详情
+(void)getCurrentMeidaDetailWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"current_meida_details\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//切换播放模式
+(void)changePlayModeWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"change_play_mode\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//切换媒体来源
+(void)changeMediaSourceWithId:(NSString *)Id Source:(NSString *)source CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"change_media_source\",\"source\":\"%@\",\"id\":\"%@\"}",source,Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//清空电能
+(void)clearEnergyWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"clear_energy\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}

//设备识别
+(void)identifyWithId:(NSString *)Id time:(int)time CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"identify\",\"id\":\"%@\",\"time\":%d}",Id,time];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}

//设置设备参数(不用的参数,属性请不要赋值)
+(void)setParamWithId:(NSString *)Id param:(NetvoxDeviceParam *)param CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数poweron_status
    NSString *poweron_status= !param.poweron_status ? @"" : [NSString stringWithFormat:@",\"poweron_status\":\"%@\"",param.poweron_status];
    
    //可选参数sunlight_threshold
    NSString *sunlight_threshold= !param.sunlight_threshold ? @"" : [NSString stringWithFormat:@",\"sunlight_threshold\":%@",param.sunlight_threshold];
    
    //可选参数ir_disable_time
    NSString *ir_disable_time= !param.ir_disable_time ? @"" : [NSString stringWithFormat:@",\"ir_disable_time\":%@",param.ir_disable_time];
    
    //可选参数ir_detection_time
    NSString *ir_detection_time= !param.ir_detection_time ? @"" : [NSString stringWithFormat:@",\"ir_detection_time\":%@",param.ir_detection_time];
    
    //可选参数childlock
    NSString *childlock= !param.childlock? @"" : [NSString stringWithFormat:@",\"childlock\":\"%@\"",param.childlock];
    
    //可选参数onoff_dir
    NSString *onoff_dir= !param.onoff_dir ? @"" : [NSString stringWithFormat:@",\"onoff_dir\":\"%@\"",param.onoff_dir];
    
    //可选参数relay_setting
    NSString *relay_setting= !param.relay_setting ? @"" : [NSString stringWithFormat:@",\"relay_setting\":\"%@\"",param.relay_setting];
    
    
    //可选参数check_setting
    NSString *check_setting= !param.check_setting ? @"" : [NSString stringWithFormat:@",\"check_setting\":\"%@\"",param.check_setting];
    
    //可选参数warn_delay
    NSString *warn_delay= !param.warn_delay ? @"" : [NSString stringWithFormat:@",\"warn_delay\":%@",param.warn_delay];
    
    
    //可选参数count_clear_time
    NSString *count_clear_time= !param.count_clear_time ? @"" : [NSString stringWithFormat:@",\"count_clear_time\":%@",param.count_clear_time];
    
    //可选参数liquid_level_check_value
    NSString *liquid_level_check_value= !param.liquid_level_check_value ? @"" : [NSString stringWithFormat:@",\"liquid_level_check_value\":%@",param.liquid_level_check_value];
    
    //可选参数wire_length
    NSString *wire_length= !param.wire_length ? @"" : [NSString stringWithFormat:@",\"wire_length\":%@",param.wire_length];
    
    
    //可选参数detect_sensitivity
    NSString *detect_sensitivity= !param.detect_sensitivity ? @"" : [NSString stringWithFormat:@",\"detect_sensitivity\":\"%@\"",param.detect_sensitivity];
    
    //可选参数sampling_period
    NSString *sampling_period= !param.sampling_period ? @"" : [NSString stringWithFormat:@",\"sampling_period\":%@",param.sampling_period];
    
    //可选参数motor_setting
    NSString *motor_setting= !param.motor_setting ? @"" : [NSString stringWithFormat:@",\"motor_setting\":\"%@\"",param.motor_setting];
    
    //可选参数stop_way
    NSString *stop_way= !param.stop_way ? @"" : [NSString stringWithFormat:@",\"stop_way\":\"%@\"",param.stop_way];
    
    //可选参数switch_way
    NSString *switch_way= !param.switch_way ? @"" : [NSString stringWithFormat:@",\"switch_way\":\"%@\"",param.switch_way];
    
    //可选参数duration
    NSString *duration= !param.duration ? @"" : [NSString stringWithFormat:@",\"duration\":%@",param.duration];
    
    //可选参数ir_delay_time
    NSString *ir_delay_time= !param.ir_delay_time ? @"" : [NSString stringWithFormat:@",\"ir_delay_time\":%@",param.ir_delay_time];
    
    //可选参数panel_brightness
    NSString *panel_brightness= !param.panel_brightness ? @"" : [NSString stringWithFormat:@",\"panel_brightness\":%@",param.panel_brightness];
    
    //可选参数enable
    NSString *enable= !param.enable ? @"" : [NSString stringWithFormat:@",\"enable\":%@",param.enable];
    
    //可选参数config_mode
    NSString *config_mode= @"";
    if (param.config_mode.count > 0) {
        if (![param.config_mode isKindOfClass:[NSArray class]] || ![param.config_mode[0] isKindOfClass:[NSString class]] ) {
            
            result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"config_mode error"});
            return;
        }
        else
        {
            NSMutableString *mutStr = [[NSMutableString alloc]initWithString:@",\"config_mode\":["];
            for (NSString * str in param.config_mode) {
                [mutStr appendFormat:@"%@,",str];
            }
            
            [mutStr replaceCharactersInRange:NSMakeRange(mutStr.length-1, 1) withString:@"]"];
            config_mode = mutStr;
        }
    }
    
    
    

    //可选参数comport_param
    NSString *comport_param= @"";
    if (param.comport_param) {
        if (![param.comport_param isKindOfClass:[NSDictionary class]]) {
            
            result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"config_mode error"});
            return;
        }
        else
        {
            int baudrate = [param.comport_param[@"baudrate"] intValue];
            int stopbit = [param.comport_param[@"stopbit"] intValue];
            int parity = [param.comport_param[@"parity"] intValue];
            
            
            comport_param = [NSString stringWithFormat:@",\"comport_param\":{\"baudrate\":%d,\"stopbit\":%d,\"parity\":%d}",baudrate,stopbit,parity];
            
        }
    }

    
    //可选参数window_cover_param
    NSString *window_cover_param= @"";
    if (param.window_cover_param) {
        if (![param.window_cover_param isKindOfClass:[NSDictionary class]]) {
            
            result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"window_cover_param error"});
            return;
        }
        else
        {
            NSString * hand_start_onoff = param.window_cover_param[@"hand_start_onoff"];
            NSString * reverse_onoff = param.window_cover_param[@"reverse_onoff"];
//            NSString * continue_mode_onoff = param.window_cover_param[@"continue_mode_onoff"];//暂时先不要
            int max_speed = [param.window_cover_param[@"max_speed"] intValue];
            NSString * shade_type = param.window_cover_param[@"shade_type"];
            
            window_cover_param = [NSString stringWithFormat:@",\"window_cover_param\":{\"hand_start_onoff\":\"%@\",\"reverse_onoff\":\"%@\",\"max_speed\":%d,\"shade_type\":\"%@\"}",hand_start_onoff,reverse_onoff,max_speed,shade_type];
            
        }
    }
    
    //可选参数ir_trigger_relay_action
    NSString *ir_trigger_relay_action= !param.ir_trigger_relay_action ? @"" : [NSString stringWithFormat:@",\"ir_trigger_relay_action\":%@",param.ir_trigger_relay_action];
    
    //可选参数twice_onoff_relay_action
    NSString *twice_onoff_relay_action= !param.twice_onoff_relay_action ? @"" : [NSString stringWithFormat:@",\"twice_onoff_relay_action\":%@",param.twice_onoff_relay_action];
    
    
    //可选参数sunlight_check_range
    NSString *sunlight_check_range= !param.sunlight_check_range ? @"" : [NSString stringWithFormat:@",\"sunlight_check_range\":%@",param.sunlight_check_range];

    //可选参数sunlight_level
    NSString *sunlight_level= !param.sunlight_level ? @"" : [NSString stringWithFormat:@",\"sunlight_level\":%@",param.sunlight_level];
    
    //可选参数valve_type
    NSString *valve_type= !param.valve_type ? @"" : [NSString stringWithFormat:@",\"valve_type\":\"%@\"",param.valve_type];
    //可选参数move_time
    NSString *move_time= !param.move_time ? @"" : [NSString stringWithFormat:@",\"move_time\":%@",param.move_time];
    //可选参数warn_way
    NSString *warn_way= !param.warn_way ? @"" : [NSString stringWithFormat:@",\"warn_way\":\"%@\"",param.warn_way];
    //可选参数ir_check_mode
    NSString *ir_check_mode= !param.ir_check_mode ? @"" : [NSString stringWithFormat:@",\"ir_check_mode\":\"%@\"",param.ir_check_mode];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_param\",\"id\":\"%@\"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@}",Id,poweron_status,sunlight_threshold,ir_disable_time,ir_detection_time,childlock,onoff_dir,relay_setting,check_setting,warn_delay,panel_brightness,enable,count_clear_time,liquid_level_check_value,wire_length,config_mode,detect_sensitivity,sampling_period,motor_setting,stop_way,switch_way,duration,ir_delay_time,comport_param,ir_trigger_relay_action,twice_onoff_relay_action,sunlight_check_range,valve_type,move_time,window_cover_param,warn_way,ir_check_mode,sunlight_level];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设备进入学习模式
+(void)learnWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"learn\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设备绑定
+(void)bindWithId:(NSString *)Id dest_devid:(NSString *)dest_devid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"bind\",\"id\":\"%@\",\"dest_devid\":\"%@\"}",Id,dest_devid];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设备解绑定
+(void)unbindWithId:(NSString *)Id dest_devid:(NSString *)dest_devid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"unbind\",\"id\":\"%@\",\"dest_devid\":\"%@\"}",Id,dest_devid];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取已绑定列表
+(void)getBindListWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_bind_list\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//获取可绑定列表
+(void)getAvailableBindListWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_available_bind_list\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}




//设置空气净化器
+(void)aircleanerConfigWithId:(NSString *)Id onoff_status:(NSString *)onoff_status childlock:(NSString *)childlock delayPowerOffTime:(NSString *)delayPowerOffTime windspeed:(NSString *)windspeed anionSwitch:(NSString *)anionSwitch cleanFilterScreen:(NSString *)cleanFilterScreen CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数powerSwitch
    NSString *fonoff_status= !onoff_status ? @"" : [NSString stringWithFormat:@",\"onoff_status\":\"%@\"",onoff_status];
    
    //可选参数childlock
    NSString *fchildlock= !childlock ? @"" : [NSString stringWithFormat:@",\"child_lock\":\"%@\"",childlock];
    
    //可选参数delayPowerOffTime
    NSString *fdelayPowerOffTime= !delayPowerOffTime ? @"" : [NSString stringWithFormat:@",\"delay_poweroff_time\":\"%@\"",delayPowerOffTime];
    
    //可选参数windspeed
    NSString *fwindspeed= !windspeed ? @"" : [NSString stringWithFormat:@",\"wind_speed\":\"%@\"",windspeed];
    
    //可选参数anionSwitch
    NSString *fanionSwitch= !anionSwitch ? @"" : [NSString stringWithFormat:@",\"anion_switch\":\"%@\"",anionSwitch];
    
    //可选参数cleanFilterScreen
    NSString *fcleanFilterScreen= !cleanFilterScreen ? @"" : [NSString stringWithFormat:@",\"clean_filter_screen\":\"%@\"",cleanFilterScreen];
    
    
    
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_aircleaner_config\",\"id\":\"%@\"%@%@%@%@%@%@}",Id,fonoff_status,fchildlock,fdelayPowerOffTime,fwindspeed,fanionSwitch,fcleanFilterScreen];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取空气净化器(config 数组内容参考设置空气净化器)
+(void)getAirCleanerConfigWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_aircleaner_config\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//设置空气净化器定时(timer 为存放字典的数组,字典key有id,action,enable,week,excute_time,例如:@[@{@“id”:@-1,@”action”:@”poweron”,@”enable”:@”0”,@”week”:@”0001001”,@”excute_time”:@”12:00”}])
+(void)setAircleanerTimerWithId:(NSString *)Id timer:(NSArray *)timer CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数timer
    NSMutableString *fTimer = [[NSMutableString alloc]init];
    
    if (timer && timer.count!=0) {
        [fTimer appendString:@",\"timer\":["];
        for (NSDictionary *dic in timer) {
            int tId = [dic[@"id"] intValue];
            NSString *action = dic[@"action"];
            NSString *enable = dic[@"enable"];
            NSString *week = dic[@"week"];
            NSString *excute_time = dic[@"excute_time"];
            [fTimer appendFormat:@"{\"id\":%d,\"action\":\"%@\",\"enable\":\"%@\",\"week\":\"%@\",\"excute_time\":\"%@\"},",tId,action,enable,week,excute_time];
        }
        
        [fTimer replaceCharactersInRange:NSMakeRange(fTimer.length-1, 1) withString:@"]"];
    }
    
    
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_aircleaner_timer\",\"id\":\"%@\"%@}",Id,fTimer];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//删除空气净化器定时(timerIds 为删除定时id的数组,值为NSNumber类型,例如:@[@1,@2])
+(void)deleteAircleanerTimerWithId:(NSString *)Id timerIds:(NSArray *)timerIds CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数timer
    NSMutableString *fTimer = [[NSMutableString alloc]init];
    
    if (timerIds && timerIds.count!=0) {
        [fTimer appendString:@",\"timer\":["];
        for (NSNumber *num in timerIds) {
           
            [fTimer appendFormat:@"{\"id\":%@},",num];
        }
        
        [fTimer replaceCharactersInRange:NSMakeRange(fTimer.length-1, 1) withString:@"]"];
    }
    else
    {
     result(@{@"seq":@"1234",@"status_code":@-411,@"result":@"timerIds error"});
        
        return ;
    }
    
    
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"del_aircleaner_timer\",\"id\":\"%@\"%@}",Id,fTimer];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取空气净化器定时
+(void)getAirCleanerTimerWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    

    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_aircleaner_timer\",\"id\":\"%@\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//获取组信息
+(void)getGroupMesWithGroupId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list_groupdata\",\"groupid\":%@}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/devgroup.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设备绑定组
+(void)deviceBindGroupWithDeviceId:(NSString *)devId GroupId:(NSString *)groupId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"bind_groupdevice\",\"dev_id\":\"%@\",\"groupid\":%@}",devId,groupId];
    NSString *url =[NSString stringWithFormat:@"/smarthome/devgroup.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设备解绑组
+(void)deviceUnbindGroupWithDeviceId:(NSString *)devId GroupId:(NSString *)groupId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"unbind_groupdevice\",\"dev_id\":\"%@\",\"groupid\":%@}",devId,groupId];
    NSString *url =[NSString stringWithFormat:@"/smarthome/devgroup.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取门锁绑定用户列表
+(void)getDoorlockBindUserlistWithId:(NSString *)Id user:(NSString *)appUser CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_doorlock_bind_userlist\",\"dev_id\":\"%@\",\"user\":\"%@\"}",Id,appUser];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//绑定门锁账户
+(void)bindDoorlockUserWithId:(NSString *)Id appUser:(NSString *)appUser userType:(int)userType CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"bind_doorlock_user\",\"dev_id\":\"%@\",\"app_user\":\"%@\",\"user_type\":%d}",Id,appUser,userType];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//解绑门锁账户
+(void)unbindDoorlockUserWithId:(NSString *)Id appUser:(NSString *)appUser doorlockUserid:(NSString *)doorlockUserid delFlag:(int)delFlag superpwd:(NSString *)superpwd CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数superpwd
    NSString *fsuperpwd= !superpwd ? @"" : [NSString stringWithFormat:@",\"superpwd\":\"%@\"",superpwd];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"unbind_doorlock_user\",\"dev_id\":\"%@\",\"app_user\":\"%@\",\"doorlock_userid\":\"%@\",\"del_flag\":%d%@}",Id,appUser,doorlockUserid,delFlag,fsuperpwd];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//删除门锁账户
+(void)deleteDoorlockUserWithId:(NSString *)Id doorlockUserId:(NSString *)doorlockUserid superpwd:(NSString *)superpwd CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"del_doorlock_user\",\"dev_id\":\"%@\",\"doorlock_userid\":\"%@\",\"superpwd\":\"%@\"}",Id,doorlockUserid,superpwd];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//新增门锁账户(user_type 为可选参数,不用的时候传-1)
+(void)addDoorlockUserWithId:(NSString *)Id appUser:(NSString *)appUser doorlockUserid:(NSString *)doorlockUserid doorlockPwd:(NSString *)doorlockPwd superpwd:(NSString *)superpwd userType:(int)userType CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数userType
    NSString *fuserType= (userType == -1) ? @"" : [NSString stringWithFormat:@",\"user_type\":%d",userType];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"add_doorlock_user\",\"dev_id\":\"%@\",\"app_user\":\"%@\",\"doorlock_userid\":\"%@\",\"doorlock_pwd\":\"%@\",\"superpwd\":\"%@\"%@}",Id,appUser,doorlockUserid,doorlockPwd,superpwd,fuserType];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//修改门锁超级密码
+(void)updateDoorlockSuperpwdWithId:(NSString *)Id oldPwd:(NSString *)oldPwd newPwd:(NSString *)newPwd CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"update_doorlock_superpwd\",\"dev_id\":\"%@\",\"old_pwd\":\"%@\",\"new_pwd\":\"%@\"}",Id,oldPwd,newPwd];
    NSString *url =[NSString stringWithFormat:@"/smarthome/device.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000001;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}
#pragma mark-- 网关接口:用户操作


//登录
+(void)loginWithTag:(NSString *)tag andIsLocal:(BOOL)islocal CompletionHandler:(void (^)(NSDictionary *result))result
{
    
    //内外网连接 判别
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    [[NetvoxSocketManager shareInstance] cutOffSocket];
    [[NetvoxMqtt shareInstance] disconnect];
    
    user.isLocalLogin = islocal;
    if (islocal)
    {
        user.netConnect = connectTypeLocal;
    }else{
        user.netConnect = connectTypeWide;
    }
    //网络判别
    switch (user.networkStatus) {
        case 0:
            //wifi
            if (user.isLocalLogin)
            {
                user.currentConnectType = currentConnectTypeSocket;
            }else{
                user.currentConnectType = currentConnectTypeMqtt;
            }
            
            break;
        case 2:
            //蜂窝数据
            user.currentConnectType = currentConnectTypeMqtt;
            break;
            
        default:
            //无网络
            user.currentConnectType = currentConnectTypeNone;
            break;
    }
    
    if (islocal) {
        
        //内网登陆
        user.netConnect = connectTypeLocal;
        
        NSString *str=[NSString stringWithFormat:@"{\"op\":\"login\",\"user\":\"%@\",\"pwd\":\"%@\"}",user.userName,[NetvoxCommon md5:user.pwd]];
        NSString *url =[NSString stringWithFormat:@"/smarthome/user.cgi?"];
        
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeCGI;
        model.user = user;
        model.type = 0x1000002;
        model.url = url;
        model.param = str;
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            //发送登陆请求
            [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
                if ([aResult[@"status_code"] intValue]==0) {
                    NSDictionary *resDic = aResult[@"result"];
                    NSString *nickname = resDic[@"nickname"];
                    NSString *photo = resDic[@"photo"];
                    NSString *house_ieee = resDic[@"house_ieee"];
                    NSString *housename = resDic[@"housename"];
                    NSString *username = resDic[@"user"];
                    NSString *houseStatus = @"online";  //网关在线
                    //                        user.isLocalSocketRes = YES;      //我们网管的socket好像有问题暂时用http协议
                    user.nickname=nickname;
                    user.photo = photo;
                    user.currentHouseIeee = house_ieee;
                    user.houseName = housename;
                    user.userName = username;
                    user.houseArr = @[@{@"name":housename,@"house_ieee":house_ieee,@"status":houseStatus,@"cloud_server_ip":user.serverIp ? user.serverIp : @"",@"cloud_server_port":[NSString stringWithFormat:@"%d",user.serverPort],@"msg_server_ip":user.msgIp ? user.msgIp : @"",@"msg_server_port":[NSString stringWithFormat:@"%d",user.msgPort]}];
                    user.isAutoLogin = YES;
                    //刷新本地存储
                    [NetvoxUserInfo updateLocalData];
                    
                    NetvoxDb *db = [NetvoxDb shareInstance] ;
                    db = [db initNetvoxDb];
                    
                    
                    
                    
                    //成功了连接callback
                    [[NetvoxSocketManager shareInstance] socketConnectCallbackSocketCompletionHandler:^(NSDictionary *validateResult) {
                        
                        
                    }];
                    
                }
                
                result(aResult);
                
                
                
            }];
        });
        
        
        
        
    }else{
        [NetvoxNetwork loginFromCloudWithTag:tag CompletionHandler:^(NSDictionary *aResult) {
            if ([aResult[@"status_code"] intValue] != 0) {
                result(aResult);
            }
            else
            {
                //外网登陆成功
                NSDictionary *resultDic = aResult[@"result"];
                NSString *username =resultDic[@"user"];
                NSString *nickname = resultDic[@"nickname"];
                NSString *photo = resultDic[@"photo"];
                user.userName = username;
                user.nickname = nickname;
                user.photo = photo;
                user.isAutoLogin = YES;
                
                NetvoxDb *db = [NetvoxDb shareInstance] ;
                db = [db initNetvoxDb];
                
                
                
                //刷新本地存储
                [NetvoxUserInfo updateLocalData];
                result(aResult);
                
            }
        }];
    }
    
    
    /*
    [NetvoxNetwork loginFromCloudWithTag:tag CompletionHandler:^(NSDictionary *aResult) {
        //如果网络没问题，走外网，网络有问题，走内网登陆
        if ([aResult[@"status_code"] intValue] != -404) {
            if ([aResult[@"status_code"] intValue] != 0) {
                result(aResult);
            }
            else
            {
                //外网登陆成功
                NSDictionary *resultDic = aResult[@"result"];
                NSString *username =resultDic[@"user"];
                NSString *nickname = resultDic[@"nickname"];
                NSString *photo = resultDic[@"photo"];
                user.userName = username;
                user.nickname = nickname;
                user.photo = photo;
                user.isAutoLogin = YES;
                
                NetvoxDb *db = [NetvoxDb shareInstance] ;
                db = [db initNetvoxDb];
                
                
                
                //刷新本地存储
                [NetvoxUserInfo updateLocalData];
                result(aResult);
                
            }
        }
        else
        {
            //内网登陆
            user.netConnect = connectTypeLocal;
            
            NSString *str=[NSString stringWithFormat:@"{\"op\":\"login\",\"user\":\"%@\",\"pwd\":\"%@\"}",user.userName,[NetvoxCommon md5:user.pwd]];
            NSString *url =[NSString stringWithFormat:@"/smarthome/user.cgi?"];
            
            NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
            model.networkType = netvoxNetworkTypeCGI;
            model.user = user;
            model.type = 0x1000002;
            model.url = url;
            model.param = str;

            dispatch_async(dispatch_get_global_queue(0, 0), ^{
      
                //发送登陆请求
                [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
                    if ([aResult[@"status_code"] intValue]==0) {
                        NSDictionary *resDic = aResult[@"result"];
                        NSString *nickname = resDic[@"nickname"];
                        NSString *photo = resDic[@"photo"];
                        NSString *house_ieee = resDic[@"house_ieee"];
                        NSString *housename = resDic[@"housename"];
                        NSString *username = resDic[@"user"];
                        NSString *houseStatus = @"online";  //网关在线
//                        user.isLocalSocketRes = YES;      //我们网管的socket好像有问题暂时用http协议
                        user.nickname=nickname;
                        user.photo = photo;
                        user.currentHouseIeee = house_ieee;
                        user.houseName = housename;
                        user.userName = username;
                        user.houseArr = @[@{@"name":housename,@"house_ieee":house_ieee,@"status":houseStatus,@"cloud_server_ip":user.serverIp ? user.serverIp : @"",@"cloud_server_port":[NSString stringWithFormat:@"%d",user.serverPort],@"msg_server_ip":user.msgIp ? user.msgIp : @"",@"msg_server_port":[NSString stringWithFormat:@"%d",user.msgPort]}];
                        user.isAutoLogin = YES;
                        //刷新本地存储
                        [NetvoxUserInfo updateLocalData];
                        
                        NetvoxDb *db = [NetvoxDb shareInstance] ;
                        db = [db initNetvoxDb];
                        
                      
                        
                        
                        //成功了连接callback
                        [[NetvoxSocketManager shareInstance] socketConnectCallbackSocketCompletionHandler:^(NSDictionary *validateResult) {
                            
                            
                        }];
                        
                    }
                    
                    result(aResult);
                    
                    
                    
                }];
            });

            
            
        }
    }];
    */
    
   
    
    
  
    
    
}



//退出登录
+(void)logout
{
    [[NetvoxSocketManager shareInstance] cutOffSocket];
    [[NetvoxMqtt shareInstance] disconnect];
    [NetvoxNetwork logoutFromCloudCompletionHandler:nil];
}

//踢出
+(void)kickOut
{
    [[NetvoxSocketManager shareInstance] cutOffSocket];
    [[NetvoxMqtt shareInstance] disconnect];
}

//获取用户列表
+(void)getUserListCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/user.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000002;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
   

}
//获取用户信息
+(void)getUserInfoCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"find\",\"user\":\"%@\"}",user.userName];
    NSString *url =[NSString stringWithFormat:@"/smarthome/user.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000002;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        NSNumber *status_code = aResult[@"status_code"];
        if (status_code.intValue == 0) {
            NSDictionary *resDic = aResult[@"result"];
            user.phone = resDic[@"phone"];
            //刷新本地存储
            [NetvoxUserInfo updateLocalData];
        }
        
        result(aResult);
    }];
    
    
}

//添加用户(数组参数元素全部为NSString类型.permissionRoomIds:有权限的房间的roomid数组;denyRoomIds:无权限的房间的roomid数组;permissionModules:有权限的模式名称数组;denyModules:无权限的模式名称数组)
+(void)addUserWithUser:(NSString *)userName pwd:(NSString *)pwd phone:(NSString *)phone permissionRoomIds:(NSArray *)permissionRoomIds denyRoomIds:(NSArray *)denyRoomIds permissionModules:(NSArray *)permissionModules denyModules:(NSArray *)denyModules CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //组装房间权限
    NSMutableString *permission = [[NSMutableString alloc]initWithFormat:@"{\"room\":["];
    for (NSString *roomId in permissionRoomIds) {
        [permission appendString:@"{"];
        [permission appendFormat:@"\"id\":\"%@\",\"perm\":\"allow\"",roomId];
        [permission appendString:@"},"];
       
    }
    
    for (NSString *roomId in denyRoomIds) {
        [permission appendString:@"{"];
        [permission appendFormat:@"\"id\":\"%@\",\"perm\":\"deny\"",roomId];
        [permission appendString:@"},"];
    }
    
    if ([[permission substringFromIndex:permission.length-1] isEqualToString:@","]) {
        [permission replaceCharactersInRange:NSMakeRange(permission.length-1, 1) withString:@"]"];
    }
    else
    {
        [permission appendString:@"]"];
    }
     [permission appendString:@","];
    
    //组装模式权限
    [permission appendString:@"\"module\":["];
    for (NSString *module in permissionModules) {
        [permission appendString:@"{"];
        [permission appendFormat:@"\"name\":\"%@\",\"perm\":\"allow\"",module];
        [permission appendString:@"},"];
        
    }
    
    for (NSString *module in denyModules) {
        [permission appendString:@"{"];
        [permission appendFormat:@"\"name\":\"%@\",\"perm\":\"deny\"",module];
        [permission appendString:@"},"];
    }
    
    if ([[permission substringFromIndex:permission.length-1] isEqualToString:@","]) {
        [permission replaceCharactersInRange:NSMakeRange(permission.length-1, 1) withString:@"]"];
    }
    else
    {
        [permission appendString:@"]"];
    }
    [permission appendString:@"}"];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"add\",\"user\":\"%@\",\"pwd\":\"%@\",\"phone\":\"%@\",\"permission\":%@}",userName,pwd,phone,permission];
    NSString *url =[NSString stringWithFormat:@"/smarthome/user.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000002;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//更新用户
+(void)updateUserInfoWithUser:(NSString *)userName pwd:(NSString *)pwd phone:(NSString *)phone nickname:(NSString *)nickname photo:(NSString *)photo CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    //可选参数pwd
    NSString *fPwd= !pwd ? @"" : [NSString stringWithFormat:@",\"pwd\":\"%@\"",pwd];
    //可选参数phone
    NSString *fPhone= !phone ? @"" : [NSString stringWithFormat:@",\"phone\":\"%@\"",phone];
    //可选参数nickname
    NSString *fnickname= !nickname ? @"" : [NSString stringWithFormat:@",\"nickname\":\"%@\"",nickname];
    //可选参数photo
    NSString *fphoto= !photo ? @"" : [NSString stringWithFormat:@",\"photo\":\"%@\"",photo];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"update\",\"user\":\"%@\"%@%@%@%@}",user.userName,fPwd,fPhone,fnickname,fphoto];
    NSString *url =[NSString stringWithFormat:@"/smarthome/user.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000002;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        int status_code = [aResult[@"status_code"] intValue];
        if (status_code == 0) {
            //成功 更新模型
            if (pwd) {
                user.pwd = pwd;
            }
            
            if (phone) {
                user.phone = phone;
            }
            
            if (nickname) {
                user.nickname = nickname;
            }
            
            [NetvoxUserInfo updateLocalData];
        }
        
        result(aResult);
    }];
    
}

//删除用户
+(void)deleteUserWithUser:(NSString *)userName CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"delete\",\"user\":\"%@\"}",userName];
    NSString *url =[NSString stringWithFormat:@"/smarthome/user.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000002;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//从云端刷新用户列表
+(void)refreshUserListCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list_refresh\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/user.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000002;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

#pragma mark-- 网关接口:规则操作
//执行规则
+(void)executeWithId:(int)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"execute\",\"id\":\"%d\"}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/rule.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000003;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取规则
+(void)getRuleListWithType:(NSString *)type CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //可选参数type
    NSString *fType= !type ? @"" : [NSString stringWithFormat:@",\"type\":\"%@\"",type];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list\"%@}",fType];
    NSString *url =[NSString stringWithFormat:@"/smarthome/rule.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000003;
    model.url = url;
    model.param = str;
    
    ////判断是否是Ipv6 假数据
    if ([NetvoxCommon isIpv6] && [user.userName isEqualToString: houseAndUserName]) {
        
        result(@{
                 @"seq": @"IPv6模式",
                 @"status_code":@(0),
                 @"result":@[
                         ]
                 });
        return;
    }
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//启用禁用规则
+(void)enableRuleWithId:(int)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"enable\",\"id\":%d}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/rule.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000003;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];


}

//下载规则文件
+(void)downloadRuleCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"download_rulefile\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/rule.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000003;
    model.url = url;
    model.param = str;
    
    
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
     
        
        //新建文件夹
        NSString *doc = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"];
        NSString * path = [doc stringByAppendingPathComponent:@"Rule"];
//        NSLog(@"%@",path);
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:path])
        {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        //解压
        if([[aResult objectForKey:@"status_code"] intValue] != 0)
        {
            //删除本地残留文件并返回结果
            [NetvoxCommon deleteFileWithName:@"Rule"];
            result(aResult);
        }
        else
        {
            NSData * preTar = [NetvoxCommon convertHexStrToData:[aResult objectForKey:@"result"]];
            [NetvoxCommon tarDecompress:preTar Path:path];
        
        
            //解密rule文件
            NSString * ruleStr = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"rule.xml"]] encoding:NSUTF8StringEncoding];
            NSString * ruleContent = ruleStr;
            if(![ruleStr containsString:@"xml version"])  //加密文件才要解密
            {
                NSString *str = [NSString stringWithContentsOfFile:[path stringByAppendingPathComponent:@"rule.xml"] encoding:NSISOLatin1StringEncoding error:nil];
                NSData *file = [str dataUsingEncoding:NSISOLatin1StringEncoding];
                [NetvoxCommon xorDecode:file andIntoPath:[path stringByAppendingPathComponent:@"rule.xml"]];
                ruleContent = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"rule.xml"]] encoding:NSUTF8StringEncoding];
            }
            
            //解密data文件
            NSString * dataStr = [[NSString alloc]initWithData:[NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"data.xml"]] encoding:NSUTF8StringEncoding];
            NSString * dataContent = dataStr;
            if(![dataStr containsString:@"xml version"])  //加密文件才要解密
            {
                NSString *str = [NSString stringWithContentsOfFile:[path stringByAppendingPathComponent:@"data.xml"] encoding:NSISOLatin1StringEncoding error:nil];
                NSData *file = [str dataUsingEncoding:NSISOLatin1StringEncoding];
                [NetvoxCommon xorDecode:file andIntoPath:[path stringByAppendingPathComponent:@"data.xml"]];
                dataContent = [[NSString alloc]initWithData:[NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:@"data.xml"]] encoding:NSUTF8StringEncoding];
            }
            
            
            
            
            
            //拼接返回
            NSString * ruleAndData = [NSString stringWithFormat:@"%@<WITH>%@",ruleContent,dataContent];
            result(@{@"seq":@"下载规则文件",@"status_code":@0,@"result":ruleAndData});
            
            //删除本地残留文件并返回结果
            [NetvoxCommon deleteFileWithName:@"Rule"];
        }
    }];

}


//上传规则文件
+(void)uploadRuleWithString:(NSString *)xmlStr CompletionHandler:(void (^)(NSDictionary *result))result
{
    
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"upload_rulefile\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/rule.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGIUpload;
    model.user = user;
    model.type = 0x1000003;
    model.url = url;
    model.param = str;
    
    //新建文件夹
    NSString *doc = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"];
    NSString * path = [doc stringByAppendingPathComponent:@"updata"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSArray * ruleAndData = [xmlStr componentsSeparatedByString:@"<WITH>"];
    if(ruleAndData.count>0)
    {
        NSString * strTemp = ruleAndData[0];
        strTemp = [strTemp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        strTemp = [strTemp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        strTemp = [strTemp stringByReplacingOccurrencesOfString:@">" withString:@">\n"];
        NSData * rule = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        [fileManager createFileAtPath:[path stringByAppendingPathComponent:@"rule.xml"] contents:rule attributes:nil];
    }
    if(ruleAndData.count>1)
    {
        NSData * data = [(NSString *)ruleAndData[1] dataUsingEncoding:NSUTF8StringEncoding];
        //写入
        [fileManager createFileAtPath:[path stringByAppendingPathComponent:@"data.xml"] contents:data attributes:nil];
    }
    
    //打包
    [NetvoxCommon tarCompress:path Topath:[doc stringByAppendingPathComponent:@"updata.tar"]];
    
    //上传
    NSData * tempData = [NSData dataWithContentsOfFile:[doc stringByAppendingPathComponent:@"updata.tar"]];
    model.file = [NetvoxCommon convertNSDataToNSString:tempData];
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
    //删除缓存文件
    [NetvoxCommon deleteFileWithName:@"updata"];
    [NetvoxCommon deleteFileWithName:@"updata.tar"];
    
}






#pragma mark-- 网关接口:房间操作

//获取房间列表
+(void)getRoomList:(BOOL)cache CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"list\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/room.cgi?"];
    
    
    
    int count =0;
    if (cache) {
        //查询缓存中是否有
         count =[NetvoxDb queryCount:TABLE_ROOM addArr:nil orArr:nil];
        if (count!=0) {
            result([NetvoxNetwork getLocalRoomList:@"1234"]);
        }
    }
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000004;
    model.url = url;
    model.param = str;
    

    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        //判断是否是ipv6 假数据
        if ([NetvoxCommon isIpv6] && [user.userName isEqualToString: houseAndUserName]) {
            
            NSDictionary * dic = [NetvoxNetwork backDicForIpv6:@"" andaResult:aResult andRequest:@"room"];
            result(dic);
            return;
        }
        
        
        if([aResult[@"status_code"] intValue] ==0)
        {
            [NetvoxDb update:TABLE_ROOM data:aResult];
        }
        //        if (!cache || count == 0) {
        result(aResult);
        //        }

    }];

   
    
    
}


//添加房间(注:该接口去除房间图片上传,dev_id数组值都为NSString类型)
+(void)addRoomWithName:(NSString *)name dev_id:(NSArray *)dev_id CompletionHandler:(void (^)(NSDictionary *result))result
{
   
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSMutableString *fdev_id = [[NSMutableString alloc]init];
    
    if (dev_id && dev_id.count!=0) {
        [fdev_id appendString:@",\"dev_id\":["];
        
        for (NSString *str in dev_id) {
            
            [fdev_id appendFormat:@"\"%@\",",str];
        }
        
        if ([[fdev_id substringFromIndex:fdev_id.length-1] isEqualToString:@","]) {
            [fdev_id replaceCharactersInRange:NSMakeRange(fdev_id.length-1, 1) withString:@"]"];
        }
        else
        {
            [fdev_id appendString:@"]"];
        }

    }
    
    
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"add\",\"name\":\"%@\"%@}",name,fdev_id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/room.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000004;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//修改房间(注:该接口去除房间图片上传,dev_id数组值都为NSString类型)
+(void)updateRoomInfoWithId:(int)Id name:(NSString *)name dev_id:(NSArray *)dev_id rule_id:(NSArray*)rule_id  CompletionHandler:(void (^)(NSDictionary *result))result
{

    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    //可选参数name
    NSString *fname= !name ? @"" : [NSString stringWithFormat:@",\"name\":\"%@\"",name];
    
    NSMutableString *fdev_id = [[NSMutableString alloc]init];
    
//    if (dev_id && dev_id.count!=0) {
        [fdev_id appendString:@",\"dev_id\":["];
        
        for (NSString *str in dev_id) {
            
            [fdev_id appendFormat:@"\"%@\",",str];
        }
        
        if ([[fdev_id substringFromIndex:fdev_id.length-1] isEqualToString:@","]) {
            [fdev_id replaceCharactersInRange:NSMakeRange(fdev_id.length-1, 1) withString:@"]"];
        }
        else
        {
            [fdev_id appendString:@"]"];
        }
 
//    }

    NSMutableString *frule_id = [[NSMutableString alloc]init];
//    if (rule_id && rule_id.count!=0) {
        [frule_id appendString:@",\"rule_id\":["];
        
        for (NSString *str in rule_id) {
            
            [frule_id appendFormat:@"\"%@\",",str];
        }
        
        if ([[frule_id substringFromIndex:frule_id.length-1] isEqualToString:@","]) {
            [frule_id replaceCharactersInRange:NSMakeRange(frule_id.length-1, 1) withString:@"]"];
        }
        else
        {
            [frule_id appendString:@"]"];
        }
        
//    }
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"update\",\"id\":%d%@%@%@}",Id,fname,fdev_id,frule_id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/room.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000004;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];


}

//删除房间
+(void)deleteRoomWithId:(int)Id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"delete\",\"id\":%d}",Id];
    NSString *url =[NSString stringWithFormat:@"/smarthome/room.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000004;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];


}

#pragma mark-- 网关接口:系统操作
//获取系统配置信息
+(void)getConfigCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *str=@"{\"op\":\"get_config\"}";
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设置系统配置信息
+(void)setConfigWithez_appkey:(NSString *)ez_appkey ez_secret:(NSString *)ez_secret CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    int originRequestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;  //这个时间比较长
    //萤石appkey和appsecret
    NSString * appkey = !ez_appkey ? @"" : [NSString stringWithFormat:@",\"ez_appkey\":\"%@\"",ez_appkey];
    NSString * secret = !ez_secret ? @"" : [NSString stringWithFormat:@",\"ez_secret\":\"%@\"",ez_secret];
    
    NSMutableString *config = [[NSMutableString alloc] initWithFormat:@"%@%@",appkey,secret];
    
    if ([config hasPrefix:@","]) {
        [config deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_config\",\"config\":{%@}}",config];
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = originRequestTime;
        result(aResult);
    }];
}

//设置系统配置信息
+(void)setConfigWithHouseName:(NSString *)houseName encryptKey:(NSString *)encryptKey wifiPwd:(NSString *)wifiPwd wifiName:(NSString *)wifiName wifiPwdEncrypt:(NSString *)wifiPwdEncrypt hwVersion:(NSString *)hwVersion manageServer:(NSString *)manageServer timestampEnable:(int)timestampEnable timestampAviableTime:(int)timestampAviableTime callbackAuth:(int)callbackAuth filterDev:(int)filterDev driver_mode:(int)driver_mode zbchannel:(int)zbchannel ez_appkey:(NSString *)ez_appkey ez_secret:(NSString *)ez_secret CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    int originRequestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;  //这个时间比较长
    //可选参数houseName
    NSString *fHouseName= !houseName ? @"" : [NSString stringWithFormat:@",\"housename\":\"%@\"",houseName];
    //可选参数encryptKey
    NSString *fEncryptKey= !encryptKey ? @"" : [NSString stringWithFormat:@",\"encrypt_key\":\"%@\"",encryptKey];
    //可选参数wifiPwd
    NSString *fWifiPwd= !wifiPwd ? @"" : [NSString stringWithFormat:@",\"wifi_pwd\":\"%@\"",wifiPwd];
    //可选参数wifiName
    NSString *fWifiName= !wifiName ? @"" : [NSString stringWithFormat:@",\"wifi_name\":\"%@\"",wifiName];
    //可选参数wifiPwdEncrypt
    NSString *fWifiPwdEncrypt= !wifiPwdEncrypt ? @"" : [NSString stringWithFormat:@",\"wifi_pwd_encrypt\":\"%@\"",wifiPwdEncrypt];
    
    //可选参数hwVersion
    NSString *fhwVersion= !hwVersion ? @"" : [NSString stringWithFormat:@",\"hw_version\":\"%@\"",hwVersion];
    
    //可选参数manageServer
    NSString *fmanageServer= !manageServer ? @"" : [NSString stringWithFormat:@",\"manage_server\":\"%@\"",manageServer];
    
    //可选参数timestampEnable
    NSString *ftimestampEnable= (timestampEnable == -1) ? @"" : [NSString stringWithFormat:@",\"timestamp_enable\":%d",timestampEnable];
    
    //可选参数timestampAviableTime
    NSString *ftimestampAviableTime= (timestampAviableTime == -1) ? @"" : [NSString stringWithFormat:@",\"timestamp_aviable_time\":%d",timestampAviableTime];

    
    //可选参数callbackAuth
    NSString *fcallbackAuth= (callbackAuth == -1) ? @"" : [NSString stringWithFormat:@",\"callback_auth\":%d",callbackAuth];

    
    //可选参数filter
    NSString *ffilterDev= (filterDev == -1) ? @"" : [NSString stringWithFormat:@",\"filter_dev\":%d",filterDev];
    
    NSString *fdriver_mode= (driver_mode == -1) ? @"" : [NSString stringWithFormat:@",\"driver_mode\":%d",driver_mode];
    
    NSString *fzbchannel= (zbchannel == -1) ? @"" : [NSString stringWithFormat:@",\"zbchannel\":%d",zbchannel];

    
    //萤石appkey和appsecret
    NSString * appkey = !ez_appkey ? @"" : [NSString stringWithFormat:@",\"ez_appkey\":\"%@\"",ez_appkey];
    NSString * secret = !ez_secret ? @"" : [NSString stringWithFormat:@",\"ez_secret\":\"%@\"",ez_secret];
    
    NSMutableString *config = [[NSMutableString alloc] initWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",fHouseName,fEncryptKey,fWifiPwd,fWifiName,fWifiPwdEncrypt,fhwVersion,fmanageServer,ftimestampEnable,ftimestampAviableTime,fcallbackAuth,ffilterDev,fdriver_mode,fzbchannel,appkey,secret];
    
    if ([config hasPrefix:@","]) {
        [config deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_config\",\"config\":{%@}}",config];
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = originRequestTime;
        result(aResult);
    }];
    

}



//文本命令控制
+(void)commandControlWithText:(NSString *)command CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString * text = command;
    if([NetvoxCommon includeChinese:command] == YES)
    {
        for(int i=0; i< [command length];i++)
        {
            int a =[command characterAtIndex:i];
            if( a >0x4e00&& a <0x9fff){
                NSString *temp = [NSString stringWithFormat:@"%d",[command characterAtIndex:i]];
                NSString * tempUTF8 = [temp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                text = [text stringByReplacingOccurrencesOfString:temp withString:tempUTF8];
            }
        }

//        NSLog(@"%@", text);
    }
 
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"text_command\",\"text\":\"%@\"}",text];
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取当地环境指数
+(void)getWeatherCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_weather\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//打包为出厂模式
+(void)factoryPackCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"factory_pack\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//IEEE合法性检查
+(void)IEEECheckCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"ieee_check\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/integrity.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//设备完整性检查
+(void)deviceCheckCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"device_check\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/integrity.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//设备绑定组完整性检查
+(void)bindGroupCheckCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"bind_group_check\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/integrity.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//设备间绑定完整性检查
+(void)bindCheckCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"bind_check\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/integrity.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//设备组完整性检查
+(void)groupCheckCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"group_check\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/integrity.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//设备登记检查
+(void)enrollCheckCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"enroll_check\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/integrity.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//一键处理
+(void)onekeyHandleWithOption:(BOOL)isBindGroup CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString * option = isBindGroup ? @"bind_group":@"group";
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"onekey_handle\",\"option\":\"%@\"}",option];
    NSString *url =[NSString stringWithFormat:@"/smarthome/integrity.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取网关信息
+(void)getGatewayInfoCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_info\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        NSNumber *status_code = aResult[@"status_code"];
        if (status_code.intValue == 0) {
            NSDictionary *resDic = aResult[@"result"];
            user.currentHouseIeee = resDic[@"ieee"];
            //刷新本地存储
            [NetvoxUserInfo updateLocalData];
        }
        
        result(aResult);

    }];
    
    
}

//修改网关无线模式
+(void)setGatewayAirwireModeCompletionHandler:(void (^)(NSDictionary *result))result
{
   
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"set_airwire_mode\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//恢复出厂设置
+(void)factoryResetCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"factory_reset\"}"];
    NSString *url =[NSString stringWithFormat:@"/smarthome/system.cgi?"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeCGI;
    model.user = user;
    model.type = 0x1000005;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

#pragma mark--云端接口

#pragma mark--云端接口:设备相关
//获取设备列表
/***
 house_ieee : 网关IEEE 为空的话就是用户下所有家庭的
 roomid : 房间id Roomid=-1 全部设备 Roomid=0 家全局的设备 Roomid=1 房间ID为1的设备
 pagenum : 页码
 pagesize : 每页大小
 */
+ (void)getListWithHouseieee:(NSString *)house_ieee andRoomid:(int)roomid andPagenum:(int)pagenum andPagesize:(int)pagesize CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];

    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/device.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list\",\"house_ieee\":\"%@\",\"roomid\":%d,,\"pagenum\":%d,\"pagesize\":%d}",house_ieee,roomid,pagenum,pagesize];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
//获取设备支持的属性
/***
 dev_id : 设备uid
 */
+ (void)getListDevattrWithDevid:(NSString *)dev_id CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/device.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_devattr\",\"id\":\"%@\"}",dev_id];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取设备操作历史 （可选参数 dev_id、houseIeee ）
+(void)getDeviceRecordFromCloudWithHouseIeee:(NSString *)houseIeee dev_id:(NSString *)dev_id pagenum:(int)pagenum pagesize:(int)pagesize CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];

    //可选参数dev_id
    NSString *fdev_id = !dev_id ? @"" : [NSString stringWithFormat:@",\"dev_id\":\"%@\"",dev_id];
    //可选参数houseIeee
    NSString *fhouseIeee = !houseIeee ? user.currentHouseIeee : houseIeee;

    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/device.do",user.header,user.proxyIp,user.proxyPort];
    

    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_op_record\",\"house_ieee\":\"%@\",\"pagenum\":%d,\"pagesize\":%d%@}",fhouseIeee,pagenum,pagesize,fdev_id];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

    
    
//获取设备图标类型
+(void)getIconTypeFromCloudWithuDeviceId:(NSString *)udeviceId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
 
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/device.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_device_icon_type\",\"udeviceid\":\"%@\"}",udeviceId];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取设备图标 suffix传入字符串 "_ON" 或者 "_OFF" 代表开启动,关闭图标，用宏表示
+(NSString *)getIconUrlFromCloudWithIcon_name:(NSString *)iconName andSuffix:(NSString *)suffix
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"download_device_icon\",\"icon_name\":\"%@%@\"}",iconName,suffix];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    
    NSString *timestamp=[NetvoxCommon getMs];
    NSString *seq = [NetvoxCommon getUuid];
    NSString *param =  [NSString stringWithFormat:@"data=%@&seq=%@&timestamp=%@&user=%@",model.param,seq,timestamp,model.user.userName];
    NSString *sign = model.isNotEncrypt ? @"AAA": [NetvoxCommon md5:[NSString stringWithFormat:@"%@&%@",param,model.user.pwd]];
    
   
    NSString *iconUrl = [[NSString stringWithFormat:@"%@?%@&sign=%@",model.url,param,sign] stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8];
    
    
    return iconUrl;
    
}

//上传预置点图片
+(void)uploadPressPicFromCloudWithImgData:(NSData *)imgData andDevID:(NSString *)devId andPicName:(NSString *)picName progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/device.do",user.header,user.proxyIp,user.proxyPort];
    int originRequestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"upload_prepoint_pic\",\"dev_id\":\"%@\",\"name\":\"%@\"}",devId,picName];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeUpload;
    model.user = user;
    model.url = url;
    
    [model.formDataArray removeAllObjects];
    [model.formDataArray addObject:imgData];
    model.progress = progress;
    [model.fileNameArray removeAllObjects];
    [model.fileNameArray addObject:@"file"];
    [model.mimeTypeArray removeAllObjects];
    [model.mimeTypeArray addObject:@"image/png"];
    
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = originRequestTime;
        result(aResult);
    }];
    
}


//获取预置点图片（云端）
+(NSString *)getPressPicFromCloudWithDevId:(NSString *)dev_id andPressName:(NSString *)pressName
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"download_prepoint_pic\",\"dev_id\":\"%@\",\"name\":\"%@\"}",dev_id,pressName];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    
    NSString *timestamp=[NetvoxCommon getMs];
    NSString *seq = [NetvoxCommon getUuid];
    NSString *param =  [NSString stringWithFormat:@"data=%@&seq=%@&timestamp=%@&user=%@",model.param,seq,timestamp,model.user.userName];
    NSString *sign = model.isNotEncrypt ? @"AAA": [NetvoxCommon md5:[NSString stringWithFormat:@"%@&%@",param,model.user.pwd]];
    
    
    NSString *iconUrl = [[NSString stringWithFormat:@"%@?%@&sign=%@",model.url,param,sign] stringByAddingPercentEscapesUsingEncoding:kCFStringEncodingUTF8];
    
    
    return iconUrl;
    
}

//删除预置点图片(云端)
+(void)deletePressPicFromCloudWithDevId:(NSString *)dev_id andPressName:(NSString *)pressName CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"del_prepoint_pic\",\"dev_id\":\"%@\",\"name\":\"%@\"}",dev_id,pressName];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}


//获取485设备
+(void)get485DeviceFromCloud:(NSString *)cmd CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_485device\",\"cmd_type\":\"%@\"}",cmd];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取485设备指令
+(void)get485CommandFromCloudWithDevId:(NSString *)z485Dev_Id CloudCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_485command\",\"z485_dev_id\":\"%@\"}",z485Dev_Id];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取485虚拟设备
+(void)get485VirtualDeviceFromCloudWithDevId:(NSString *)dev_Id CloudCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_485virtualdev\",\"dev_id\":\"%@\"}",dev_Id];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取IR设备
+(void)getIRDeviceFromCloudCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_irdevice\"}"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取IR品牌列表 type:-1=全部、0=AC空调、1=TV=、2=TVBox电视机顶盒、3=DVD、4=Projector投影仪、5=其他
+(void)getIRBrandListFromCloudWithType:(NSString *)type BrandName:(NSString *)brandName CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_irbrand\",\"irdevice\":\"%@\",\"brand_name\":\"%@\"}",type,brandName];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取IR型号列表 type:-1=全部、0=AC空调、1=TV=、2=TVBox电视机顶盒、3=DVD、4=Projector投影仪、5=其他
+(void)getIRTypeFromCloudWithBrandId:(NSString *)brandId Type:(NSString *)type CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_irmodel\",\"brandid\":\"%@\",\"irdevice\":\"%@\"}",brandId,type];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取IR品牌型号
+(void)getIRBrandOrTypeFromCloudWithBrandOrType:(NSString *)brandOrType CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_brandmodel\",\"name\":\"%@\"}",brandOrType];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取IR开机数据 type:-1=全部、0=AC空调、1=TV=、2=TVBox电视机顶盒、3=DVD、4=Projector投影仪、5=其他
+(void)getIRPowerOnDataFromCloudWithBrandId:(NSString *)brandId ModelId:(NSString *)modelId Type:(NSString *)type CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_poweron_data\",\"brandid\":\"%@\",\"modelid\":\"%@\",\"irdevice\":\"%@\"}",brandId,modelId,type];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取IR匹配数据 type:-1=全部、0=AC空调、1=TV=、2=TVBox电视机顶盒、3=DVD、4=Projector投影仪、5=其他
+(void)getIRMatchDataFromCloudWithType:(NSString *)type IRData:(NSString *)irData HouseIEEE:(NSString *)houseIeee CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_irmatch\"},{\"irdevice\":\"%@\",\"irdata\":\"%@\",\"house_ieee\":\"%@\"}",type,irData,houseIeee];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取IR数据文件
+(void)getIRDataFromCloudWithBrandId:(NSString *)brandId ModelId:(NSString *)modelId CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/virtual_device.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"get_irxml\",\"brandid\":\"%@\",\"modelid\":\"%@\"}",brandId,modelId];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

    
//添加Lora设备
+(void)addDeviceWithLora:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/lora.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"add_device\",\"devid\":\"%@\"}",devid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
    
    
//第三方注册
+(void)registerBySocialFromCloudWithUser:(NSString *)userName Pwd:(NSString *)pwd
                           andnickName:(NSString *)nickName andRegcode:(NSString *) regcode andOpenId:(NSString *)openid andAccessToken:(NSString *)accessToken andPlatFrom:(NSString *)platfrom CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"tp_reg\",\"user\":\"%@\",\"pwd\":\"%@\",\"nickname\":\"%@\",\"regcode\":\"%@\",\"openid\":\"%@\",\"access_token\":\"%@\",\"platform\":\"%@\"}",userName,pwd,nickName,regcode,openid,accessToken,platfrom];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//第三方登录
+(void)loginBySocialFromCloudWithOpenId:(NSString *)openid andAccessToken:(NSString *)accessToken andPlatFrom:(NSString *)platfrom CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"tp_login\",\"openid\":\"%@\",\"access_token\":\"%@\",\"platform\":\"%@\"}",openid,accessToken,platfrom];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//第三方用户绑定
+(void)bindToSocialFromCloudWithUser:(NSString *)userName OpenId:(NSString *)openid andAccessToken:(NSString *)accessToken andPlatFrom:(NSString *)platfrom andBindCode:(NSString *)bindcode CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"tp_bind_user\",\"user\":\"%@\",\"openid\":\"%@\",\"access_token\":\"%@\",\"platform\":\"%@\",\"bind_code\":\"%@\"}",userName,openid,accessToken,platfrom,bindcode];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//分享家,生成简化内容
+ (void)shareHouseBriefContentWithDetail:(NSString *)detail CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"brief_content\",\"detail\":\"%@\"}",detail];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//分享家,获取化简的内容
+ (void)getShareHouseDetailContentWithBrief:(NSString *)brief CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"detail_content\",\"brief\":\"%@\"}",brief];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

#pragma mark--云端接口:电能统计

//获取电能统计数据(startTime,endTime传入格式:YYYY-MM-DD,例如:2017-01-01)
+(void)getEnergyStatFromCloudWithHouseIeee:(NSString *)houseIeee startTime:(NSString *)startTime endTime:(NSString *)endTime catalog:(NSString *)catalog CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/house.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"energy_stat\",\"house_ieee\":\"%@\",\"start_time\":\"%@\",\"end_time\":\"%@\",\"catalog\":\"%@\"}",houseIeee,startTime,endTime,catalog];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取电能详细数据(startTime,endTime传入格式:YYYY-MM-DD,例如:2017-01-01)
+(void)getEnergyDetailsFromCloudWithHouseIeee:(NSString *)houseIeee startTime:(NSString *)startTime endTime:(NSString *)endTime catalog:(NSString *)catalog CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/house.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"energy_details\",\"house_ieee\":\"%@\",\"start_time\":\"%@\",\"end_time\":\"%@\",\"catalog\":\"%@\"}",houseIeee,startTime,endTime,catalog];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取设备数据表 devid:设备id=uid attr_name:设备属性(temperature/humidity/ph...)  time_type:(day/month/year) time:(day:2018-05-01,month:2018-05,year:2018)
+(void)getAttrReportWithHouseIeee:(NSString *)houseIeee devid:(NSString *)devid attr_name:(NSString *)attr_name time_type:(NSString *)time_type time:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/statistics.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"attr_report\",\"house_ieee\":\"%@\",\"devid\":\"%@\",\"attr_name\":\"%@\",\"time_type\":\"%@\",\"time\":\"%@\"}",houseIeee,devid,attr_name,time_type,time];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
//    model.networkType = netvoxNetworkTypeHttpPost;
    model.networkType = netvoxNetworkTypeHttpGet;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    //请求时间至少需要17s以上
    int requestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = requestTime;
        
        if ([aResult[@"status_code"] intValue] !=0) {
            result(aResult);
        }else{
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1];
            NSMutableDictionary * results = [NSMutableDictionary dictionaryWithCapacity:1];
            [results setDictionary:aResult[@"result"]];
            [results setValue:time forKey:@"request_time"];
            [dic setValue:results forKey:@"result"];
            [dic setValue:aResult[@"seq"] forKey:@"seq"];
            [dic setValue:aResult[@"status_code"] forKey:@"status_code"];
            [NetvoxDb update:TABLE_REPORT data:dic];
//            NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"Netvox"];
//            NSLog(@"path=%@",path);
            result([NetvoxNetwork getReportWithHouseIeee:houseIeee time:time seq:aResult[@"seq"]]);
        }
        
        
        
        
    }];
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取设备报表[批量] devids:[设备id=uid]数组 attr_name:设备属性(temperature/humidity/ph...)  time_type:(day/month/year/range) time:(day:2018-05-01,month:2018-05,year:2018,range:2018-05-01,2018-05-02)
+(void)getAttrReportBatchWithDevids:(NSArray *)devids andAttr_name:(NSString *)attr_name andTime_type:(NSString *)time_type andTime:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/statistics.do",user.header,user.proxyIp,user.proxyPort];
    
    NSMutableString * devString = [NSMutableString string];
    
    [devString appendString:@",\"devids\":["];
    
    for (NSString *str in devids) {
        
        [devString appendFormat:@"\"%@\",",str];
    }
    
    
    if ([[devString substringFromIndex:devString.length-1] isEqualToString:@","]) {
        [devString replaceCharactersInRange:NSMakeRange(devString.length-1, 1) withString:@"]"];
    }
    else
    {
        [devString appendString:@"]"];
    }
    
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"attr_report_batch\"%@,\"attr_name\":\"%@\",\"time_type\":\"%@\",\"time\":\"%@\"}",devString,attr_name,time_type,time];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    //    model.networkType = netvoxNetworkTypeHttpPost;
    model.networkType = netvoxNetworkTypeHttpGet;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    //请求时间至少需要17s以上
    int requestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = requestTime;
        result(aResult);
        /*
        if ([aResult[@"status_code"] intValue] !=0) {
            result(aResult);
        }else{
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1];
            NSMutableDictionary * results = [NSMutableDictionary dictionaryWithCapacity:1];
            [results setDictionary:aResult[@"result"]];
            [results setValue:time forKey:@"request_time"];
            [dic setValue:results forKey:@"result"];
            [dic setValue:aResult[@"seq"] forKey:@"seq"];
            [dic setValue:aResult[@"status_code"] forKey:@"status_code"];
            [NetvoxDb update:TABLE_REPORT data:dic];
            //            NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"Netvox"];
            //            NSLog(@"path=%@",path);
            result([NetvoxNetwork getReportWithHouseIeee:user.currentHouseIeee time:time seq:aResult[@"seq"]]);
        }
        */
        
        
        
    }];
}

//电能数据报表 devs:数组 [{dev_id :设备id , attr:电能属性名称(energy,a_energy,b_energy,c_energy)}] time_type:(day/month/year) time:(day:2018-05-01,month:2018-05,year:2018)
+(void)getEnergyReportWithHouseIeee:(NSString *)houseIeee devs:(NSArray *)devs time_type:(NSString *)time_type time:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/statistics.do",user.header,user.proxyIp,user.proxyPort];
    
    NSMutableString * devString = [NSMutableString string];
    for (NSDictionary * devDic in devs) {
        [devString appendString:[NSString stringWithFormat:@"{\"dev_id\":\"%@\",\"attr\":\"%@\"},",devDic[@"dev_id"],devDic[@"attr"]]];
    }
    if ([[devString substringFromIndex:devString.length-1] isEqualToString:@","]) {
        [devString replaceCharactersInRange:NSMakeRange(devString.length-1, 1) withString:@"]"];
    }
    else
    {
        [devString appendString:@"]"];
    }
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"energy_report\",\"house_ieee\":\"%@\",\"devs\":[%@,\"time_type\":\"%@\",\"time\":\"%@\"}",houseIeee,devString,time_type,time];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    //请求时间至少需要17s以上
    int requestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = requestTime;
        
        if ([aResult[@"status_code"] intValue] !=0) {
            result(aResult);
        }else{
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1];
            NSMutableDictionary * results = [NSMutableDictionary dictionaryWithCapacity:1];
            [results setDictionary:aResult[@"result"]];
            [results setValue:time forKey:@"request_time"];
            [dic setValue:results forKey:@"result"];
            [dic setValue:aResult[@"seq"] forKey:@"seq"];
            [dic setValue:aResult[@"status_code"] forKey:@"status_code"];
            [NetvoxDb update:TABLE_REPORT data:dic];
            //            NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"Netvox"];
            //            NSLog(@"path=%@",path);
            result([NetvoxNetwork getReportWithHouseIeee:houseIeee time:time seq:aResult[@"seq"]]);
        }
    }];
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//电能数据详情表 devs:数组 [dev_id :设备id , attr:电能属性名称(energy,a_energy,b_energy,c_energy)] time_type:(day/month/year) time:(day:2018-05-01,month:2018-05,year:2018)
+(void)getEnergyDetailReportWithHouseIeee:(NSString *)houseIeee devs:(NSArray *)devs time_type:(NSString *)time_type time:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/statistics.do",user.header,user.proxyIp,user.proxyPort];
    
    NSMutableString * devString = [NSMutableString string];
    for (NSDictionary * devDic in devs) {
        [devString appendString:[NSString stringWithFormat:@"{\"dev_id\":\"%@\",\"attr\":\"%@\"},",devDic[@"dev_id"],devDic[@"attr"]]];
    }
    if ([[devString substringFromIndex:devString.length-1] isEqualToString:@","]) {
        [devString replaceCharactersInRange:NSMakeRange(devString.length-1, 1) withString:@"]"];
    }
    else
    {
        [devString appendString:@"]"];
    }
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"energy_detail_report\",\"house_ieee\":\"%@\",\"devs\":[%@,\"time_type\":\"%@\",\"time\":\"%@\"}",houseIeee,devString,time_type,time];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    //请求时间至少需要17s以上
    int requestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = requestTime;
        
        if ([aResult[@"status_code"] intValue] !=0) {
            result(aResult);
        }else{
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1];
            NSMutableDictionary * results = [NSMutableDictionary dictionaryWithCapacity:1];
            [results setDictionary:aResult[@"result"]];
            [results setValue:time forKey:@"request_time"];
            [dic setValue:results forKey:@"result"];
            [dic setValue:aResult[@"seq"] forKey:@"seq"];
            [dic setValue:aResult[@"status_code"] forKey:@"status_code"];
            [NetvoxDb update:TABLE_REPORT data:dic];
            //            NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"Netvox"];
            //            NSLog(@"path=%@",path);
            result([NetvoxNetwork getReportWithHouseIeee:houseIeee time:time seq:aResult[@"seq"]]);
        }
    }];
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}



#pragma mark--云端接口:告警相关
//获取告警信息(startTime,endTime传入格式:YYYY-MM-DD,例如:2017-01-01)
+(void)getWarnMsgFromCloudWithHouseIeee:(NSString *)houseIeee startTime:(NSString *)startTime endTime:(NSString *)endTime pagenum:(int)pagenum pagesize:(int)pagesize CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/warnmsg.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list\",\"house_ieee\":\"%@\",\"start_time\":\"%@\",\"end_time\":\"%@\",\"pagenum\":%d,\"pagesize\":%d}",houseIeee,startTime,endTime,pagenum,pagesize];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        result(aResult);
        if ([aResult[@"status_code"] intValue] == 0) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
            NSMutableArray * listAry = aResult[@"result"];
            for (int i = 0; i<listAry.count; i++) {
                 dic = [NSMutableDictionary dictionaryWithDictionary:listAry[i]];
                [dic setValue:user.userName forKey:@"user"];
                [dic setValue:dic[@"desc"] forKey:@"msg"];
                [NetvoxDb insert:TABLE_MSG data:dic];
            }
            
            
        }
        
    }];

}

//删除告警消息(startTime,endTime传入格式:YYYY-MM-DD,例如:2017-01-01)
+(void)deleteWarnMsgFromCloudWithHouseIeee:(NSString *)houseIeee startTime:(NSString *)startTime endTime:(NSString *)endTime CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
   
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/warnmsg.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"del\",\"house_ieee\":\"%@\",\"stime\":\"%@\",\"etime\":\"%@\"}",houseIeee,startTime,endTime];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

#pragma mark--云端接口:用户相关
//添加网关
+(void)addShcFromCloudWithHouseIeee:(NSString *)houseIeee name:(NSString *)name Lng:(float)lng Lat:(float)lat Address:(NSString *)address andAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"add_shc\",\"house_ieee\":\"%@\",\"name\":\"%@\",\"lng\":%.2f,\"lat\":%.2f,\"address\":\"%@\",\"appid\":\"%@\"}",houseIeee,name,lng,lat,address,appid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
//  [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
         result(aResult);
         if ([aResult[@"status_code"] intValue] == 0) {
             NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
             
             NSDictionary *dic = aResult[@"result"];
             NSString *name = dic[@"name"];
             NSString *house_ieee = dic[@"house_ieee"];
//             NSString *houseStatus = dic[@"status"];
             NSString *cloud_server_ip = dic[@"cloud_server_ip"];
             int cloud_server_port = [dic[@"cloud_server_port"] intValue];
             NSString *msg_server_ip = dic[@"msg_server_ip"];
             int msg_server_port = [dic[@"msg_server_port"] intValue];
             
             
             
            
             
             //houseArray 添加元素
             NSMutableArray *tempHouseArr = [NSMutableArray arrayWithArray:user.houseArr];
             //@"status":houseStatus,
             [tempHouseArr addObject:@{@"name":name,@"house_ieee":house_ieee,@"cloud_server_ip":cloud_server_ip,@"cloud_server_port":[NSString stringWithFormat:@"%d",cloud_server_port],@"msg_server_ip":msg_server_ip,@"msg_server_port":[NSString stringWithFormat:@"%d",msg_server_port]}];
             user.houseArr = [NSArray arrayWithArray:tempHouseArr];
             
             [NetvoxUserInfo updateLocalData];
            
             
             //之前没网关，更新一下user模型和plist，并连接mqtt
             if(user.houseArr.count == 1)
             {
                 user.currentHouseIeee = house_ieee;
                 user.houseName = name;
                 [self connectToHouse:user.currentHouseIeee CompletionHandler:^(NSDictionary *bresult) {
                     NSString *status_code = bresult[@"status_code"];
                     if([status_code intValue] == 88888)
                     {
                         NSLog(@"添加网关后MQTT连接成功，当前家%@",user.currentHouseIeee);
                     }
                     else
                     {
                         NSLog(@"添加网关后MQTT连接失败");
                     }
                 }];
                 
             }
            
         }
       
    }];

}

//登录云端
+(void)loginFromCloudWithTag:(NSString *)tag CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"login\",\"user\":\"%@\",\"pwd\":\"%@\",\"os\":\"%@\",\"token\":\"%@\",\"tag\":\"%@\"}",user.userName,user.pwd,@"ios",user.token,tag];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        if ([NetvoxCommon isIpv6] && [user.userName isEqualToString: houseAndUserName]) {
            /*
             ["status_code": 0, "result": {
             nickname = test;
             photo = "";
             user = "214976189@qq.com";
             }, "seq": 2D8E5B24-9CA9-4286-A044-263CFEA64967]
             */
            result([NetvoxNetwork backDicForIpv6:nil andaResult:aResult andRequest:@"login"]);
        }
        else{
            result(aResult);
        }
    }];
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//用户退出云端
+(void)logoutFromCloudCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"logout\"}"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

//添加用户(网关请求)
+(void)addUserFromCloudWithUser:(NSString *)userName pwd:(NSString *)pwd CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"add\",\"user\":\"%@\",\"pwd\":\"%@\"}",user,pwd];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

////修改用户(users 数组的元素为字典,字典的key有user,pwd,nickname,其中nickname为可选参数)(网关请求)
//+(void)updateUserFromCloudWithHouseIeee:(NSString *)houseIeee users:(NSArray *)users CompletionHandler:(void (^)(NSDictionary *result))result
//{
//    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
//    
//    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.serverIp,user.serverPort];
//    
//    
//    
//    //参数users
//    NSMutableString *fusers = [[NSMutableString alloc]init];
//    
//   
//        [fusers appendString:@"{,\"users\":["];
//    if (users && users.count !=0) {
//        for (NSDictionary *dic in users) {
//            NSString *auser = dic[@"user"];
//            NSString *pwd = dic[@"pwd"];
//            NSString *nickname = dic[@"nickname"];
//            //可选参数nickname
//            NSString *fnickname= !nickname ? @"" : [NSString stringWithFormat:@",\"nickname\":\"%@\"",nickname];
//            
//            [fusers appendFormat:@"{\"user\":\"%@\",\"pwd\":\"%@\"%@},",auser,pwd,fnickname];
//        }
//        
//        [fusers replaceCharactersInRange:NSMakeRange(fusers.length-1, 1) withString:@"]"];
//    }
//    else
//    {
//        [fusers appendString:@"]"];
//    }
//    
//    
//
//    
//    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"update\",\"house_ieee\":\"%@\"%@}",houseIeee,fusers];
//    
//    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
//    model.networkType = netvoxNetworkTypeHttpPost;
//    model.user = user;
//    model.url = url;
//    model.param = dataStr;
//    
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
//
//}

//删除用户(users 数组的元素为字典,字典的key有user)(网关请求)
//+(void)deleteUsersFromCloudWithHouseIeee:(NSString *)houseIeee users:(NSArray *)users CompletionHandler:(void (^)(NSDictionary *result))result
//{
//    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
//    
//    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.serverIp,user.serverPort];
//    
//    
//    
//    //参数users
//    NSMutableString *fusers = [[NSMutableString alloc]init];
//    
//    
//    [fusers appendString:@"{,\"users\":["];
//    if (users && users.count !=0) {
//        for (NSDictionary *dic in users) {
//            NSString *auser = dic[@"user"];
//            [fusers appendFormat:@"{\"user\":\"%@\"},",auser];
//        }
//        
//        [fusers replaceCharactersInRange:NSMakeRange(fusers.length-1, 1) withString:@"]"];
//    }
//    else
//    {
//        [fusers appendString:@"]"];
//    }
//    
//    
//    
//    
//    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"delete\",\"house_ieee\":\"%@\"%@}",houseIeee,fusers];
//    
//    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
//    model.networkType = netvoxNetworkTypeHttpPost;
//    model.user = user;
//    model.url = url;
//    model.param = dataStr;
//    
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
//
//}

//上传用户头像
+(void)uploadPhotoFromCloudWithImgData:(NSData *)imgData progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    int originRequestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;

    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"upload_photo\"}"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeUpload;
    model.user = user;
    model.url = url;
    
    [model.formDataArray removeAllObjects];
    [model.formDataArray addObject:imgData];
    model.progress = progress;
    [model.fileNameArray removeAllObjects];
    [model.fileNameArray addObject:@"file"];
    [model.mimeTypeArray removeAllObjects];
    [model.mimeTypeArray addObject:@"image/png"];
    model.param = dataStr;
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = originRequestTime;
        NSString *status_code = aResult[@"status_code"];
        if([status_code intValue] == 0)
        {
            NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
            NSDictionary *dic = aResult[@"result"];
            user.photo = dic[@"photo"];
            
        }
        result(aResult);
    }];
    
  
}

//获取用户信息（云端）
+(void)getUserMsgFromCloudCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"detail\",\"user\":\"%@\"}",user.userName];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取用户注册短信验证码
+(void)getRegcodeFromCloudWithMobile:(NSString *)mobile verifyType:(int)type andLang:(NSString *)lang CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
   
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"get_verify_code\",\"mobile\":\"%@\",\"verify_code_type\":\"%d\",\"lang\":\"%@\"}",mobile,type,lang];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//用户注册
+(void)regFromCloudWithUser:(NSString *)userName pwd:(NSString *)pwd nickname:(NSString *)nickname recode:(NSString *)regcode CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
     user.userName = userName;
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"reg\",\"user\":\"%@\",\"pwd\":\"%@\",\"nickname\":\"%@\",\"regcode\":\"%@\"}",userName,pwd,nickname,regcode];
    
    //该接口不加密
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.isNotEncrypt = YES;
    model.param = dataStr;
    
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        if ([aResult[@"status_code"] intValue] ==0) {
            //更新plist
            NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
            user.userName = userName;
            user.pwd = pwd;
            user.nickname = nickname;
            user.houseArr = @[];
            user.currentHouseIeee = @"";
            user.msgIp = @"";
            [NetvoxUserInfo updateLocalData];    
        }
        result(aResult);
    }];

}


//查询用户是否注册
+(void)checkUserIsRegistFromCloudWithUser:(NSString *)userName CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"check_phone_reg\",\"user\":\"%@\"}",userName];
    
    
    //该接口不加密
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.isNotEncrypt = YES;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//意见反馈  content文字内容 ext版本信息，无版本信息传"" ImageDataArr图片NSData数组
+(void)suggestionFromCloudWithContent:(NSString *)content ImageDataArr:(NSArray *)imageDateArr Ext:(NSString *)ext progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"commit_suggestion\",\"username\":\"%@\",\"house_ieee\":\"%@\",\"content\":\"%@\",\"ext\":\"%@\"}",user.userName,user.currentHouseIeee,content,ext];
    
    int originRequestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    
    
    //该接口不加密
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeUpload;
    model.user = user;
    model.url = url;
    
    [model.formDataArray removeAllObjects];
    [model.fileNameArray removeAllObjects];
    [model.mimeTypeArray removeAllObjects];
    
    for (int i = 0; i < imageDateArr.count; i++) {
        [model.formDataArray addObject:imageDateArr[i]];
        NSString * paramName = [NSString stringWithFormat:@"pic%d",i+1];
        [model.fileNameArray addObject:paramName];
        [model.mimeTypeArray addObject:@"image/png"];
    }
    
    model.progress = progress;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = originRequestTime;
        result(aResult);
    }];
    
    
    
    
    
    

}

//用户找回密码
+(void)resetPwdFromCloudWithUser:(NSString *)userName newPwd:(NSString *)newPwd verifycode:(NSString *)verifycode CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"reset_pwd\",\"user\":\"%@\",\"new_pwd\":\"%@\",\"verify_code\":\"%@\"}",userName,newPwd,verifycode];
    
    
    //该接口不加密
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.isNotEncrypt = YES;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}


//获取所有的家 pagesize 每页大小，不传查询所有  pagenum页码，不传查询所有
+(void)getHouseListWithUser:(NSString *)userName pagenum:(NSNumber *)pagenum pagesize:(NSNumber *)pagesize Cache:(BOOL) cache CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_house\",\"user\":\"%@\",\"pagenum\":\"%@\",\"pagesize\":\"%@\"}",userName,pagenum,pagesize];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    //无网络
    if(user.netConnect == connectTypeNone)
    {
        [dic setObject:@"no net" forKey:@"seq"];
        [dic setObject:@(1) forKey:@"status_code"];
        [dic setObject:@"no net" forKey:@"result"];
        result(dic);
    }
    //wifi(内网）
    else if(user.netConnect == connectTypeLocal)
    {
        [dic setObject:@"wifi（内网）" forKey:@"seq"];
        [dic setObject:@(0) forKey:@"status_code"];
        user.houseArr = @[@{@"name":user.houseName,@"house_ieee":user.currentHouseIeee,@"status":@"online",@"cloud_server_ip":user.serverIp ? user.serverIp : @"",@"cloud_server_port":[NSString stringWithFormat:@"%d",user.serverPort],@"msg_server_ip":user.msgIp ? user.msgIp : @"",@"msg_server_port":[NSString stringWithFormat:@"%d",user.msgPort],@"lat":@"",@"lng":@"",@"energy_report_day":@"1"}]; //内网就一个houseIeee
        [dic setObject:user.houseArr forKey:@"result"];
        result(dic);
    }
    //外网
    else
    {
        //判断是否是Ipv6 由于没有适配，所以制造假数据
        if ([NetvoxCommon isIpv6] && [user.userName isEqualToString: houseAndUserName]) {
            dic = [[NetvoxNetwork backDicForIpv6:@"" andaResult:@{@"seq":@"IPV6环境返回",@"status_code":@(0)} andRequest:@"house"] mutableCopy];
            user.houseArr = dic[@"result"];
            user.houseName = @"上海的家";
            user.currentHouseIeee = @"00137A0000010136";
            result(dic);
            return;
        }
        
        
        //读缓存
        if(cache == YES)
        {
            if(user.houseArr.count > 0)
            {
                [dic setObject:@"外网读取缓存所有家" forKey:@"seq"];
                [dic setObject:@(0) forKey:@"status_code"];
                [dic setObject:user.houseArr forKey:@"result"];
                result(dic);
            }
            else
            {
                [NetvoxNetwork getHouseListFromCloudWithModel:model CompletionHandler:^(NSDictionary *cResult) {
                    result(cResult);
                }];
            }
        }
        //请求
        else
        {
           [NetvoxNetwork getHouseListFromCloudWithModel:model CompletionHandler:^(NSDictionary *cResult) {
               result(cResult);
           }];
        }

    }
}
//发送获取所有家请求并连接mqtt （云端）
+(void)getHouseListFromCloudWithModel:(NetvoxNetworkModel *)model CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        NSString * status_code = [aResult objectForKey:@"status_code"];
        //请求失败
        if([status_code intValue] != 0)
        {
            user.houseArr = [NSArray new];
            [NetvoxUserInfo updateLocalData];
            result(aResult);
        }
        //请求成功
        else
        {
            [user remHouseInfo:aResult];
            if(user.houseArr.count == 0)
            {
                user.houseName = @"";
                user.currentHouseIeee = @"";
                user.msgIp = @"";
                result(aResult);
                return;
            }
            [NetvoxNetwork connectMqttCompletionHandler:^(NSDictionary *validateResult) {
                
                //mqtt未连上
                if([[validateResult objectForKey:@"status_code"] intValue] != 88888)
                {
                    user.houseArr = [NSArray new];
                    [NetvoxUserInfo updateLocalData];
                    result(validateResult);
                }
                //mqtt连上
                else
                {
                    result(aResult);
                }
            }];
            
            
        }
        
    }];
}

//修改用户信息
+(void)modifyUserInfoFromCloudWithNickname:(NSString *)nickname andPwd:(NSString *)pwd CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    //可选参数nickname
    NSString *fnickname = !nickname ? @"":[NSString stringWithFormat:@",\"nickname\":\"%@\"",nickname];
    NSString *fpwd = !pwd ? @"":[NSString stringWithFormat:@",\"pwd\":\"%@\"",pwd];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/user.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"update\",\"user\":\"%@\"%@%@}",user.userName,fnickname,fpwd];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        
        NSString *status_code = aResult[@"status_code"];
        if([status_code intValue] == 0)
        {
            NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
          
            if(nickname != nil)
            {
                user.nickname = nickname;
            }
            if(pwd != nil)
            {
                user.pwd = pwd;
            }
 
            
        }
        result(aResult);
    }];

}

#pragma mark -- 云端接口:分享相关
//共享家庭 andDevices:(NSArray *)devicesWithHouseIeeeAry andFunctions:(NSArray *)functionsWiControl
//共享家庭 permission 权限 devices 数组 和 functions 数组  0无权限，1所有权限 例如 所有权限 @{@"devices":@["0"],@"functions":@["1"]}  appid: 应用版id  不是应用版可以传空""
+(void)shareHouseFromCloudWithHouseIeee:(NSString *)houseIeee andInitiator:(NSString *)srcUser andPermission:(NSDictionary *)permission andAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/house.do",user.header,user.proxyIp,user.proxyPort];
    
    
    NSString * pemissions = @"";
    
    NSMutableString * devices = [[NSMutableString alloc]init];
    NSMutableString * functions = [[NSMutableString alloc]init];
    
    if (permission && [permission isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"%@",permission[@"devices"]);
        NSLog(@"%@",permission[@"functions"]);
        if (permission[@"devices"] && [permission[@"devices"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary * device = permission[@"devices"];
            NSLog(@"%@",device);
            for (NSString * key in device) {
                NSLog(@"device字典key == %@",key);
                NSLog(@"device字典value == %@",device[key]);
                [devices appendString:[NSString stringWithFormat:@"\"%@\"",key]];
                [devices appendString:@":"];
                [devices appendFormat:@"%@",device[key]];
                [devices appendString:@","];
            }
        }
        
        if (permission[@"functions"] && [permission[@"functions"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary * function = permission[@"functions"];
            NSLog(@"%@",function);
            for (NSString * key in function) {
                NSLog(@"function字典key == %@",key);
                NSLog(@"function字典value == %@",function[key]);
                [functions appendString:[NSString stringWithFormat:@"\"%@\"",key]];
                [functions appendString:@":"];
                [functions appendFormat:@"%@",function[key]];
                [functions appendString:@","];
            }
            
        }
        
            if ([[devices substringFromIndex:devices.length-1] isEqualToString:@","]) {
                [devices replaceCharactersInRange:NSMakeRange(devices.length-1, 1) withString:@""];
            }
            if ([[functions substringFromIndex:functions.length-1] isEqualToString:@","]) {
                [functions replaceCharactersInRange:NSMakeRange(functions.length-1, 1) withString:@""];
            }
            pemissions = [NSString stringWithFormat:@",\"permission\":{\"devices\":{%@},\"functions\":{%@}}",devices,functions];
        
    }

    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"share_house\",\"house_ieee\":\"%@\",\"src_user\":\"%@\"%@,\"appid\":\"%@\"}",houseIeee,srcUser,pemissions,appid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
//    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        result(aResult);
        if ([aResult[@"status_code"] intValue] == 0)
        {
            if ([appid isEqual: @""]) {
                NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
                
                NSDictionary *dic = aResult[@"result"];
                NSString *name = dic[@"name"];
                NSString *house_ieee = dic[@"house_ieee"];
                NSString *houseStatus = dic[@"status"];
                NSString *cloud_server_ip = dic[@"cloud_server_ip"];
                int cloud_server_port = [dic[@"cloud_server_port"] intValue];
                NSString *msg_server_ip = dic[@"msg_server_ip"];
                int msg_server_port = [dic[@"msg_server_port"] intValue];
                NSDictionary * permission = dic[@"permission"];
                //houseArray 添加元素
                NSMutableArray *tempHouseArr = [NSMutableArray arrayWithArray:user.houseArr];
                [tempHouseArr addObject:@{@"name":name,@"house_ieee":house_ieee,@"status":houseStatus,@"cloud_server_ip":cloud_server_ip,@"cloud_server_port":[NSString stringWithFormat:@"%d",cloud_server_port],@"msg_server_ip":msg_server_ip,@"msg_server_port":[NSString stringWithFormat:@"%d",msg_server_port],@"permission":permission}];
                user.houseArr = [NSArray arrayWithArray:tempHouseArr];
                
                [NetvoxUserInfo updateLocalData];
                
                //之前没网关，更新一下user模型和plist，并连接mqtt
                if(user.houseArr.count == 1)
                {
                    user.currentHouseIeee = house_ieee;
                    user.houseName = name;
                    [self connectToHouse:user.currentHouseIeee CompletionHandler:^(NSDictionary *bresult) {
                        NSString *status_code = bresult[@"status_code"];
                        if([status_code intValue] == 88888)
                        {
                            NSLog(@"添加网关后MQTT连接成功，当前家%@",user.currentHouseIeee);
                        }
                        else
                        {
                            NSLog(@"添加网关后MQTT连接失败");
                        }
                    }];
                }
            }
            else{
                //应用版可能解析不同,现在这样的写法是错误的需要修改
                NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
                
                
                NSDictionary *dic = aResult[@"result"];
                NSString *name = dic[@"name"];
                NSString *house_ieee = dic[@"house_ieee"];
                NSString *houseStatus = dic[@"status"];
                NSString *cloud_server_ip = dic[@"cloud_server_ip"];
                int cloud_server_port = [dic[@"cloud_server_port"] intValue];
                NSString *msg_server_ip = dic[@"msg_server_ip"];
                int msg_server_port = [dic[@"msg_server_port"] intValue];
                NSDictionary * permission = dic[@"permission"];
                //houseArray 添加元素
                NSMutableArray *tempHouseArr = [NSMutableArray arrayWithCapacity:1];
                NSMutableArray * houseAry = [NSMutableArray arrayWithArray:user.applicationHouseArr];
                for (int i = 0; i<user.applicationHouseArr.count; i++) {
                    NSDictionary * hosDic = user.applicationHouseArr[i];
                    if ([hosDic [@"appid"] isEqualToString:appid])
                    {
                        [tempHouseArr addObjectsFromArray:hosDic[@"houses"]];
                        [tempHouseArr addObject:@{@"name":name,@"house_ieee":house_ieee,@"status":houseStatus,@"cloud_server_ip":cloud_server_ip,@"cloud_server_port":[NSString stringWithFormat:@"%d",cloud_server_port],@"msg_server_ip":msg_server_ip,@"msg_server_port":[NSString stringWithFormat:@"%d",msg_server_port],@"permission":permission}];
                        [houseAry replaceObjectAtIndex:i withObject:tempHouseArr];
                        break;
                    }
                    
                }
                
                
                user.applicationHouseArr = [NSArray arrayWithArray:houseAry];
                
                [NetvoxUserInfo updateLocalData];
                
                //之前没网关，更新一下user模型和plist，并连接mqtt
                if(user.applicationHouseArr.count == 1)
                {
                    user.currentHouseIeee = house_ieee;
                    user.houseName = name;
                    [self connectToHouse:user.currentHouseIeee CompletionHandler:^(NSDictionary *bresult) {
                        NSString *status_code = bresult[@"status_code"];
                        if([status_code intValue] == 88888)
                        {
                            NSLog(@"添加网关后MQTT连接成功，当前家%@",user.currentHouseIeee);
                        }
                        else
                        {
                            NSLog(@"添加网关后MQTT连接失败");
                        }
                    }];
                }
            }
        }
        
    }];


}

//删除分享家庭
+(void)deleteShareHouseFromCloudWithHouseIeee:(NSString *)houseIeee andShareUser:(NSString *)shareUser CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/house.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"del_share_house\",\"house_ieee\":\"%@\",\"share_user\":\"%@\"}",houseIeee,shareUser];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    typeof (self) weakSelf = self;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        //成功后切换当前网关
        if ([aResult[@"status_code"] intValue] == 0){
            
            [weakSelf reChoiseHouseIeeeFromHouseArrayWithDeleteHouse:houseIeee];
        }
        result(aResult);
    }];
    
    
    

}

//获取分享记录
+(void)getShareRecordFromCloudWithPagenum:(int)pagenum pagesize:(int)pagesize houseIeee:(NSString *) houseIeee CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/house.do",user.header,user.proxyIp,user.proxyPort];
    NSString *fhouseIeee = !houseIeee ? user.currentHouseIeee : houseIeee;
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_share_record\",\"pagenum\":%d,\"pagesize\":%d,\"house_ieee\":\"%@\"}",pagenum,pagesize,fhouseIeee];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//转让
+(void)transferHouseFromCloudWithHouseIeee:(NSString *)houseIeee target_user:(NSString *)target_user CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/house.do",user.header,user.proxyIp,user.proxyPort];
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"transfer_house\",\"target_user\":\"%@\",\"house_ieee\":\"%@\"}",target_user,houseIeee];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    typeof (self) weakSelf = self;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        if ([aResult[@"status_code"] intValue] == 0){
            
            [weakSelf reChoiseHouseIeeeFromHouseArrayWithDeleteHouse:houseIeee];
        }
        result(aResult);
    }];
}


//获取房间信息
+(void)getRoomlistWithHouseieee:(NSString *)houseIeee CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/house.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *str=[NSString stringWithFormat:@"{\"op\":\"get_roomlist\",\"house_ieee\":\"%@\"}",houseIeee];
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = str;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    
}


#pragma mark-- 云端接口: 应用 相关
//获取用户应用
+(void)getListApplicationCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];

    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/homepage.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_application\"}"];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        NSString * status_code = [aResult objectForKey:@"status_code"];
        //请求失败
        if([status_code intValue] != 0)
        {
            user.applicationHouseArr = [NSArray new];
            [NetvoxUserInfo updateLocalData];
            result(aResult);
        }
        //请求成功
        else
        {
            [user remApplicationHouse:aResult];
            if(user.applicationHouseArr.count == 0)
            {
                user.houseName = @"";
                user.currentHouseIeee = @"";
                user.msgIp = @"";
                result(aResult);
                return;
            }
            [NetvoxNetwork connectMqttCompletionHandler:^(NSDictionary *validateResult) {
                
                //mqtt未连上
                if([[validateResult objectForKey:@"status_code"] intValue] != 88888)
                {
                    user.applicationHouseArr = [NSArray new];
                    [NetvoxUserInfo updateLocalData];
                    result(validateResult);
                }
                //mqtt连上
                else
                {
                    result(aResult);
                }
            }];
            
            
        }
    }];
    
}

//修改用户应用
/**
 appid : 应用id(-1表示新增)
 name : 应用名称
 houses : 应用的家(不传则不更新)
 modules : 应用的模块(不传则不更新)
 
 */
+(void)updateApplicationWithAppid:(NSString *)appid andName:(NSString *)name andHouses:(NSArray *)houses andModules:(NSArray *)modules CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/homepage.do",user.header,user.proxyIp,user.proxyPort];
    
    NSMutableString * housestr = [[NSMutableString alloc]init];
    
    NSMutableString * modulestr = [[NSMutableString alloc]init];
    
    [housestr appendString:@",\"houses\":["];
    if (houses.count > 0)
    {
        for (NSString *str in houses) {
            
            [housestr appendFormat:@"\"%@\",",str];
        }
        
        if ([[housestr substringFromIndex:housestr.length-1] isEqualToString:@","]) {
            [housestr replaceCharactersInRange:NSMakeRange(housestr.length-1, 1) withString:@"]"];
        }
        else
        {
            [housestr appendString:@"]"];
        }
    }
    else{
        [housestr appendString:@"]"];
    }
    
    
    
    [housestr appendString:@",\"modules\":["];
    if (modules.count > 0) {
        for (NSString *str in modules) {
            
            [modulestr appendFormat:@"\"%@\",",str];
        }
        
        if ([[modulestr substringFromIndex:modulestr.length-1] isEqualToString:@","]) {
            [modulestr replaceCharactersInRange:NSMakeRange(modulestr.length-1, 1) withString:@"]"];
        }
        else
        {
            [modulestr appendString:@"]"];
        }
    }
    else{
        [modulestr appendString:@"]"];
    }
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"update_application\",\"appid\":\"%@\",\"name\":\"%@\"%@%@}",appid,name,housestr,modulestr];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//删除用户应用
/**
 appid : 应用id
 
 */
+(void)delApplicationWithAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/homepage.do",user.header,user.proxyIp,user.proxyPort];
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"del_application\",\"appid\":\"%@\"}",appid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//切换应用
/**
 appid : 切换到那个应用的appid
 houseieee : 切换到应用需要连接的家
 
 */
+ (void)changeApplicationWithAppid:(NSString *)appid andHouseieee:(NSString *)houseieee CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo * user = [NetvoxUserInfo shareInstance];
    
    for (NSDictionary * dic in user.applicationHouseArr) {
        
        NSString * apid = dic[@"appid"];
        
        user.appHouses = dic[@"houses"];
        NSString *appname = dic[@"name"];
        NSArray *modules = dic[@"modules"];
        NSNumber * flag = dic[@"flag"];
        NSNumber * hasLora = dic[@"has_lora"];
        
        if ([apid isEqualToString:appid])
        {
            if (user.appHouses.count > 0) {
                NSDictionary * houseDic = user.appHouses.firstObject;
                
                NSString *house_ieee = houseDic[@"house_ieee"];
                user.currentHouseIeee = house_ieee;
                user.appName = appname;
                user.appModules = modules;
                user.appFlag = [NSString stringWithFormat:@"%@",flag];
                user.appHas_lora = hasLora;
                user.appid = [NSString stringWithFormat:@"%@",apid];
                [NetvoxNetwork connectToHouse:user.currentHouseIeee CompletionHandler:^(NSDictionary *aResult) {
                    result(aResult);
                }];
                [NetvoxUserInfo updateLocalData];
                break;
            }
            else{
                
                user.appName = appname;
                user.appModules = modules;
                user.appFlag = [NSString stringWithFormat:@"%@",flag];
                user.appHas_lora = hasLora;
                user.appid = [NSString stringWithFormat:@"%@",apid];
                [NetvoxUserInfo updateLocalData];
                result(@{@"seq":@"1234",@"status_code":@8888,@"result":@"切换应用,但是无网关"});
                break;
            }
        }
        
    }
}


//获取网关信息应用版
/**
 appid : 应用id
 */
+(void)getListHouseApplicationWithAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/homepage.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_house\",\"appid\":\"%@\"}",appid];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取数据汇总设备列表
/**
 appid : 应用id
 house_ieee : 网关ieee，不传该字段表示全部网关
 moduleid : 模快的id
 
 */
+(void)getListDatapanelDevicesWithAppid:(NSString *)appid andHouseieee:(NSString *)house_ieee  andModuleid:(NSString *)moduleid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/homepage.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_datapanel_devices\",\"appid\":\"%@\",\"house_ieee\":\"%@\",\"moduleid\":\"%@\"}",appid,house_ieee,moduleid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//新增数据汇总设备
/**
 appid : 应用id
 moduleid : 模快的id
 devid : 设备id
 */
+(void)addDatapanelDeviceApplicationWithAppid:(NSString *)appid andModuleid:(NSString *)moduleid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/homepage.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"add_datapanel_device\",\"appid\":\"%@\",\"moduleid\":\"%@\",\"devid\":\"%@\"}",appid,moduleid,devid];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//删除数据汇总设备
/**
 appid : 应用id
 moduleid : 模快的id
 devid : 设备id
 */
+(void)delDatapanelDeviceApplicationWithAppid:(NSString *)appid andModuleid:(NSString *)moduleid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/homepage.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"del_datapanel_device\",\"appid\":\"%@\",\"moduleid\":\"%@\",\"devid\":\"%@\"}",appid,moduleid,devid];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

#pragma mark-- 定位相关的接口

//获取区域列表
/**
 appid : 应用id
 
 */
+(void)getListLocationAreaWithAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/location.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_location_area\",\"appid\":\"%@\"}",appid];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//新增区域
/**
 areaid : 区域id(-1表示服务器生成id,其他值表示直接使用客户端上传的id)
 appid : 应用id
 name : 名称
 imgData : 上传的图片 转成jpg格式
 */
+(void)addLocationAreaWithImgData:(NSData *)imgData andAreaid:(NSString *)areaid andAppid:(NSString *)appid andName:(NSString *)name progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/location.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"add_location_area\",\"appid\":\"%@\",\"id\":\"%@\",\"name\":\"%@\"}",appid,areaid,name];
    
    int originRequestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    
    model.user = user;
    model.url = url;
    
    if (imgData != nil) {
        model.networkType = netvoxNetworkTypeUpload;
        [model.formDataArray removeAllObjects];
        [model.formDataArray addObject:imgData];
        model.progress = progress;
        [model.fileNameArray removeAllObjects];
        [model.fileNameArray addObject:@"file"];
        [model.mimeTypeArray removeAllObjects];
        [model.mimeTypeArray addObject:@"image/jpg"];
        
    }
    else{
        model.networkType = netvoxNetworkTypeHttpPost;
    }

    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = originRequestTime;
        result(aResult);
    }];
    
}

//修改区域
/**
 areaid : 区域id(-1表示服务器生成id,其他值表示直接使用客户端上传的id)
 appid : 应用id
 name : 名称
 imgData : 上传的图片 转成jpg格式
 */
+(void)updateLocationAreaWithWithImgData:(NSData *)imgData andAreaid:(NSString *)areaid andAppid:(NSString *)appid andName:(NSString *)name progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/location.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"update_location_area\",\"appid\":\"%@\",\"id\":\"%@\",\"name\":\"%@\"}",appid,areaid,name];
    
    
    int originRequestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
   
    model.user = user;
    model.url = url;
    
    if (imgData != nil) {
        model.networkType = netvoxNetworkTypeUpload;
        [model.formDataArray removeAllObjects];
        [model.formDataArray addObject:imgData];
        model.progress = progress;
        [model.fileNameArray removeAllObjects];
        [model.fileNameArray addObject:@"file"];
        [model.mimeTypeArray removeAllObjects];
        [model.mimeTypeArray addObject:@"image/jpg"];
        
    }
    else{
        model.networkType = netvoxNetworkTypeHttpPost;
    }
    
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = originRequestTime;
        result(aResult);
    }];
}

//删除区域
/**
 areaid : 区域id(-1表示服务器生成id,其他值表示直接使用客户端上传的id)
 appid : 应用id
 name : 名称
 */
+(void)delLocationAreaWithareaid:(NSString *)areaid andAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/location.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"del_location_area\",\"appid\":\"%@\",\"id\":\"%@\"}",appid,areaid];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//获取定位设备列表
/**
 appid : 应用id
 category : 类别(1=移动设备，2=坐标设备)
 */
+(void)getListLocationDeviceWithappid:(NSString *)appid andCategory:(NSString *)category  CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/location.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_location_device\",\"appid\":\"%@\",\"category\":\"%@\"}",appid,category];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//添加定位设备
/**
 appid : 应用id
 devid : 设备id
 category : 类别(1=移动设备，2=坐标设备)
 areaid : 区域id
 */
+(void)addLocationDeviceWithappid:(NSString *)appid andDevid:(NSString *)devid andCategory:(NSString *)category andAreaid:(NSString *)areaid  CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/location.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"add_location_device\",\"appid\":\"%@\",\"devid\":\"%@\",\"category\":\"%@\",\"areaid\":\"%@\"}",appid,devid,category,areaid];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//删除定位设备
/**
 appid : 应用id
 devid : 设备id
 
 */
+(void)delLocationDeviceWithappid:(NSString *)appid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/location.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"del_location_device\",\"appid\":\"%@\",\"devid\":\"%@\"}",appid,devid];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


//设置基点位置
/**
 appid : 应用id
 info : 位置信息 数组字典 @[@{@"devid":@"",@"posx":@"",@"posy":@""}]
 devid : 设备id
 posx : x位置
 posy : y位置
 */
+(void)setLocationDeviceWithappid:(NSString *)appid andInfo:(NSArray *)info  CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/location.do",user.header,user.proxyIp,user.proxyPort];
    
    NSMutableString * infostr = [[NSMutableString alloc]init];
    
    
    
    [infostr appendString:@",\"info\":["];
    
    for (NSDictionary *infoDic in info) {
        
        if (infoDic[@"devid"]) {
            [infostr appendFormat:@"{\"devid\":\"%@\"",infoDic[@"devid"]];
        }
        
        if (infoDic[@"posx"]) {
            [infostr appendFormat:@",\"posx\":\"%@\"",infoDic[@"posx"]];
        }
        
        if (infoDic[@"posy"]) {
            [infostr appendFormat:@",\"posy\":\"%@\"},",infoDic[@"posy"]];
        }
        
    }
    
    if ([[infostr substringFromIndex:infostr.length-1] isEqualToString:@","]) {
        [infostr replaceCharactersInRange:NSMakeRange(infostr.length-1, 1) withString:@"]"];
    }
    else
    {
        [infostr appendString:@"]"];
    }
    
    

    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"set_location_device\",\"appid\":\"%@\"%@}",appid,infostr];
    
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}




#pragma mark-- 云端接口: 服务器 相关

//获取网关服务器信息(网关请求)
+(void)getGatewayInfoFromCloudWithHouseIeee:(NSString *)houseIeee CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/server.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"get_byhouse\",\"house_ieee\":\"%@\"}",houseIeee];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];

}

#pragma mark-- 云端接口: 天气相关

//获取天气环境指数
+(void)getWeatherFromCloudCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
 
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/netdata.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"get_weather\"}"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

//获取皮肤列表 cache表示是否只读缓存数据
+(void)getSkinLsitFormCloudWithCache:(BOOL) cache CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/client.do",user.header,user.proxyIp,user.proxyPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_appskin\"}"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    
    NSArray * skinDicOri = [[NSUserDefaults standardUserDefaults] objectForKey:@"skinlist"];
    if(skinDicOri == nil)
    {
        skinDicOri = [NSArray new];
    }
    result(@{@"seq":@"皮肤",@"status_code":@0,@"result":skinDicOri});
    
    if(cache == NO)  //不仅读缓存，还要从网络更新数据
    {
        [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
            if ([aResult[@"status_code"] intValue] !=0) {
                result(@{@"seq":@"皮肤",@"status_code":@0,@"result":skinDicOri});
            }
            else
            {
                [NetvoxCommon updateSkin:[aResult objectForKey:@"result"]];
                NSArray * skinDicCur = [[NSUserDefaults standardUserDefaults] objectForKey:@"skinlist"];
                result(@{@"seq":@"皮肤",@"status_code":@0,@"result":skinDicCur});
            }
            
        }];
    }
    
}

//获取APK最新版本 type:ios-mobile/ios-pad
+(void)getVersionFormCloudWithType:(NSString *)type CustomerCode:(NSString *)code CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    if(user.isNotFirstIn != true)  //启动后第一次登录需要检测版本
    {
        user.isNotFirstIn = true;
        
        NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/client.do",user.header,user.proxyIp,user.proxyPort];
        NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"get_last_apk\",\"dev_type\":\"%@\",\"customer_code\":\"%@\"}",type,code];
        
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeHttpPost;
        model.user = user;
        model.url = url;
        model.param = dataStr;
        
        
        [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
            //当前版本
            NSString *key = @"CFBundleShortVersionString";
            NSString *versionLocal = [[NSBundle mainBundle] infoDictionary][key];
            //存储到最新版本
            NSString * userDefaultKey = [NSString stringWithFormat:@"%@Version",code];
            NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:userDefaultKey] == nil ? @"" : [[NSUserDefaults standardUserDefaults] objectForKey:userDefaultKey];
            id temp = aResult[@"result"];

            if ([aResult[@"status_code"] intValue] == 0 && [temp isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary *resultMsg = [NSMutableDictionary dictionaryWithDictionary:aResult[@"result"]];
                //网络版本
                NSString *verInNet = resultMsg[@"version_name"];
                if(verInNet != nil && ![verInNet isEqualToString:versionLocal] && ![verInNet isEqualToString:lastVersion])
                {
                    result(@{@"seq":@"是否更新",@"status_code":@0,@"result":[NSString stringWithFormat:@"net:%@ - local:%@",verInNet,lastVersion ]});
                }
                else
                {
                    [resultMsg setValue:lastVersion forKey:@"local"];
                    result(@{@"seq":@"是否更新",@"status_code":@1,@"result":resultMsg});
                }
                [[NSUserDefaults standardUserDefaults] setObject:verInNet forKey:userDefaultKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                result(@{@"seq":@"是否更新",@"status_code":@1,@"result":[NSString stringWithFormat:@"app version does not exist,local:%@",lastVersion]});
            }
        }];
    }
}


//上传崩溃日志
+(void)updataLogToCloudWithProxyIP:(NSString *)proxyIp ProxyPort:(int)proxyPort House:(NSString *)ieee User:(NSString *)userName IphoneType:(NSString *) iphoneType Resolution:(NSString *) resolution Memory:(NSString *)memory OsVer:(NSString *)osVer LogFile:(NSData *)file progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/client.do",user.header,proxyIp,proxyPort];
    //当前版本
    NSString *key = @"CFBundleShortVersionString";
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][key];
 
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"upload_log\",\"house_ieee\":\"%@\",\"user\":\"%@\",\"dev_type\":\"IOS\",\"brand\":\"Apple\",\"model\":\"%@\",\"resolution\":\"%@\",\"memory\":\"%@\",\"os_version\":\"%@\",\"app_version\":\"%@\",\"cloud_ip\":\"%@\"}",ieee,userName,iphoneType,resolution,memory,osVer,appVersion,proxyIp];
    
    int originRequestTime = user.requstTime;
    user.requstTime = user.updataRequestTime;
    
    
    //该接口不加密
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.isNotEncrypt = YES;
    model.networkType = netvoxNetworkTypeUpload;
    model.user = user;
    model.url = url;
    
    [model.formDataArray removeAllObjects];
    [model.fileNameArray removeAllObjects];
    [model.mimeTypeArray removeAllObjects];
    [model.formDataArray addObject:file];
    [model.fileNameArray addObject:@"file"];
    [model.mimeTypeArray addObject:@"text/plain"];
   
    model.progress = progress;
    model.param = dataStr;
    
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        user.requstTime = originRequestTime;
        result(aResult);
    }];
}

//上传联动日志
+ (void)uploadRuleLogWithHouseieee:(NSString *)houseIeeee User:(NSString *)user Ruleid:(NSString *)ruleid Rulename:(NSString *)rulename Operation:(NSString *)operation progress:(void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *userInfo = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/shc.do",userInfo.header,userInfo.proxyIp,userInfo.proxyPort];

    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"upload_rule_log\",\"house_ieee\":\"%@\",\"user\":\"%@\",\"rule_id\":\"%@\",\"rule_name\":\"%@\",\"operation\":\"%@\"}",houseIeeee,user,ruleid,rulename,operation];
    
   
    
    
    //该接口不加密
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeUpload;
    model.user = userInfo;
    model.url = url;
    model.type = 0x1000003;
    
    
    [model.formDataArray removeAllObjects];
    [model.fileNameArray removeAllObjects];
    [model.mimeTypeArray removeAllObjects];
    [model.fileNameArray addObject:@"file"];
    [model.mimeTypeArray addObject:@"text/plain"];
    
    model.progress = progress;
    model.param = dataStr;
    
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        
        result(aResult);
    }];
}

//获取联动日志
+ (void)getListRuleLogWithHouseieee:(NSString *)houseIeee Starttime:(NSString *)starttime Endtime:(NSString *)endtime Pagenum:(NSNumber *)pagenum Pagesize:(NSNumber *)pagesize CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/shc.do",user.header,user.serverIp,user.serverPort];
    
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_rule_log\",\"house_ieee\":\"%@\",\"start_time\":\"%@\",\"end_time\":\"%@\",\"pagenum\":\"%@\",\"pagesize\":\"%@\"}",houseIeee,starttime,endtime,pagenum,pagesize];
    

    //该接口不加密
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    
    model.param = dataStr;
    
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        result(aResult);
    }];
}


#pragma mark--萤石摄像头接口

//萤石摄像头获取accessToken
+(void)YSGetAccessTokenWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret CompletionHandler:(void (^)(NSDictionary *result))result
{
    NSString *url = @"https://open.ys7.com/api/lapp/token/get";
    NSDictionary *params = @{@"appKey":appKey,@"appSecret":appSecret};
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeYSHttpPost;
    model.url = url;
    model.params = params;
    
    
//    NetvoxUserInfo * user = [NetvoxUserInfo shareInstance];
//    if (user.ysAppKey == nil)
//    {
//        user.ysAppKey = appKey;
//    }
//    if (user.ysAppSecret == nil){
//        user.ysAppSecret = appSecret;
//    }
    
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:^(NSDictionary *aResult) {
        if (aResult && [aResult[@"code"] intValue] == 200) {
            NSDictionary *accessTokenData = aResult[@"data"];
            NSString *accessToken = accessTokenData[@"accessToken"];
            [NetvoxUserInfo shareInstance].ysAccessToken = accessToken;
        }
        
        result(aResult);
    }];
    
 
    
}

//萤石添加预置点
+(void)YSAddPresetWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo CompletionHandler:(void (^)(NSDictionary *result))result
{
    NSString *url = @"https://open.ys7.com/api/lapp/device/preset/add";
    NSString *accessToken = [NetvoxUserInfo shareInstance].ysAccessToken;
    if (accessToken) {
        NSDictionary *params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial,@"channelNo":[NSNumber numberWithInt:channelNo]};
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeYSHttpPost;
        model.url = url;
        model.params = params;
        
        [NetvoxNetwork sendWithParam:model CompletionHandler:result];
       
    }
    else
    {
        result(@{@"seq":@"1234",@"code":@"-409",@"result":@"not get accessToken"});

    }
    

}

//调用预置点
+(void)YSMovePresetWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo index:(int)index CompletionHandler:(void (^)(NSDictionary *result))result
{
    NSString *url = @"https://open.ys7.com/api/lapp/device/preset/move";
    NSString *accessToken = [NetvoxUserInfo shareInstance].ysAccessToken;
    if (accessToken) {
        NSDictionary *params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial,@"channelNo":[NSNumber numberWithInt:channelNo],@"index":[NSNumber numberWithInt:index]};
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeYSHttpPost;
        model.url = url;
        model.params = params;
        
        [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    }
    else
    {
        result(@{@"seq":@"1234",@"code":@"-409",@"result":@"not get accessToken"});
        
    }

}

//清除预置点
+(void)YSClearPresetWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo index:(int)index CompletionHandler:(void (^)(NSDictionary *result))result
{
    NSString *url = @"https://open.ys7.com/api/lapp/device/preset/clear";
    NSString *accessToken = [NetvoxUserInfo shareInstance].ysAccessToken;
    if (accessToken) {
        NSDictionary *params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial,@"channelNo":[NSNumber numberWithInt:channelNo],@"index":[NSNumber numberWithInt:index]};
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeYSHttpPost;
        model.url = url;
        model.params = params;
        
        [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    }
    else
    {
        result(@{@"seq":@"1234",@"code":@"-409",@"result":@"not get accessToken"});
        
    }

}

//设置摄像机指示灯开关
+(void)YSSetLightSwitchWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo enable:(int)enable CompletionHandler:(void (^)(NSDictionary *result))result
{
    NSString *url = @"https://open.ys7.com/api/lapp/device/light/switch/set";
    NSString *accessToken = [NetvoxUserInfo shareInstance].ysAccessToken;
    if (accessToken) {
        NSDictionary *params = @{};
        if (channelNo == -1) {
            params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial,@"enable":[NSNumber numberWithInt:enable]};
        }
        else
        {
            params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial,@"channelNo":[NSNumber numberWithInt:channelNo],@"enable":[NSNumber numberWithInt:enable]};
        }
  
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeYSHttpPost;
        model.url = url;
        model.params = params;
        
        [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    }
    else
    {
        result(@{@"seq":@"1234",@"code":@"-409",@"result":@"not get accessToken"});
        
    }
}

//获取摄像机指示灯开关状态
+(void)YSGetLightSwitchWithDeviceSerial:(NSString *)deviceSerial CompletionHandler:(void (^)(NSDictionary *result))result
{
    NSString *url = @"https://open.ys7.com/api/lapp/device/light/switch/status";
    NSString *accessToken = [NetvoxUserInfo shareInstance].ysAccessToken;
    if (accessToken) {
        NSDictionary *params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial};
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeYSHttpPost;
        model.url = url;
        model.params = params;
        
        [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    }
    else
    {
        result(@{@"seq":@"1234",@"code":@"-409",@"result":@"not get accessToken"});
        
    }

}

//获取声源定位开关状态
+(void)YSGetSslSwitchWithDeviceSerial:(NSString *)deviceSerial CompletionHandler:(void (^)(NSDictionary *result))result
{
    NSString *url = @"https://open.ys7.com/api/lapp/device/ssl/switch/status";
    NSString *accessToken = [NetvoxUserInfo shareInstance].ysAccessToken;
    if (accessToken) {
        NSDictionary *params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial};
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeYSHttpPost;
        model.url = url;
        model.params = params;
        
        [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    }
    else
    {
        result(@{@"seq":@"1234",@"code":@"-409",@"result":@"not get accessToken"});
        
    }

}

//设置声源定位开关(channelNo:传-1 表示设备本身)
+(void)YSSetSslSwitchWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo enable:(int)enable CompletionHandler:(void (^)(NSDictionary *result))result
{
    NSString *url = @"https://open.ys7.com/api/lapp/device/ssl/switch/set";
    NSString *accessToken = [NetvoxUserInfo shareInstance].ysAccessToken;
    if (accessToken) {
        NSDictionary *params = @{};
        if (channelNo == -1) {
            params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial,@"enable":[NSNumber numberWithInt:enable]};
        }
        else
        {
            params = @{@"accessToken":accessToken,@"deviceSerial":deviceSerial,@"channelNo":[NSNumber numberWithInt:channelNo],@"enable":[NSNumber numberWithInt:enable]};
        }
        
        NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
        model.networkType = netvoxNetworkTypeYSHttpPost;
        model.url = url;
        model.params = params;
        
        [NetvoxNetwork sendWithParam:model CompletionHandler:result];
    }
    else
    {
        result(@{@"seq":@"1234",@"code":@"-409",@"result":@"not get accessToken"});
        
    }

}


#pragma mark -- 单设备接口
/**
 添加单设备
 appid : 应用id(默认是智能家居应用)
 devid : 设备id
 */
+(void)addDeviceWithAppid:(NSString *)appid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"add_device\",\"appid\":\"%@\",\"devid\":\"%@\"}",appid,devid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

/**
 删除单设备
 appid : 应用id
 devid : 设备id
 */
+(void)delDeviceWithAppid:(NSString *)appid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"del_device\",\"appid\":\"%@\",\"devid\":\"%@\"}",appid,devid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

/**
 获取单设备的设备列表
 appid : 应用id
 roomid : 房间id
 devids : 设备id数组，空代表全部
 pagenum : 页码
 pagesize : 每页大小
 */
+(void)getListDeviceWithAppid:(NSString *)appid andRoomid:(NSString *)roomid andDevids:(NSArray *)dev_ids andPagenum:(NSString *)pagenum andPagesize:(NSString *)pagesize CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    NSMutableString * devidsStr = [NSMutableString string];
    

    [devidsStr appendString:@"["];
    for (NSString * str in dev_ids) {
        [devidsStr appendFormat:@"\"%@\",",str];
    }
    if ([[devidsStr substringFromIndex:devidsStr.length-1] isEqualToString:@","]) {
        [devidsStr replaceCharactersInRange:NSMakeRange(devidsStr.length-1, 1) withString:@"]"];
    }
    else
    {
        [devidsStr appendString:@"]"];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\" list_device\",\"appid\":\"%@\",\"roomid\":\"%@\",\"dev_ids\":%@,\"pagenum\":\"%@\",\"pagesize\":\"%@\"}",appid,roomid,devidsStr,pagenum,pagesize];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}
/**
 获取单个设备详情
 devid : 设备id
 */
+(void)getDetailsDeviceWithDevid:(NSString *)devid  CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"details\",\"devid\":\"%@\"}",devid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}


/**
 修改单设备信息
 devid : 设备id
 roomid : 房间id
 name : 设备名称
 */
+(void)updateDevinfoWithDevid:(NSString *)devid andRoomid:(NSString *)roomid andName:(NSString *)name CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"update_devinfo\",\"devid\":\"%@\",\"roomid\":\"%@\",\"name\":\"%@\"}",devid,roomid,name];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

/**
 获取单设备的房间列表
 */
+(void)getListRoomsWithCompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"list_rooms\"}"];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

/**
 新增修改房间单设备
 id : 房间id(-1表示新增)
 name : 房间名称
 dev_ids : 设备id数组(新增房间可以不传设备)
 */
+(void)updateRoomInfoWithRoomid:(NSString *)roomid andName:(NSString *)name andDevids:(NSArray *)dev_ids CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
    NSMutableString * devidsStr = [NSMutableString string];
    
    
    [devidsStr appendString:@"["];
    for (NSString * str in dev_ids) {
        [devidsStr appendFormat:@"\"%@\",",str];
    }
    if ([[devidsStr substringFromIndex:devidsStr.length-1] isEqualToString:@","]) {
        [devidsStr replaceCharactersInRange:NSMakeRange(devidsStr.length-1, 1) withString:@"]"];
    }
    else
    {
        [devidsStr appendString:@"]"];
    }
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"update_roominfo\",\"id\":\"%@\",\"name\":\"%@\",\"dev_ids\":%@}",roomid,name,devidsStr];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

/**
 删除单设备房间
 id : 房间id
 */

+(void)delRoomInfoWithRoomid:(NSString *)roomid  CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
   
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"update_roominfo\",\"id\":\"%@\"}",roomid];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}

/**
 设备控制
 action    note     params
 set_threshold     设置阈值     [{"threshold":20}]
 send_command     发送命令     [{"command":"00101124121515511"}]
 devid : 设备id
 action : 设备动作
 params : 设备参数 [{参数名称:参数值}] @[@{"name":"value"}]
 */
+ (void)controlDeviceWithDevid:(NSString *)devid andAction:(NSString *)action andParams:(NSArray *)params CompletionHandler:(void (^)(NSDictionary *result))result
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    
    NSString *url = [NSString stringWithFormat:@"%@://%@:%d/smarthome/api/single_device.do",user.header,user.proxyIp,user.proxyPort];
    
    NSMutableString * paramsStr = [NSMutableString string];
    
    [paramsStr appendString:@"["];
    for (NSDictionary *dic in params) {
        NSString *name = dic[@"name"];
        NSString *value = dic[@"value"];
        [paramsStr appendFormat:@"{\"name\":\"%@\",\"value\":\"%@\"},",name,value];
    }
    
    [paramsStr replaceCharactersInRange:NSMakeRange(paramsStr.length-1, 1) withString:@"]"];
    
    
    NSString *dataStr = [NSString stringWithFormat:@"{\"op\":\"control\",\"devid\":\"%@\",\"action\":\"%@\",\"params\":%@}",devid,action,paramsStr];
    
    NetvoxNetworkModel *model = [[NetvoxNetworkModel alloc]init];
    model.networkType = netvoxNetworkTypeHttpPost;
    model.user = user;
    model.url = url;
    model.param = dataStr;
    
    [NetvoxNetwork sendWithParam:model CompletionHandler:result];
}





//恢复初始化url地址
+(NSString *)recoverUrl
{
    return @"http://101.201.197.167/restore/index.html";
}

//重新选择当前家 在删除或转让分享家后
+(void)reChoiseHouseIeeeFromHouseArrayWithDeleteHouse:(NSString *)houseIeee
{
    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
    
    //删除的是当前网关，找下一个网关,更新当前网关并重连mqtt
    if([houseIeee isEqualToString:user.currentHouseIeee])
    {
        if(user.houseArr.count > 1)
        {
            NSMutableArray * tempHouseArr = [NSMutableArray arrayWithArray:user.houseArr];
            for (int i=0;i<user.houseArr.count;i++) {
                NSDictionary *dic = user.houseArr[i];
                if([dic[@"house_ieee"] isEqualToString:houseIeee])
                {
                    if([dic isEqual:user.houseArr.lastObject])
                    {
                        NSDictionary *firstHouse = user.houseArr.firstObject;
                        NSString *name = firstHouse[@"name"];
                        NSString *house_ieee = firstHouse[@"house_ieee"];
                        user.currentHouseIeee = house_ieee;
                        user.houseName = name;
                    }
                    else
                    {
                        NSDictionary *nextHouse = user.houseArr[i+1];
                        NSString *name = nextHouse[@"name"];
                        NSString *house_ieee = nextHouse[@"house_ieee"];
                        user.currentHouseIeee = house_ieee;
                        user.houseName = name;
                    }
                    
                    [tempHouseArr removeObject:dic];
                    user.houseArr = [NSArray arrayWithArray:tempHouseArr];
                    [NetvoxUserInfo updateLocalData];
                    
                }
            }
            
            //重连
            [self connectToHouse:user.currentHouseIeee CompletionHandler:^(NSDictionary *bresult) {
                NSString *status_code = bresult[@"status_code"];
                if([status_code intValue] == 88888)
                {
                    NSLog(@"删除分享网关后 MQTT重连成功,当前家%@",user.currentHouseIeee);
                }
                else
                {
                    NSLog(@"删除分享网关后 MQTT重连失败");
                }
            }];
            
        }
        else  //如果数组中只有一个家
        {
            user.currentHouseIeee = @"";
            user.houseName = @"";
            user.houseArr = @[];
            [NetvoxUserInfo updateLocalData];
            [[NetvoxMqtt shareInstance] disconnect];
            
        }
    }
    else  //移除数组中元素
    {
        
        NSMutableArray *tempHouseArr = [NSMutableArray arrayWithArray:user.houseArr];
        for (NSDictionary *dic in user.houseArr) {
            if([dic[@"house_ieee"] isEqualToString:houseIeee])
            {
                [tempHouseArr removeObject:dic];
            }
        }
        user.houseArr = [NSArray arrayWithArray:tempHouseArr];
        
        [NetvoxUserInfo updateLocalData];
    }
}



#pragma mark - 判断Ipv6 环境制造假数据返回
/***
 dev_id 对应单个设备请求，tagStr 对应请求是属于什么类型的请求 需要请求造假的请求是
 1.获取家列表
 2.获取房间
 3.获取设备而列表详情
 4.获取单个设备详情
 
 */
+ (NSDictionary *)backDicForIpv6:(NSString *)dev_id andaResult:(NSDictionary *)aResult andRequest:(NSString *)tagStr
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:aResult[@"seq"] forKey:@"seq"];
    [dic setValue:[NSNumber numberWithInteger:0] forKey:@"status_code"];
    if ([tagStr isEqualToString:@"house"]) {
        NetvoxUserInfo * user = [NetvoxUserInfo shareInstance];
        NSArray * array = @[@{
                              @"name":@"上海的家",
                              @"house_ieee":@"00137A0000010136",
                              @"status":@"online",
                              @"cloud_server_ip":@"101.201.252.233",
                              @"cloud_server_port":[NSString stringWithFormat:@"%d",80],
                              @"msg_server_ip": @"101.201.252.233",
                              @"msg_server_port":[NSString stringWithFormat:@"%d",1883],
                              @"address": @"福建省厦门市湖里区殿前街道",
                              @"lat":@"24.51448917696747",//24.51448917696747
                              @"lng":@"118.124365657568"//118.124365657568
                              }];
        if (user != nil) {
            user.houseArr = array;
        }
        [dic setObject:array forKey:@"result"];
    }
    else if ([tagStr isEqualToString:@"room"])
    {
        [dic setValue:@[@{
                            @"id":@"0",
                            @"name":@"家全局",
                            @"picture":@""
                            }] forKey:@"result"];
    }
    else if ([tagStr isEqualToString:@"list"])
    {
        [dic setValue:[NetvoxCommon arrayForDeviceListDictionary] forKey:@"result"];
    }
    else if ([tagStr isEqualToString:@"device"])
    {
        [dic setValue:[NetvoxCommon resultDeviceDetail:dev_id] forKey:@"result"];
    }
    else if ([tagStr isEqualToString:@"login"])
    {
        [dic setValue:@{
                        @"nickname":@"test",
                        @"photo": @"",
                        @"user":@"214976189@qq.com",
                        } forKey:@"result"];
    }
    return dic;
}

#pragma mark 字典转化字符串
+(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
