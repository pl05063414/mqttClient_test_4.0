//
//  NetvoxNetwork_Interface.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/22.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  接口
//  说明:返回代码块不能传nil;返回status_code(萤石接口为code,value为NSString类型,除萤石外该key的value为NSNumber类型) 为-404 是本地请求超时的错误码或者失败;-405 为socket 连接失败;-406 为mqtt 连接失败;-407 为无网络连接;-408 为sockCallback验证失败;-409 为萤石摄像头未取得accesstoken,需调用接口获取;-410,数据解析失败;对于可选参数,字符串类型的不传可以传nil;-411,接口参数错误;

#import "NetvoxNetwork.h"


@interface NetvoxNetwork ()

/*
               参数设置
 **/

//初始化
+(void)initWithUserParam:(NetvoxUserParam *)param CompletionHandler:(void (^)(NSDictionary *result))result;

// 连接到家（只有外网可用，内网无效，外网做设备控制，获取设备列表前需要调用该接口，调用登陆接口默认连接第一个家）
+(void)connectToHouse:(NSString *)houseIeee CompletionHandler:(void (^)(NSDictionary *result))result;





/*
                 网关接口
 **/




//                       设备操作




// 获取设备列表(cache 是否读缓存,YES取缓存数据,如果有缓存,block会返回2次数据;可选参数devicetype 不传可以传nil)
+(void)getDeviceListWithRoomid:(NSString *)roomid devicetype:(NSString *)devicetype pagenum:(int)pagenum pagesize:(int)pagesize cache:(BOOL)cache CompletionHandler:(void (^)(NSDictionary *result))result;

//获取设备列表详情(dev_ids 数组元素请传NSString类型;可选参数devicetype 不传可以传nil;cache 是否读缓存,YES取缓存数据,如果有缓存,block会返回2次数据)
+(void)getDeviceListDetailWithRoomid:(NSString *)roomid devicetype:(NSString *)devicetype dev_ids:(NSArray *)dev_ids pagenum:(int)pagenum pagesize:(int)pagesize cache:(BOOL)cache CompletionHandler:(void (^)(NSDictionary *result))result;

//获取单个设备详情
+(void)getDeviceDetailWithDev_id:(NSString *)dev_id CompletionHandler:(void (^)(NSDictionary *result))result;

//设备开加网操作
+(void)opennetWithTime:(int)time CompletionHandler:(void (^)(NSDictionary *result))result;

+(void)searchDeviceWithDeviceType:(NSString *)deviceType Time:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result;

//添加设备(udeviceid ,ext为可选参数,ext字典key为sn和verify,如@{@"sn":@"1234",@"verify_code":@"434"}
+(void)addDeviceWithIeee:(NSString *)ieee devicetype:(NSString *)devicetype udeviceid:(NSString *)udeviceid ext:(NSDictionary *)ext CompletionHandler:(void (^)(NSDictionary *result))result;

//删除设备
+(void)deleteDeviceWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//添加预置点
+(void)addPresetpointWithId:(NSString *)Id name:(NSString *)name desc:(NSString *)desc createTime:(NSString *)createTime CompletionHandler:(void (^)(NSDictionary *result))result;

//修改预置点
+(void)modifyPresspointWithId:(NSString *)Id name:(NSString *)name desc:(NSString *)desc CompletionHandler:(void (^)(NSDictionary *result))result;

//删除预置点
+(void)deletePresetpointWithId:(NSString *)Id name:(NSString *)name CompletionHandler:(void (^)(NSDictionary *result))result;

//获取预置点列表
+(void)getPresetpointListWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//修改设备信息
+(void)updateDevInfoWithId:(NSString *)Id name:(NSString *)name roomid:(NSString *)rooomid CompletionHandler:(void (^)(NSDictionary *result))result;

//设备开操作
+(void)onWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//设备关操作
+(void)offWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//设备置反操作
+(void)toggleWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;


//调节设备级别
+(void)setlevelWithId:(NSString *)Id level:(int)level CompletionHandler:(void (^)(NSDictionary *result))result;

//设备背板亮度设置
+(void)setbglevelWithId:(NSString *)Id level:(int)level CompletionHandler:(void (^)(NSDictionary *result))result;

//设置彩灯颜色(transTime 为可选参数,不设置请传-1)
+(void)setcolorWithId:(NSString *)Id r:(int)r g:(int)g b:(int)b transTime:(int)transTime CompletionHandler:(void (^)(NSDictionary *result))result;

//获取彩灯模式列表
+(void)getColorModeWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//设置彩灯色温(transTime 为可选参数,不设置请传-1)
+(void)setcolortempWithId:(NSString *)Id level:(int)level transTime:(int)transTime CompletionHandler:(void (^)(NSDictionary *result))result;


//新增修改彩灯模式(或修改）modelId = -1为新增 colorArr里存字典，{r:x,g:x,b:x,duration:x}
+(void)addColorModeWithId:(NSString *)Id ModeId:(NSString *)modeId Name:(NSString *)name ColorArr:(NSArray *)arr CompletionHandler:(void (^)(NSDictionary *result))result;

//删除彩灯模式
+(void)deleteColorModeWithId:(NSString *)Id ModeId:(NSString *)modeId CompletionHandler:(void (^)(NSDictionary *result))result;



//应用彩灯模式
+(void)applyColorModeWithId:(NSString *)Id ModeId:(NSString *)modeId CompletionHandler:(void (^)(NSDictionary *result))result;


//设备响铃
+(void)ringWithId:(NSString *)Id sound:(NSString *)sound CompletionHandler:(void (^)(NSDictionary *result))result;

