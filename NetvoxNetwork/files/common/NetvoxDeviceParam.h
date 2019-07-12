//
//  NetvoxDeviceParam.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/6/20.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  设备参数设置模型

#import <Foundation/Foundation.h>


@interface NetvoxDeviceParam : NSObject

//上电开关状态
@property (nonatomic,strong)NSString *poweron_status;

//光照阈值
@property (nonatomic,strong)NSString *sunlight_threshold;

//红外延时时间(标准)
@property (nonatomic,strong)NSString *ir_delay_time;

//无人检测时间(红外延时时间(自定义))
@property (nonatomic,strong)NSString *ir_disable_time;

//有人检测时间(红外检测时间)
@property (nonatomic,strong)NSString *ir_detection_time;

//童锁设置
@property (nonatomic,strong)NSString *childlock;

//开关方向
@property (nonatomic,strong)NSString *onoff_dir;

//继电器设置
@property (nonatomic,strong)NSString *relay_setting;

//检测设置
@property (nonatomic,strong)NSString *check_setting;

//告警延迟
@property (nonatomic,strong)NSString *warn_delay;


//基数清零时间
@property (nonatomic,strong)NSString *count_clear_time;

//液位检测值
@property (nonatomic,strong)NSString *liquid_level_check_value;

//导线长度
@property (nonatomic,strong)NSString *wire_length;


//探测灵敏度
@property (nonatomic,strong)NSString *detect_sensitivity;

//采样周期
@property (nonatomic,strong)NSString *sampling_period;

//电机设置
@property (nonatomic,strong)NSString *motor_setting;

//停止方式
@property (nonatomic,strong)NSString *stop_way;

//本机开关方式
@property (nonatomic,strong)NSString *switch_way;

//持续时间
@property (nonatomic,strong)NSString *duration;

//背板亮度
@property (nonatomic,strong)NSString *panel_brightness;

//设置模式(数组里面是字典,举例如下:@[@"1"}])
@property (nonatomic,strong)NSMutableArray *config_mode;

//光照级别
@property (nonatomic,strong)NSString *sunlight_level;

//串口参数设置(comport_param是字典,举例如下:@{@"baudrate":@115200,@"stopbit":@0,@"parity":@1})
@property (nonatomic,strong)NSDictionary *comport_param;

//感应到红外信号,是否支持动作继电器
@property (nonatomic,strong)NSString *ir_trigger_relay_action;

//接收到2此ON/OFF命令,是否动作继电器
@property (nonatomic,strong)NSString *twice_onoff_relay_action;

//日照检测范围设置
@property (nonatomic,strong)NSString *sunlight_check_range;

//阀门类型
@property (nonatomic,strong)NSString *valve_type;

//zone设备是否被弃用
@property (nonatomic,strong)NSString *enable;

//移动时间
@property (nonatomic,strong)NSString *move_time;

//红外检测方式
@property (nonatomic,strong)NSString *ir_check_mode;
//窗帘电机类型 window_cover_param {hand_start_onoff:当shade_type=duya_shade时候仅设置该参数. shade_type=mfg_shade,需同时设置其余三个参数,reverse_onoff:reverse_on\reverse_off,continue_mode_onoff:预留，暂不设置. continue_mode_on\continue_mode_off,max_speed:最大速度（50-150）,shade_type:mfg_shade\duya_shade}
@property (nonatomic,strong)NSDictionary *window_cover_param;
//告警方式
@property (nonatomic,strong)NSString *warn_way;


//弹出间隔


@end
