//
//  NetvoxNetwork.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/22.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetvoxDeviceParam.h"
#import "NetvoxUserParam.h"

@interface NetvoxNetwork : NSObject


//获取摄像头本地缓存的accessToken(需要做过获取摄像头accessToken的请求)
+(NSString *)getYSAccessToken;


//获取时间戳(精确到毫秒)
+(NSString *)getTimestamp;

//返回文件夹路径
+(NSString *)getDirectoryPath;


@end