//设备停止操作
+(void)stopWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//开门操作
+(void)openDoorWithId:(NSString *)Id userId:(NSString *)userId pwd:(NSString *)pwd CompletionHandler:(void (^)(NSDictionary *result))result;

//读取温控器开关状态
+ (void)getThermostatOnoffStatusWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//设置温控器温度
+ (void)setThermostatTemperatureWithId:(NSString *)Id temperature:(NSString *)temperature CompletionHandler:(void (^)(NSDictionary *result))result;

//读取温控器温度
+ (void)getThermostatTemperatureWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//设置温控器风量
+ (void)setThermostatWindspeedWithId:(NSString *)Id windspeed:(NSString *)windspeed CompletionHandler:(void (^)(NSDictionary *result))result;


//读取温控器风量
+ (void)getThermostatWindspeedWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//温控器模式设置 模式(cool/heat/fanonly)
+ (void)setThermostatModeWithId:(NSString *)Id mode:(NSString *)mode CompletionHandler:(void (^)(NSDictionary *result))result;


//发送IR命令
+(void)sendIrWithId:(NSString *)Id irData:(NSString *)irdata CompletionHandler:(void (^)(NSDictionary *result))result;

//设备退出学习模式 传真实设备id
+(void)quitIrLearnWithDevId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//下载IR数据
+(void)downloadIRDataWithBrandId:(NSString *)brandId ModelId:(NSString *)modelId CompletionHandler:(void (^)(NSDictionary *result))result;

//测试IR设备按键 Irdevice IR设备类型    Irseq key对应的IR序号
+(void)testIRKeyWithDevid:(NSString *)devId Irdevice:(NSString *)irdevice Irseq:(NSString *)irseq  CompletionHandler:(void (^)(NSDictionary *result))result;

//点击IR设备按键
+(void)clickIRDevWithVirtualDevid:(NSString *)devId Irseq:(NSString *)irseq  CompletionHandler:(void (^)(NSDictionary *result))result;

//确认IR设备有效
+(void)checkIRDevWithDevid:(NSString *)devId Irdevice:(NSString *)irdevice CompletionHandler:(void (^)(NSDictionary *result))result;

//获取IR设备按键
+(void)getIRKeyWithVirtualDevid:(NSString *)devId CompletionHandler:(void (^)(NSDictionary *result))result;

//新增IR设备
+(void)addIRDevWithDevid:(NSString *)devId Irdevice:(NSString *)irdevice CompletionHandler:(void (^)(NSDictionary *result))result;

//新增IR设备按键 Devid虚拟设备id   Irseq 可以对应irsq  Tag 标签
+(void)addIRKeyWithVirtualDevid:(NSString *)devId Irseq:(NSString *)irseq Tag:(NSString *)tag CompletionHandler:(void (^)(NSDictionary *result))result;

//删除IR设备按键
+(void)deleteIRKeyWithVirtualDevid:(NSString *)devId Irseq:(NSString *)irseq CompletionHandler:(void (^)(NSDictionary *result))result;

//学习IR设备按键  Devid 传虚拟设备id
+(void)learnIRKeyWithVirtualDevid:(NSString *)devId Irseq:(NSString *)irseq CompletionHandler:(void (^)(NSDictionary *result))result;

//IR设备分享
+(void)shareIRDevWithVirtualDevid:(NSString *)devId Brandid:(NSString *)brandid Modelid:(NSString *)modelid CompletionHandler:(void (^)(NSDictionary *result))result;

//接受IR设备分享
+(void)recieveIRShareWithDevid:(NSString *)devId Share_code:(NSString *)code CompletionHandler:(void (^)(NSDictionary *result))result;


//新增485设备
+(void)addSpdeviceWithUdeviceid:(NSArray *)udevice Spdevice:(NSString *)spdevice CompletionHandler:(void (^)(NSDictionary *result))result;

//获取485按键设备
+(void)getListSpdevkeyWithDevid:(NSString *)devId CompletionHandler:(void (^)(NSDictionary *result))result;

//点击485设备按键(不包括大金空调)
+(void)clickSpdevKeyWithDevid:(NSString *)devId FuncId:(NSString *)funcId CompletionHandler:(void (^)(NSDictionary *result))result;

//点击发送指令(大金空调)
+(void)sendSpdevCommandWithDevid:(NSString *)devId cmdType:(NSString *)cmdType command:(NSString *)command CompletionHandler:(void (^)(NSDictionary *result))result;


//布防
+(void)armCompletionHandler:(void (^)(NSDictionary *result))result;

//撤防
+(void)disarmCompletionHandler:(void (^)(NSDictionary *result))result;
//播放
+(void)mediaPlayWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//暂停
+(void)mediaPauseWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//调节音量
+(void)mediaVolumeWithId:(NSString *)Id andVolume:(int)volume CompletionHandler:(void (^)(NSDictionary *result))result;

//调节进度
+(void)mediaProgressWithId:(NSString *)Id andProgress:(int)progress CompletionHandler:(void (^)(NSDictionary *result))result;

//上一首
+(void)mediaPreWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;


//下一首
+(void)mediaNextWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//获取当前媒体详情
+(void)getCurrentMeidaDetailWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//切换播放模式
+(void)changePlayModeWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//切换媒体来源
+(void)changeMediaSourceWithId:(NSString *)Id Source:(NSString *)source CompletionHandler:(void (^)(NSDictionary *result))result;

//清空电能
+(void)clearEnergyWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//设备识别
+(void)identifyWithId:(NSString *)Id time:(int)time CompletionHandler:(void (^)(NSDictionary *result))result;

