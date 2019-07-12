//
//  NetvoxCallback.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/23.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import <Foundation/Foundation.h>


//注:如无特殊说明,value为NSDictionary类型,通知的object参数写type(NSString 类型),如果传nil,则会收到全部callback
//callback 接收到消息
extern NSString *const kCallbackReciveMsgNotification;

@interface NetvoxCallback : NSObject


//单例
+(NetvoxCallback *)shareInstance;

//object 监听type设置
+(NSString *)type:(int)type;

@end
