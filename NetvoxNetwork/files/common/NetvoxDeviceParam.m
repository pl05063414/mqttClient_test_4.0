//
//  NetvoxDeviceParam.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/6/20.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  设备参数模型(用于设置设备参数请求,没有的属性请不要赋值)

#import "NetvoxDeviceParam.h"

@implementation NetvoxDeviceParam




-(NSMutableArray *)config_mode
{
    if(_config_mode == nil)
    {
        _config_mode = [NSMutableArray new];
    }
    return _config_mode;
}



@end