//设置设备参数(不用的参数,属性请不要赋值)
+(void)setParamWithId:(NSString *)Id param:(NetvoxDeviceParam *)param CompletionHandler:(void (^)(NSDictionary *result))result;

//设备进入学习模式
+(void)learnWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//设备绑定
+(void)bindWithId:(NSString *)Id dest_devid:(NSString *)dest_devid CompletionHandler:(void (^)(NSDictionary *result))result;

//设备解绑定
+(void)unbindWithId:(NSString *)Id dest_devid:(NSString *)dest_devid CompletionHandler:(void (^)(NSDictionary *result))result;

//获取已绑定列表
+(void)getBindListWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//获取可绑定列表
+(void)getAvailableBindListWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;



//设置空气净化器
+(void)aircleanerConfigWithId:(NSString *)Id onoff_status:(NSString *)onoff_status childlock:(NSString *)childlock delayPowerOffTime:(NSString *)delayPowerOffTime windspeed:(NSString *)windspeed anionSwitch:(NSString *)anionSwitch cleanFilterScreen:(NSString *)cleanFilterScreen CompletionHandler:(void (^)(NSDictionary *result))result;

//获取空气净化器
+(void)getAirCleanerConfigWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;


//设置空气净化器定时(timer 为存放字典的数组,字典key有id,action,enable,week,excute_time,例如:@[@{@“id”:@-1,@”action”:@”poweron”,@”enable”:@”0”,@”week”:@”0001001”,@”excute_time”:@”12:00”}])
+(void)setAircleanerTimerWithId:(NSString *)Id timer:(NSArray *)timer CompletionHandler:(void (^)(NSDictionary *result))result;


//删除空气净化器定时(timerIds 为删除定时id的数组,值为NSNumber类型,例如:@[@1,@2])
+(void)deleteAircleanerTimerWithId:(NSString *)Id timerIds:(NSArray *)timerIds CompletionHandler:(void (^)(NSDictionary *result))result;


//获取空气净化器定时
+(void)getAirCleanerTimerWithId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;


//获取组信息
+(void)getGroupMesWithGroupId:(NSString *)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//设备绑定组
+(void)deviceBindGroupWithDeviceId:(NSString *)devId GroupId:(NSString *)groupId CompletionHandler:(void (^)(NSDictionary *result))result;

//设备解绑组
+(void)deviceUnbindGroupWithDeviceId:(NSString *)devId GroupId:(NSString *)groupId CompletionHandler:(void (^)(NSDictionary *result))result;

//获取门锁绑定用户列表
+(void)getDoorlockBindUserlistWithId:(NSString *)Id user:(NSString *)appUser CompletionHandler:(void (^)(NSDictionary *result))result;

//绑定门锁账户
+(void)bindDoorlockUserWithId:(NSString *)Id appUser:(NSString *)appUser userType:(int)userType CompletionHandler:(void (^)(NSDictionary *result))result;

//解绑门锁账户
+(void)unbindDoorlockUserWithId:(NSString *)Id appUser:(NSString *)appUser doorlockUserid:(NSString *)doorlockUserid delFlag:(int)delFlag superpwd:(NSString *)superpwd CompletionHandler:(void (^)(NSDictionary *result))result;

//删除门锁账户
+(void)deleteDoorlockUserWithId:(NSString *)Id doorlockUserId:(NSString *)doorlockUserid superpwd:(NSString *)superpwd CompletionHandler:(void (^)(NSDictionary *result))result;

//新增门锁账户(user_type 为可选参数,不用的时候传-1)
+(void)addDoorlockUserWithId:(NSString *)Id appUser:(NSString *)appUser doorlockUserid:(NSString *)doorlockUserid doorlockPwd:(NSString *)doorlockPwd superpwd:(NSString *)superpwd userType:(int)userType CompletionHandler:(void (^)(NSDictionary *result))result;

//修改门锁超级密码
+(void)updateDoorlockSuperpwdWithId:(NSString *)Id oldPwd:(NSString *)oldPwd newPwd:(NSString *)newPwd CompletionHandler:(void (^)(NSDictionary *result))result;


//                          用户操作





//登陆  tag表示app名字 islocal是否是内网登陆, false是外网 true是内网,默认外网
+(void)loginWithTag:(NSString *)tag andIsLocal:(BOOL)islocal CompletionHandler:(void (^)(NSDictionary *result))result;

//获取用户列表
+(void)getUserListCompletionHandler:(void (^)(NSDictionary *result))result;

//获取用户信息
+(void)getUserInfoCompletionHandler:(void (^)(NSDictionary *result))result;

//添加用户(数组参数元素全部为NSString类型.permissionRoomIds:有权限的房间的roomid数组;denyRoomIds:无权限的房间的roomid数组;permissionModules:有权限的模式名称数组;denyModules:无权限的模式名称数组)
+(void)addUserWithUser:(NSString *)userName pwd:(NSString *)pwd phone:(NSString *)phone permissionRoomIds:(NSArray *)permissionRoomIds denyRoomIds:(NSArray *)denyRoomIds permissionModules:(NSArray *)permissionModules denyModules:(NSArray *)denyModules CompletionHandler:(void (^)(NSDictionary *result))result;

////更新用户
//+(void)updateUserInfoWithUser:(NSString *)userName pwd:(NSString *)pwd phone:(NSString *)phone nickname:(NSString *)nickname photo:(NSString *)photo CompletionHandler:(void (^)(NSDictionary *result))result;

//删除用户
+(void)deleteUserWithUser:(NSString *)userName CompletionHandler:(void (^)(NSDictionary *result))result;

//从云端刷新用户列表
+(void)refreshUserListCompletionHandler:(void (^)(NSDictionary *result))result;


//                          规则操作



//执行规则
+(void)executeWithId:(int)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//获取规则
+(void)getRuleListWithType:(NSString *)type CompletionHandler:(void (^)(NSDictionary *result))result;

//启用禁用规则
+(void)enableRuleWithId:(int)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//下载规则文件
+(void)downloadRuleCompletionHandler:(void (^)(NSDictionary *result))result;

//上传规则文件
+(void)uploadRuleWithString:(NSString *)xmlStr CompletionHandler:(void (^)(NSDictionary *result))result;

//                          房间操作


//获取房间列表(cache:YES取缓存数据,如果有缓存,block会返回2次数据)
+(void)getRoomList:(BOOL)cache CompletionHandler:(void (^)(NSDictionary *result))result;

//添加房间(注:该接口去除房间图片上传,dev_id数组值都为NSString类型)
+(void)addRoomWithName:(NSString *)name dev_id:(NSArray *)dev_id CompletionHandler:(void (^)(NSDictionary *result))result;

//修改房间(注:该接口去除房间图片上传,dev_id数组值都为NSString类型)
+(void)updateRoomInfoWithId:(int)Id name:(NSString *)name dev_id:(NSArray *)dev_id rule_id:(NSArray*)rule_id  CompletionHandler:(void (^)(NSDictionary *result))result;

//删除房间
+(void)deleteRoomWithId:(int)Id CompletionHandler:(void (^)(NSDictionary *result))result;

//LORA设备操作
/*
//添加lora设备
+(void)addLoraDeviceWithDevid:(NSString *)dev_id CompletionHandler:(void (^)(NSDictionary *result))result;

//获取lora设备列表
+(void)getLoraDevicelistWithRoomid:(NSString*)roomId withDevids:(NSArray *)devids withPagenum:(int)pagenum withPagesize:(int)pagesize CompletionHandler:(void (^)(NSDictionary *result))result;
*/


//                          系统操作

//文本命令控制
+(void)commandControlWithText:(NSString *)command CompletionHandler:(void (^)(NSDictionary *result))result;

//获取当地环境指数
+(void)getWeatherCompletionHandler:(void (^)(NSDictionary *result))result;

//获取系统配置信息
+(void)getConfigCompletionHandler:(void (^)(NSDictionary *result))result;

////设置系统配置信息(对于NSString 类型的不选传nil,int型不选传-1)
+(void)setConfigWithHouseName:(NSString *)houseName encryptKey:(NSString *)encryptKey wifiPwd:(NSString *)wifiPwd wifiName:(NSString *)wifiName wifiPwdEncrypt:(NSString *)wifiPwdEncrypt hwVersion:(NSString *)hwVersion manageServer:(NSString *)manageServer timestampEnable:(int)timestampEnable timestampAviableTime:(int)timestampAviableTime callbackAuth:(int)callbackAuth filterDev:(int)filterDev driver_mode:(int)driver_mode zbchannel:(int)zbchannel ez_appkey:(NSString *)ez_appkey ez_secret:(NSString *)ez_secret CompletionHandler:(void (^)(NSDictionary *result))result;
////设置系统配置信息(AppKey secret)
+(void)setConfigWithez_appkey:(NSString *)ez_appkey ez_secret:(NSString *)ez_secret CompletionHandler:(void (^)(NSDictionary *result))result;
//打包为出厂模式
+(void)factoryPackCompletionHandler:(void (^)(NSDictionary *result))result;



//IEEE合法性检查
+(void)IEEECheckCompletionHandler:(void (^)(NSDictionary *result))result;

//设备完整性检查
+(void)deviceCheckCompletionHandler:(void (^)(NSDictionary *result))result;

//设备绑定组完整性检查
+(void)bindGroupCheckCompletionHandler:(void (^)(NSDictionary *result))result;

//设备间绑定完整性检查
+(void)bindCheckCompletionHandler:(void (^)(NSDictionary *result))result;

//设备组完整性检查
+(void)groupCheckCompletionHandler:(void (^)(NSDictionary *result))result;

//设备登记检查
+(void)enrollCheckCompletionHandler:(void (^)(NSDictionary *result))result;

//一键处理
+(void)onekeyHandleWithOption:(BOOL)isBindGroup CompletionHandler:(void (^)(NSDictionary *result))result;

//获取网关信息
+(void)getGatewayInfoCompletionHandler:(void (^)(NSDictionary *result))result;


//修改网关无线模式
+(void)setGatewayAirwireModeCompletionHandler:(void (^)(NSDictionary *result))result;

//恢复出厂设置
+(void)factoryResetCompletionHandler:(void (^)(NSDictionary *result))result;



/*
                 云端接口(支持http和https)
 **/



//         设备相关
//获取设备列表
/***
 house_ieee : 网关IEEE 为空的话就是用户下所有家庭的
 roomid : 房间id Roomid=-1 全部设备 Roomid=0 家全局的设备 Roomid=1 房间ID为1的设备
 pagenum : 页码
 pagesize : 每页大小
 */
+ (void)getListWithHouseieee:(NSString *)house_ieee andRoomid:(int)roomid andPagenum:(int)pagenum andPagesize:(int)pagesize CompletionHandler:(void (^)(NSDictionary *result))result;

//获取设备支持的属性
/***
 dev_id : 设备uid
 */
+ (void)getListDevattrWithDevid:(NSString *)dev_id CompletionHandler:(void (^)(NSDictionary *result))result;


//获取设备操作历史 （可选参数 dev_id）
+(void)getDeviceRecordFromCloudWithHouseIeee:(NSString *)houseIeee dev_id:(NSString *)dev_id pagenum:(int)pagenum pagesize:(int)pagesize CompletionHandler:(void (^)(NSDictionary *result))result;
    
//获取设备图标类型
+(void)getIconTypeFromCloudWithuDeviceId:(NSString *)udeviceId CompletionHandler:(void (^)(NSDictionary *result))result;

//获取设备图标 suffix传入字符串 "_ON" 或者 "_OFF" 代表开启动,关闭图标，用宏表示
+(NSString *)getIconUrlFromCloudWithIcon_name:(NSString *)iconName andSuffix:(NSString *)suffix;

//上传预置点图片
+(void)uploadPressPicFromCloudWithImgData:(NSData *)imgData andDevID:(NSString *)devId andPicName:(NSString *)picName progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result;

//获取预置点图片（云端）
+(NSString *)getPressPicFromCloudWithDevId:(NSString *)dev_id andPressName:(NSString *)pressName;

//删除预置点图片（云端）
+(void)deletePressPicFromCloudWithDevId:(NSString *)dev_id andPressName:(NSString *)pressName CompletionHandler:(void (^)(NSDictionary *result))result;

//获取485设备
+(void)get485DeviceFromCloud:(NSString *)cmd CompletionHandler:(void (^)(NSDictionary *result))result;

//获取485设备指令
+(void)get485CommandFromCloudWithDevId:(NSString *)z485Dev_Id CloudCompletionHandler:(void (^)(NSDictionary *result))result;


//获取485虚拟设备
+(void)get485VirtualDeviceFromCloudWithDevId:(NSString *)dev_Id CloudCompletionHandler:(void (^)(NSDictionary *result))result;


//获取IR设备
+(void)getIRDeviceFromCloudCompletionHandler:(void (^)(NSDictionary *result))result;


//获取IR品牌列表 type:all=全部、IR_AC=AC空调、IR_TV=TV、IR_TVBOX=TVBox电视机顶盒、IR_DVD=DVD、4=Projector投影仪、IR_CUSTOM=自定义
+(void)getIRBrandListFromCloudWithType:(NSString *)type BrandName:(NSString *)brandName CompletionHandler:(void (^)(NSDictionary *result))result;

//获取IR型号列表 type:all=全部、IR_AC=AC空调、IR_TV=TV、IR_TVBOX=TVBox电视机顶盒、IR_DVD=DVD、4=Projector投影仪、IR_CUSTOM=自定义
+(void)getIRTypeFromCloudWithBrandId:(NSString *)brandId Type:(NSString *)type CompletionHandler:(void (^)(NSDictionary *result))result;


//获取IR品牌型号
+(void)getIRBrandOrTypeFromCloudWithBrandOrType:(NSString *)brandOrType CompletionHandler:(void (^)(NSDictionary *result))result;

//获取IR开机数据 type:all=全部、IR_AC=AC空调、IR_TV=TV、IR_TVBOX=TVBox电视机顶盒、IR_DVD=DVD、4=Projector投影仪、IR_CUSTOM=自定义
+(void)getIRPowerOnDataFromCloudWithBrandId:(NSString *)brandId ModelId:(NSString *)modelId Type:(NSString *)type CompletionHandler:(void (^)(NSDictionary *result))result;

//获取IR匹配数据 type:all=全部、IR_AC=AC空调、IR_TV=TV、IR_TVBOX=TVBox电视机顶盒、IR_DVD=DVD、4=Projector投影仪、IR_CUSTOM=自定义
+(void)getIRMatchDataFromCloudWithType:(NSString *)type IRData:(NSString *)irData HouseIEEE:(NSString *)houseIeee CompletionHandler:(void (^)(NSDictionary *result))result;


//获取IR数据文件
+(void)getIRDataFromCloudWithBrandId:(NSString *)brandId ModelId:(NSString *)modelId CompletionHandler:(void (^)(NSDictionary *result))result;

    
//添加Lora设备
+(void)addDeviceWithLora:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result;

//第三方注册
+(void)registerBySocialFromCloudWithUser:(NSString *)userName Pwd:(NSString *)pwd
                          andnickName:(NSString *)nickName andRegcode:(NSString *) regcode andOpenId:(NSString *)openid andAccessToken:(NSString *)accessToken andPlatFrom:(NSString *)platfrom CompletionHandler:(void (^)(NSDictionary *result))result;

//第三方登录
+(void)loginBySocialFromCloudWithOpenId:(NSString *)openid andAccessToken:(NSString *)accessToken andPlatFrom:(NSString *)platfrom CompletionHandler:(void (^)(NSDictionary *result))result;

//第三方用户绑定
+(void)bindToSocialFromCloudWithUser:(NSString *)userName OpenId:(NSString *)openid andAccessToken:(NSString *)accessToken andPlatFrom:(NSString *)platfrom andBindCode:(NSString *)bindcode CompletionHandler:(void (^)(NSDictionary *result))result;

//分享家,生成简化内容
+ (void)shareHouseBriefContentWithDetail:(NSString *)detail CompletionHandler:(void (^)(NSDictionary *result))result;

//分享家,获取化简的内容
+ (void)getShareHouseDetailContentWithBrief:(NSString *)brief CompletionHandler:(void (^)(NSDictionary *result))result;





//          电能统计

//获取电能统计数据(startTime,endTime传入格式:YYYY-MM-DD,例如:2017-01-01 catalog =day按天返回， =mon 按月返回， = year 按年返回)
+(void)getEnergyStatFromCloudWithHouseIeee:(NSString *)houseIeee startTime:(NSString *)startTime endTime:(NSString *)endTime catalog:(NSString *)catalog CompletionHandler:(void (^)(NSDictionary *result))result;


//获取电能详细数据(startTime,endTime传入格式:YYYY-MM-DD,例如:2017-01-01 catalog =day按天返回， =mon 按月返回， = year 按年返回)（可能不用）
+(void)getEnergyDetailsFromCloudWithHouseIeee:(NSString *)houseIeee startTime:(NSString *)startTime endTime:(NSString *)endTime catalog:(NSString *)catalog CompletionHandler:(void (^)(NSDictionary *result))result;




//获取设备数据表 devid:设备id=uid attr_name:设备属性(temperature/humidity/ph...)  time_type:(day/month/year/range) time:(day:2018-05-01,month:2018-05,year:2018,range:2018-05-01,2018-05-02)
+(void)getAttrReportWithHouseIeee:(NSString *)houseIeee devid:(NSString *)devid attr_name:(NSString *)attr_name time_type:(NSString *)time_type time:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result;

//获取设备报表[批量] devids:[设备id=uid]数组 attr_name:设备属性(temperature/humidity/ph...)  time_type:(day/month/year/range) time:(day:2018-05-01,month:2018-05,year:2018,range:2018-05-01,2018-05-02)
+(void)getAttrReportBatchWithDevids:(NSArray *)devids andAttr_name:(NSString *)attr_name andTime_type:(NSString *)time_type andTime:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result;

//电能数据报表 devs:字典数组 [{dev_id :设备id , attr:电能属性名称(energy,a_energy,b_energy,c_energy)}] time_type:(day/month/year) time:(day:2018-05-01,month:2018-05,year:2018)
+(void)getEnergyReportWithHouseIeee:(NSString *)houseIeee devs:(NSArray *)devs time_type:(NSString *)time_type time:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result;

//电能数据详情表 devs:字典数组 [{dev_id :设备id , attr:电能属性名称(energy,a_energy,b_energy,c_energy)}] time_type:(day/month/year) time:(day:2018-05-01,month:2018-05,year:2018)
+(void)getEnergyDetailReportWithHouseIeee:(NSString *)houseIeee devs:(NSArray *)devs time_type:(NSString *)time_type time:(NSString *)time CompletionHandler:(void (^)(NSDictionary *result))result;

//             告警相关


//获取告警信息(startTime,endTime传入格式:YYYY-MM-DD,例如:2017-01-01)
+(void)getWarnMsgFromCloudWithHouseIeee:(NSString *)houseIeee startTime:(NSString *)startTime endTime:(NSString *)endTime pagenum:(int)pagenum pagesize:(int)pagesize CompletionHandler:(void (^)(NSDictionary *result))result;

//删除告警消息(startTime,endTime传入格式:YYYY-MM-DD,例如:2017-01-01)
+(void)deleteWarnMsgFromCloudWithHouseIeee:(NSString *)houseIeee startTime:(NSString *)startTime endTime:(NSString *)endTime CompletionHandler:(void (^)(NSDictionary *result))result;




//             用户相关


//添加网关
/**
 appid : 可选,应用版的appid 普通版可以不用传 传空""
 */
+(void)addShcFromCloudWithHouseIeee:(NSString *)houseIeee name:(NSString *)name Lng:(float)lng Lat:(float)lat Address:(NSString *)address andAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result;



//用户退出云端
+(void)logoutFromCloudCompletionHandler:(void (^)(NSDictionary *result))result;

//退出登录
+(void)logout;

//踢出
+(void)kickOut;

//上传用户头像(progress 为上传进度)
+(void)uploadPhotoFromCloudWithImgData:(NSData *)imgData progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result;

//获取用户信息（云端）
+(void)getUserMsgFromCloudCompletionHandler:(void (^)(NSDictionary *result))result;

//获取用户注册短信验证码 1注册新用户  2忘记密码  3第三方登录绑定
+(void)getRegcodeFromCloudWithMobile:(NSString *)mobile verifyType:(int)type andLang:(NSString *)lang CompletionHandler:(void (^)(NSDictionary *result))result;

//用户注册
+(void)regFromCloudWithUser:(NSString *)userName pwd:(NSString *)pwd nickname:(NSString *)nickname recode:(NSString *)regcode CompletionHandler:(void (^)(NSDictionary *result))result;

//查询用户是否注册
+(void)checkUserIsRegistFromCloudWithUser:(NSString *)userName CompletionHandler:(void (^)(NSDictionary *result))result;


//意见反馈  content内容 ext版本信息，无版本信息传""
+(void)suggestionFromCloudWithContent:(NSString *)content ImageDataArr:(NSArray *)imageDateArr Ext:(NSString *)ext progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result;


//用户找回密码
+(void)resetPwdFromCloudWithUser:(NSString *)userName newPwd:(NSString *)newPwd verifycode:(NSString *)verifycode CompletionHandler:(void (^)(NSDictionary *result))result;


//获取所有的家 pagesize 每页大小，不传查询所有  pagenum页码，不传查询所有
+(void)getHouseListWithUser:(NSString *)userName pagenum:(NSNumber *)pagenum pagesize:(NSNumber *)pagesize Cache:(BOOL) cache CompletionHandler:(void (^)(NSDictionary *result))result;

//修改用户信息
+(void)modifyUserInfoFromCloudWithNickname:(NSString *)nickname andPwd:(NSString *)pwd CompletionHandler:(void (^)(NSDictionary *result))result;

//  分享 相关
//共享家庭 permission 权限 devices 数组 和 functions 数组  0无权限，1所有权限 例如 所有权限 @{@"devices":@["0"],@"functions":@["1"]}
+(void)shareHouseFromCloudWithHouseIeee:(NSString *)houseIeee andInitiator:(NSString *)srcUser andPermission:(NSDictionary *)permission andAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result;

//删除分享家庭
+(void)deleteShareHouseFromCloudWithHouseIeee:(NSString *)houseIeee andShareUser:(NSString *)shareUser CompletionHandler:(void (^)(NSDictionary *result))result;


//获取分享记录
+(void)getShareRecordFromCloudWithPagenum:(int)pagenum pagesize:(int)pagesize houseIeee:(NSString *) houseIeee CompletionHandler:(void (^)(NSDictionary *result))result;


//转让
+(void)transferHouseFromCloudWithHouseIeee:(NSString *)houseIeee target_user:(NSString *)target_user CompletionHandler:(void (^)(NSDictionary *result))result;


//获取房间信息
+(void)getRoomlistWithHouseieee:(NSString *)houseIeee CompletionHandler:(void (^)(NSDictionary *result))result;

//       服务器 相关


//应用的接口
/**
 编号          模块名称                        备注
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
//获取用户应用
+(void)getListApplicationCompletionHandler:(void (^)(NSDictionary *result))result;

//修改用户应用
/**
 appid : 应用id(-1表示新增)
 name : 应用名称
 houses : 应用的家(不传则不更新)
 modules : 应用的模块(不传则不更新)
 
 */
+(void)updateApplicationWithAppid:(NSString *)appid andName:(NSString *)name andHouses:(NSArray *)houses andModules:(NSArray *)modules CompletionHandler:(void (^)(NSDictionary *result))result;

//删除用户应用
/**
 appid : 应用id

 */
+(void)delApplicationWithAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result;

//获取网关信息应用版
/**
 appid : 应用id
 */
+(void)getListHouseApplicationWithAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result;

//获取数据汇总设备列表
/**
 appid : 应用id
 house_ieee : 网关ieee，不传该字段表示全部网关
 moduleid : 模快的id
 
 */
+(void)getListDatapanelDevicesWithAppid:(NSString *)appid andHouseieee:(NSString *)house_ieee  andModuleid:(NSString *)moduleid CompletionHandler:(void (^)(NSDictionary *result))result;

//新增数据汇总设备
/**
 appid : 应用id
 moduleid : 模快的id
 devid : 设备id
 */
+(void)addDatapanelDeviceApplicationWithAppid:(NSString *)appid andModuleid:(NSString *)moduleid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result;


//删除数据汇总设备
/**
 appid : 应用id
 moduleid : 模快的id
 devid : 设备id
 */
+(void)delDatapanelDeviceApplicationWithAppid:(NSString *)appid andModuleid:(NSString *)moduleid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result;

//切换应用
/**
 appid : 切换到那个应用的appid
 houseieee : 切换到应用需要连接的家
 
 */
+ (void)changeApplicationWithAppid:(NSString *)appid andHouseieee:(NSString *)houseieee CompletionHandler:(void (^)(NSDictionary *result))result;


//地图相关接口

//获取区域列表
/**
 appid : 应用id

 */
+(void)getListLocationAreaWithAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result;

//新增区域
/**
 areaid : 区域id(-1表示服务器生成id,其他值表示直接使用客户端上传的id)
 appid : 应用id
 name : 名称
 imgData :上传的图片 转成jpg格式
 */
+(void)addLocationAreaWithImgData:(NSData *)imgData andAreaid:(NSString *)areaid andAppid:(NSString *)appid andName:(NSString *)name progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result;

//修改区域
/**
 areaid : 区域id(-1表示服务器生成id,其他值表示直接使用客户端上传的id)
 appid : 应用id
 name : 名称
 imgData :上传的图片 转成jpg格式
 */
+(void)updateLocationAreaWithWithImgData:(NSData *)imgData andAreaid:(NSString *)areaid andAppid:(NSString *)appid andName:(NSString *)name progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result;

//删除区域
/**
 areaid : 区域id(-1表示服务器生成id,其他值表示直接使用客户端上传的id)
 appid : 应用id
 name : 名称
 */
+(void)delLocationAreaWithareaid:(NSString *)areaid andAppid:(NSString *)appid CompletionHandler:(void (^)(NSDictionary *result))result;


//获取定位设备列表
/**
 appid : 应用id
 category : 类别(1=移动设备，2=坐标设备)
 */
+(void)getListLocationDeviceWithappid:(NSString *)appid andCategory:(NSString *)category  CompletionHandler:(void (^)(NSDictionary *result))result;

//添加定位设备
/**
 appid : 应用id
 devid : 设备id
 category : 类别(1=移动设备，2=坐标设备)
 areaid : 区域id
 */
+(void)addLocationDeviceWithappid:(NSString *)appid andDevid:(NSString *)devid andCategory:(NSString *)category andAreaid:(NSString *)areaid  CompletionHandler:(void (^)(NSDictionary *result))result;

//删除定位设备
/**
 appid : 应用id
 devid : 设备id

 */
+(void)delLocationDeviceWithappid:(NSString *)appid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result;


//设置基点位置
/**
 appid : 应用id
 info : 位置信息 数组字典 @[@{@"devid":@"",@"posx":@"",@"posy":@""}]
 devid : 设备id
 posx : x位置
 posy : y位置
 */
+(void)setLocationDeviceWithappid:(NSString *)appid andInfo:(NSArray *)info  CompletionHandler:(void (^)(NSDictionary *result))result;





//       天气相关

//获取天气环境指数
+(void)getWeatherFromCloudCompletionHandler:(void (^)(NSDictionary *result))result;


//获取皮肤列表  cache表示是否只读缓存数据
+(void)getSkinLsitFormCloudWithCache:(BOOL) cache CompletionHandler:(void (^)(NSDictionary *result))result;

//获取APK最新版本 type:ios-mobile/ios-pad
+(void)getVersionFormCloudWithType:(NSString *)type CustomerCode:(NSString *)code CompletionHandler:(void (^)(NSDictionary *result))result;

//上传崩溃日志
+(void)updataLogToCloudWithProxyIP:(NSString *)proxyIp ProxyPort:(int)proxyPort House:(NSString *)ieee User:(NSString *)userName IphoneType:(NSString *) iphoneType Resolution:(NSString *) resolution Memory:(NSString *)memory OsVer:(NSString *)osVer LogFile:(NSData *)file progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result;

//上传联动日志  operation execute/edit
+ (void)uploadRuleLogWithHouseieee:(NSString *)houseIeeee User:(NSString *)user Ruleid:(NSString *)ruleid Rulename:(NSString *)rulename Operation:(NSString *)operation progress:( void (^)(NSProgress *progress))progress CompletionHandler:(void (^)(NSDictionary *result))result;

//获取联动日志
+ (void)getListRuleLogWithHouseieee:(NSString *)houseIeee Starttime:(NSString *)starttime Endtime:(NSString *)endtime Pagenum:(NSNumber *)pagenum Pagesize:(NSNumber *)pagesize CompletionHandler:(void (^)(NSDictionary *result))result;

/*
                萤石摄像头接口(全部为https)
 
 
 **/

//萤石摄像头获取accessToken
+(void)YSGetAccessTokenWithAppKey:(NSString *)appKey appSecret:(NSString *)appSecret CompletionHandler:(void (^)(NSDictionary *result))result;

//萤石添加预置点
+(void)YSAddPresetWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo CompletionHandler:(void (^)(NSDictionary *result))result;

//调用预置点
+(void)YSMovePresetWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo index:(int)index CompletionHandler:(void (^)(NSDictionary *result))result;

//清除预置点
+(void)YSClearPresetWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo index:(int)index CompletionHandler:(void (^)(NSDictionary *result))result;

//设置摄像机指示灯开关(channelNo:传-1 表示设备本身)
+(void)YSSetLightSwitchWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo enable:(int)enable CompletionHandler:(void (^)(NSDictionary *result))result;

//获取摄像机指示灯开关状态
+(void)YSGetLightSwitchWithDeviceSerial:(NSString *)deviceSerial CompletionHandler:(void (^)(NSDictionary *result))result;

//获取声源定位开关状态
+(void)YSGetSslSwitchWithDeviceSerial:(NSString *)deviceSerial CompletionHandler:(void (^)(NSDictionary *result))result;

//设置声源定位开关(channelNo:传-1 表示设备本身)
+(void)YSSetSslSwitchWithDeviceSerial:(NSString *)deviceSerial channelNo:(int)channelNo enable:(int)enable CompletionHandler:(void (^)(NSDictionary *result))result;

#pragma mark -- 单设备接口
/**
 添加单设备
 appid : 应用id(默认是智能家居应用)
 devid : 设备id
 */
+(void)addDeviceWithAppid:(NSString *)appid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result;

/**
 删除单设备
 appid : 应用id
 devid : 设备id
 */
+(void)delDeviceWithAppid:(NSString *)appid andDevid:(NSString *)devid CompletionHandler:(void (^)(NSDictionary *result))result;

/**
 获取单设备的设备列表
 appid : 应用id
 roomid : 房间id
 devids : 设备id数组，空代表全部
 pagenum : 页码
 pagesize : 每页大小
 */
+(void)getListDeviceWithAppid:(NSString *)appid andRoomid:(NSString *)roomid andDevids:(NSArray *)dev_ids andPagenum:(NSString *)pagenum andPagesize:(NSString *)pagesize CompletionHandler:(void (^)(NSDictionary *result))result;
/**
 获取单个设备详情
 devid : 设备id
 */
+(void)getDetailsDeviceWithDevid:(NSString *)devid  CompletionHandler:(void (^)(NSDictionary *result))result;


/**
 修改单设备信息
 devid : 设备id
 roomid : 房间id
 name : 设备名称
 */
+(void)updateDevinfoWithDevid:(NSString *)devid andRoomid:(NSString *)roomid andName:(NSString *)name CompletionHandler:(void (^)(NSDictionary *result))result;

/**
 获取单设备的房间列表
 */
+(void)getListRoomsWithCompletionHandler:(void (^)(NSDictionary *result))result;

/**
 新增修改房间单设备
 id : 房间id(-1表示新增)
 name : 房间名称
 dev_ids : 设备id数组(新增房间可以不传设备)
 */
+(void)updateRoomInfoWithRoomid:(NSString *)roomid andName:(NSString *)name andDevids:(NSArray *)dev_ids CompletionHandler:(void (^)(NSDictionary *result))result;

/**
 删除单设备房间
 id : 房间id
 */

+(void)delRoomInfoWithRoomid:(NSString *)roomid  CompletionHandler:(void (^)(NSDictionary *result))result;

/**
 设备控制
 action    note     params
 set_threshold     设置阈值     [{"threshold":20}]
 send_command     发送命令     [{"command":"00101124121515511"}]
 devid : 设备id
 action : 设备动作
 params : 设备参数 [{参数名称:参数值}] @[@{@"name":@"",@"value":@""}]
 */
+ (void)controlDeviceWithDevid:(NSString *)devid andAction:(NSString *)action andParams:(NSArray *)params CompletionHandler:(void (^)(NSDictionary *result))result;

 
 




@end
