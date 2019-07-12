//
//  ViewController.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/16.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import "ViewController.h"
#import "NetvoxSocketManager.h"
#import "NetvoxCommon.h"
#import "NetvoxNetwork_Interface.h"
#import "SVProgressHUD.h"
#import "NetvoxUserInfo.h"
#import "NetvoxCallback.h"
#import "NetvoxDb.h"
#import "NetvoxMqtt.h"
#import "JRToast.h"
#import "MJExtension.h"
#import "NetvoxReachability.h"
#import "XMLDictionary.h"

#import "NetvoxNetwork-Swift.h"




#ifdef DEBUG
#define NSLog(format, ...) printf("\n[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

@interface ViewController ()
{
    NetvoxSocketManager *socketManager;
    
    NetvoxMqtt *mqtt;
    
    UILabel * msgLab;
    
    
    //MARK: - 萤石的APPkey
    NSString * APPKEY1 ;
    NSString *  APPSecret1 ;
    
    NSString * APPKEY2;
    NSString * APPSecret2 ;
    
    
}
//网络状态
@property (nonatomic,strong)NetvoxReachability *reachR;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    APPKEY1 = @"be88033debee49deaf47713c31655953";
    APPSecret1 = @"2d61c9b6d85f88293f40b1553f9aa5f0";
    APPKEY2 = @"0b69a4faedde4bf3a623e48270601cb8";
    APPSecret2 = @"a4ef01a41d709384cf2a94e153d3d39b";
//    [NetvoxUserInfo shareInstance];
    
//    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
//    //        网络状态通知
//    [notificationCenter addObserver:self selector:@selector(reachabilityChanged:) name:kNetvoxReachabilityChangedNotification object:nil];
//    
//    
//    self.reachR = [NetvoxReachability reachabilityForInternetConnection];
//    [self changeAlongWithReachability:self.reachR];
//    [self.reachR startNotifier];

    
    
//    NSString *deviceUUID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    
    msgLab = [[UILabel alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 30, [UIScreen mainScreen].bounds.size.width, 20)];
//    msgLab.text = [[NetvoxUserInfo shareInstance] getStringForKey:@"一" withTable:@"Localizable"];
    [self.view addSubview:msgLab];
    
    //注册callback通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callbackMsgNotice:) name:kCallbackReciveMsgNotification object:nil];
    

    
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)test:(UIButton *)sender {
    //mqtt 连接测试
//    mqtt = [NetvoxMqtt shareInstance];
//    //    [mqtt configWithHost:@"soweye.com" port:1883 clientId:[NSString stringWithFormat:@"ios_%@",deviceUUID] topic:[NSString stringWithFormat:@"/sh/sc/client/msg/%@/",deviceUUID] userName:@"15859269233" pwd:@"123456789"];
//    //    00137A00000384F3
//    //00137A000002EA2C
//    [mqtt configWithHost:@"192.168.1.243" port:1883 houseIeee:@"00137A00000384E1" userName:@"15859269233" pwd:@"123456"];
//    
//    
//    
//    NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
//    user.netConnect = connectTypeWide;//暂时设置为外网
//    
//    //打印测试(正常请使用接口调用)
//    user.isPrint = YES;
//    user.requstTime = 15;
//    
//    //设置服务器地址
//    user.userName = @"15859269233";
//    user.pwd = @"123456";
//    //
//    user.proxyIp = @"192.168.1.186";
//    user.proxyPort = 80;
//    
//    user.serverIp = @"192.168.1.247";
//    user.serverPort = 80;
//    
//    user.msgIp = @"192.168.1.243";
//    user.msgPort = 1883;
//    
//    NSLog(@"用户名:%@,密码:%@,家名字:%@,---%@",user.userName,user.pwd,user.houseName,user.houseArr);
//    
//    [mqtt connectCompletionHandler:^(NSDictionary *validateResult) {
//        NSLog(@"mqtt 连接结果:%@",validateResult);
//    }];
//
//    [JRToast showWithText:@"这是个测试" topOffset:70 duration:2];
    //00137A1000000A37
    //00137A0000042842
    //00137A00000384F2
    //00137A0000010136
    
    //00137A000003B1EC
    //00137A000002D509
    //00137A1000001F90
    [NetvoxNetwork connectToHouse:@"00137A0000010136" CompletionHandler:^(NSDictionary *result) {
        NSLog(@"切换网关结果:%@",result);
    }];
    
//    [NetvoxNetwork logout];
    
//    [NetvoxNetwork regFromCloudWithUser:@"475566949@qq.com" pwd:@"123456" nickname:@"nick" recode:@"773233" CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"%@",result);
//    }];
    
    
//    [NetvoxNetwork getRoomList:NO CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"获取房间:%@",result);
//    }];
    
//        [NetvoxNetwork getDeviceListDetailWithRoomid:@"-1" devicetype:nil dev_ids:@[@"-1"] pagenum:0 pagesize:INT_MAX cache:NO CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"设备详情列表=%@",result);
//        }];
//        
    
    int msgSize = [NetvoxDb getMsgCacheSize];
    NSLog(@"%d", msgSize);
    
}

- (IBAction)send:(UIButton *)sender {
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [SVProgressHUD show];
//        15160006563
//        439796
        //15859269233
        //475566949@qq.com
        NetvoxUserParam *param = [[NetvoxUserParam alloc]init];
        param.user = @"15606903130";
        param.pwd = @"123456";
        param.localIp = @"192.168.15.1";
        param.isPrint = YES; //打印日志
        param.isGetBackAuthority = YES; //更多返回权限
        param.isLocalConnectSocket = NO; //内网socket/http连接设置
        param.token = @"dcb94ee8d53379a7a508c470e3592548177fdf9d30e5df71ccaee19471d0a31a";
        
        
        NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
        //正式服务器云端地址
//        user.proxyIp = @"mng.netvoxcloud.com";
//        user.proxyPort = 80;
        //测试服务器云端地址
        user.proxyIp = @"mngtest.netvoxcloud.com";
//        user.proxyIp = @"mng.netvoxcloud.com"; //正式服务器
        user.proxyPort = 80;
//        user.serverIp = @"192.168.1.230";
//        user.proxyPort = 80;
//        user.msgIp = @"192.168.1.231";
//        user.proxyPort = 80;
//        
//        NetvoxUserInfo *user = [NetvoxUserInfo shareInstance];
//        user.proxyIp = nil;
//        user.proxyPort = 80;
//        user.serverIp = nil;
//        user.proxyPort = 80;
//        user.msgIp = nil;
//        user.proxyPort = 80;
//[mqtt configWithHost:user.msgIp port:user.msgPort houseIeee:user.currentHouseIeee userName:user.userName pwd:user.pwd];

        
        [NetvoxNetwork initWithUserParam:param CompletionHandler:^(NSDictionary *result) {
            NSLog(@"初始化结果:%@",result);
            
            [NetvoxNetwork loginWithTag:@"netvox" andIsLocal:NO CompletionHandler:^(NSDictionary *result) {
                NSLog(@"登陆:%@",result);
//                        [NetvoxNetwork getDeivceListDetailWithRoomid:@"-1" devicetype:nil dev_ids:@[@"-1"] pagenum:0 pagesize:INT_MAX cache:NO  CompletionHandler:^(NSDictionary *result) {
//                            NSLog(@"设备详情列表=%@",result);
//
//                        }];
//                [NetvoxNetwork getHouseListWithUser:param.user pagenum:0 pagesize:0 Cache:NO CompletionHandler:^(NSDictionary *result) {
//                    NSLog(@"%@",result);
//                }];
//
//                            [SVProgressHUD dismiss];
                
                
                
                
            }];
             }];

    });

       
   

    

}
- (IBAction)connect:(UIButton *)sender {
    
//    int count =4000;
//    for (int i=0; i<100000; i++) {
//        [NetvoxDb insert:TABLE_MSG data:@{@"id":[NSString stringWithFormat:@"%d",count],@"type":@"1134",@"time":@"2017-07-17 12:00:09",@"update_flag":@"0",@"warn_type":@"2000004",@"dev_id":@"20"}];
//        count++;
//    }
    NSLog(@"消息大小:%.1f",[NetvoxDb getMsgCacheSize]);

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//    [NetvoxNetwork getVersionFormCloudWithType:@"ios-mobile" CustomerCode:@"netvox" CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"获取新版本:%@",result);
//    }];
        //18135054601
//    [NetvoxNetwork getHouseListWithUser:@"15606903130" Cache:NO CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"获取所有的家结果:%@",result);
//        UIImage *img1 = [UIImage imageNamed:@"大图"];
//        NSData *imgData1 = UIImageJPEGRepresentation(img1, 1);
//        UIImage *img2 = [UIImage imageNamed:@"大图"];
//        NSData *imgData2 = UIImageJPEGRepresentation(img2, 1);
//        UIImage *img3 = [UIImage imageNamed:@"大图"];
//        NSData *imgData3 = UIImageJPEGRepresentation(img3, 1);
//        NSArray * arr = @[imgData1,imgData2,imgData3];
//        NSArray * arr2 = @[imgData1];
//        [NetvoxNetwork uploadPhotoFromCloudWithImgData:imgData progress:^(NSProgress *progress) {
//                        NSLog(@"%@",progress);
//                    } CompletionHandler:^(NSDictionary *result) {
//                        NSLog(@"上传用户头像结果:%@",result);
//        }];
//        [NetvoxNetwork suggestionFromCloudWithContent:@"你好" ImageDataArr:arr Ext:@"1" progress:^(NSProgress *progress) {
//            NSLog(@"%@",progress);
//        } CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"意见反馈结果:%@",result);
//        }];
       
//        NSMutableArray * array = [NSMutableArray arrayWithCapacity:1];
//        [NetvoxNetwork getDeviceListDetailWithRoomid:@"-1" devicetype:@"" dev_ids:@[@"-1"] pagenum:0 pagesize:200 cache:false CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"设备详情列表=%@",result);
////            [array addObject:result[@"result"]];
////            [array addObjectsFromArray:result[@"result"]];
//        }];

//        [NetvoxNetwork getRoomlistWithHouseieee:[NetvoxUserInfo shareInstance].currentHouseIeee CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"result = %@ ",result);
//        }];
//        [NetvoxNetwork getListApplicationCompletionHandler:^(NSDictionary *result) {
//            NSLog(@"result,%@",result);
//        }];
        
//        [NetvoxNetwork setLocationDeviceWithappid:@"57af1e82c18d4c28bc813a5500074e1e" andInfo:@[@{@"devid":@"00137A000001D12903",@"posy":@"547.0",@"posx":@"594.0"}] CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"%@",result);
//        }];
        
//        [NetvoxNetwork getAttrReportWithHouseIeee:@"00137A0000010136" devid:@"00137A00000066A40A" attr_name:@"temperature" time_type:@"day" time:@"2019-03-23" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取报表请求 = %@",result);
//        }];
        
//        NSDictionary * dic = @{@"dev_id":@"00137A00000067210A",@"attr":@"energy"};
//        [NetvoxNetwork getEnergyReportWithHouseIeee:@"00137A0000010136" devs:@[dic] time_type:@"month" time:@"2019-04" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取电能 = %@",result);
//        }];
//        [NetvoxNetwork getEnergyDetailReportWithHouseIeee:@"00137A0000010136" devs:@[dic] time_type:@"month" time:@"2019-04" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取电能详情 = %@",result);
//        }];
        
        
//        [NetvoxNetwork setConfigWithHouseName:nil encryptKey:nil wifiPwd:@"12345678" wifiName:@"Netvox_CSHC_84F2" wifiPwdEncrypt:@"TKIPAES" hwVersion:nil manageServer:nil timestampEnable:-1 timestampAviableTime:-1 callbackAuth:-1 filterDev:-1 driver_mode:-1 zbchannel:-1 CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"设置系统配置信息=%@",result);
//        }];
        
//        [NetvoxNetwork getConfigCompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取系统配置信息=%@",result);
//        }];
        

//        NetvoxDeviceParam *param = [[NetvoxDeviceParam alloc]init];
//         param.ir_check_mode = @"pironly";
//         [NetvoxNetwork setParamWithId:@"00137A000004283901" param:param CompletionHandler:^(NSDictionary *result) {
//             NSLog(@"设置参数结果:%@",result);
//         }];
//        [NetvoxNetwork deleteDeviceWithId:@"00626E54E8FC" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"删除设备结果:%@",result);
//        }];
//        [NetvoxNetwork get485DeviceFromCloudCompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取485设备:%@",result);
//        }];
        
//        [NetvoxNetwork sendSpdevCommandWithDevid:@"00137A0000009B680A" cmdType:@"zl01j" command:@"020FD80702EF2C00137A0000009B68FE601401" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"大金空调发送请求 %@",result);
//        }];
        
        
        
//        [NetvoxNetwork getIRDeviceFromCloudCompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取IR设备:%@",result);
//        }];
//        [NetvoxNetwork addSpdeviceWithUdeviceid:@[@"SP_AC_DJ24"] Spdevice:@"00137A0000009B680A" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"添加485设备 %@",result);
//        }];
//        [NetvoxNetwork getListSpdevkeyWithDevid:@"00137A0000009B680A_1" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取485按键设备 %@",result);
//        }];
        
//        [NetvoxNetwork downloadRuleCompletionHandler:^(NSDictionary *downloadresult) {
//            NSLog(@"下载规则:%@",downloadresult);
//            NSString * result = downloadresult[@"result"];
//            if ([downloadresult[@"status_code"]intValue] == 0)
//            {
//                NSArray * xmlAry = [result componentsSeparatedByString:@"<WITH>"];
//                NSDictionary * dic = [NSDictionary dictionaryWithXMLString:xmlAry.firstObject];
//                NSLog(@"规则:%@",dic);
//                NSDictionary * head = dic[@"Rule"];
//                NSLog(@"%@",head)
//            }
//            [NetvoxNetwork uploadRuleWithString:[downloadresult objectForKey:@"result"] CompletionHandler:^(NSDictionary *uploadresult) {
//                NSLog(@"上传规则:%@",uploadresult);
//            }];
//        }];

        
//        [NetvoxNetwork getListRuleLogWithHouseieee:@"00137A00000384F2" Starttime:@"2018-09-09 10:28:06" Endtime:@"2018-09-10 10:28:06" Pagenum:@1 Pagesize:@10 CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"%@",result);
//        }];
        
//        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"];
//        NSLog(@"%@", path);
        //日志
//          NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"];
//         NSString * path1 = [path stringByAppendingString:@"/log11.txt"];
//          NSLog(@"%@",path1);
//          NSData * da = [NSData dataWithContentsOfFile:path1];
//          [NetvoxNetwork updataLogToCloudWithProxyIP:@"test.mng.netvoxcloud.com" ProxyPort:80 House:@"000137A00000384E" User:@"18760021345" IphoneType:@"a" Resolution:@"axa" Memory:@"100" OsVer:@"1" LogFile:da progress:nil CompletionHandler:^(NSDictionary *result) {
//              NSLog(@"日志上传:%@",result);
//          }];
//
//          [NetvoxNetwork searchDeviceWithDeviceType:@"1002001" Time:@"-1" CompletionHandler:^(NSDictionary *result) {
//              NSLog(@"设备搜索:%@",result);
//          }];
//
//            [NetvoxNetwork getRoomList:NO CompletionHandler:^(NSDictionary *result) {
//                                NSLog(@"获取房间:%@",result);
        

//            [NetvoxNetwork getSkinLsitFormCloudWithCache:NO CompletionHandler:^(NSDictionary *result) {
//                NSLog(@"获取皮肤列表=%@",result);
//            }];
//                [NetvoxNetwork getWarnMsgFromCloudWithHouseIeee:@"00137A1000000A37" startTime:@"2018-05-13" endTime:@"2018-05-17" pagenum:1 pagesize:INT_MAX CompletionHandler:^(NSDictionary *result) {
//                    NSLog(@"获取告警消息列表 = %@",result);
//                }];
        
//                [NetvoxNetwork getDeviceListWithRoomid:@"-1" devicetype:@"" pagenum:0 pagesize:150 cache:NO CompletionHandler:^(NSDictionary *result) {
//                                    NSLog(@"设备列表=%@",result);
//
//                }];
//
//            }];
        
        
//        [NetvoxNetwork YSGetAccessTokenWithAppKey:APPKEY1 appSecret:APPSecret1 CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"%@", result);
//        }];
        

//        [NetvoxNetwork getConfigCompletionHandler:^(NSDictionary *result) {
//            NSLog(@"%@",result);
//        }];
        
        
//            [NetvoxNetwork getCurrentMeidaDetailWithId:@"BGM_CNWISE_WISE-BM206-TFANBTR" CompletionHandler:^(NSDictionary *result) {
//                NSLog(@"获取当前媒体信息:%@",result);
//            }];
//            [NetvoxNetwork commandControlWithText:@"12s号" CompletionHandler:^(NSDictionary *result) {
//                NSLog(@"文本控制:%@",result);
//            }];
        
        [NetvoxNetwork getDeviceListDetailWithRoomid:@"-1" devicetype:nil dev_ids:@[@"-1"] pagenum:0 pagesize:INT_MAX cache:NO CompletionHandler:^(NSDictionary *result) {
            NSLog(@"设备详情列表=%@",result);
            
        }];
        
//        [NetvoxNetwork getDeviceDetailWithDev_id:@"00137A1000000A32" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"单个设备详情=%@",result);
//        }];
        
//        }];
//
//        [NetvoxNetwork getDeviceListFromCloudWithHouseIeee:@"00137A00000384E1" roomid:-1 pagenum:0 pagesize:100 CompletionHandler:^(NSDictionary *result) {
//             NSLog(@"云端获取设备结果:%@",result);
//        }];
        
//        [NetvoxNetwork shareHouseFromCloudWithHouseIeee:@"00137A00000384F2" andInitiator:@"15606903130" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"%@",result);
//        }];
                     
//                     
//      [NetvoxNetwork getWeatherFromCloudCompletionHandler:^(NSDictionary *result) {
//          NSLog(@"获取天气环境指数=%@",result);
//      }];
        
//        [NetvoxNetwork getUserInfoCompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取用户列表结果:%@",result);
//        }];

//        [NetvoxNetwork addUserWithUser:@"ios6" pwd:@"123456" phone:[NetvoxUserInfo shareInstance].phone permissionRoomIds:@[@"0"] denyRoomIds:@[] permissionModules:@[] denyModules:@[] CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"添加用户结果:%@",result);
//        }];
        
//        [NetvoxNetwork getRegcodeFromCloudWithMobile:@"15960297960" verifyType: 1 CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"获取验证码结果:%@",result);
//        }];
//
//        UIImage *img = [UIImage imageNamed:@"abc"];
//        NSData *imgData = UIImageJPEGRepresentation(img, 0.8);
//        [NetvoxNetwork uploadPhotoFromCloudWithImgData:imgData progress:^(NSProgress *progress) {
//            NSLog(@"%@",progress);
//        } CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"上传用户头像结果:%@",result);
//        }];
        
//        [NetvoxNetwork setlevelWithId:@"2" level:100 CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"调级结果:%@",result);
//        }];
        
        
        
//        [NetvoxNetwork addRoomWithName:@"roomTest" dev_id:@[@"27"] CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"添加房间:%@",result);
        [NetvoxNetwork getRoomList:NO CompletionHandler:^(NSDictionary *result) {
                NSLog(@"获取房间:%@",result);


            }];
        
        
        
            
            
        
//        [NetvoxNetwork updateRoomInfoWithId:2 name:nil dev_id:@[@"37",@"2",@"38",@"39"] CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"删除结果:%@",result);
//        }];
//
//        [NetvoxNetwork updateDevInfoWithId:@"12" name:nil roomid:@"10" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"修改设备房间结果:%@",result);
           
//
            
//        }];


//        }];
        
        
//        [NetvoxNetwork updateRoomInfoWithId:6 name:@"mofifyName" dev_id:@[@"27"] CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"修改房间:%@",result);
//            [NetvoxNetwork getDeviceListWithRoomid:@"-1" devicetype:@"" pagenum:0 pagesize:20 cache:NO CompletionHandler:^(NSDictionary *result) {
//                NSLog(@"设备列表=%@",result);
//                
//            }];
//        }];
        
//        [NetvoxNetwork deleteRoomWithId:9 CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"删除房间:%@",result);
//            [NetvoxNetwork getDeviceListWithRoomid:@"-1" devicetype:@"" pagenum:0 pagesize:20 cache:NO CompletionHandler:^(NSDictionary *result) {
//                NSLog(@"设备列表=%@",result);
//                
//            }];
//
//        }];
        
//        [NetvoxNetwork updateDevInfoWithId:@"2" name:@"我们1314" roomid:nil CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"修改房间:%@",result);
//            
//        }];
        
//        [NetvoxNetwork getDeviceListWithRoomid:@"-1" devicetype:@"" pagenum:0 pagesize:20 cache:NO CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"设备列表=%@",result);
//
//        }];
        
//    [NetvoxNetwork getIconTypeFromCloudWithuDeviceId:@"ZL01GE3R_0102_01" CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"获取设备图标类型=%@",result);
//    }];

//        [NetvoxNetwork getDeivceListDetailWithRoomid:@"-1" devicetype:nil dev_ids:@[@"-1"] pagenum:0 pagesize:50 cache:NO  CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"设备详情列表=%@",result);
////            if ([result[@"status_code"] intValue] == 0) {
////                NSArray *arr = result[@"result"];
////                for (NSDictionary *dic in arr) {
////                    if ([dic[@"uid"] intValue] == 2) {
////                        int fre = [dic[@"fre"] intValue];
////                        fre++;
////                        [NetvoxDb update:TABLE_DEVICE conditions:@[@{@"key":@"uid",@"value":@"2",@"op":@"="},@{@"key":@"house_ieee",@"value":@"00137A00000384E1",@"op":@"="}] updates:@[@{@"key":@"fre",@"value":[NSString stringWithFormat:@"%d",fre]}]];
////                    }
////                }
////            }
//        }];
//        00137A00000384E1
//        [NetvoxNetwork getDeviceDetailWithDev_id:@"30" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"设备详情:%@",result);
//        }];
        
//        [NetvoxNetwork onWithId:@"2" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"开=%@",result);
//        }];
        
//        [NetvoxNetwork offWithId:@"2" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"关=%@",result);
//        }];
//        
//        [NetvoxNetwork toggleWithId:@"2" CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"toggle=%@",result);
//        }];

//      [NetvoxNetwork setlevelWithId:@"2" level:100 CompletionHandler:^(NSDictionary *result) {
//          NSLog(@"调级=%@",result);
//      }];
        
                     
//         [NetvoxNetwork getRuleListWithType:@"all" CompletionHandler:^(NSDictionary *result) {
//             NSLog(@"获取规则 = %@",result);
//         }];
        
                     
//     [NetvoxNetwork modifyUserInfoFromCloudWithNickname:@"nysnys" andPwd:nil CompletionHandler:^(NSDictionary *result) {
//         NSLog(@"修改用户信息 = %@",result);
//     }];
//
    });
    
//    [NetvoxNetwork YSGetAccessTokenWithAppKey:@"be88033debee49deaf47713c31655953" appSecret:@"2d61c9b6d85f88293f40b1553f9aa5f0" CompletionHandler:^(NSDictionary *result) {
//        NSString *msg = result[@"msg"];
//        NSLog(@"accessToken=%@,msg=%@",result,msg);
//    }];
////
//    [NetvoxNetwork getDeviceListWithRoomid:@"-1" devicetype:@"" pagenum:1 pagesize:20 cache:NO CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"设备列表=%@",result);
//        
//    }];
    
    
//    [NetvoxNetwork getDeviceRecordFromCloudWithHouseIeee:nil dev_id: @"89" pagenum:0 pagesize:INT_MAX CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"获取设备操作历史=%@",result);
//    }];
    
//    [NetvoxNetwork getEnergyStatFromCloudWithHouseIeee:@"00137A00000384E1" startTime:@"2017-01-01" endTime:@"2017-08-10" catalog:@"mon" CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"获取电能统计数据=%@",result);
//    }];
    
    
//    [NetvoxNetwork getWarnMsgFromCloudWithHouseIeee:@"00137A00000384E1" startTime:@"2017-01-01" endTime:@"2017-08-10" pagenum:0 pagesize:INT_MAX CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"获取告警消息列表 = %@",result);
//    }];

//    [NetvoxNetwork deleteWarnMsgFromCloudWithHouseIeee:@"00137A00000384E1" startTime:@"2017-08-10" endTime:@"2017-08-11" CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"删除告警消息 = %@",result);
//    }];

//    [NetvoxNetwork addShcFromCloudWithHouseIeee:@"00137A000002D50E" name:@"15960297960"  CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"添加网关（关联网关） = %@",result);
//    }];
    
   
    
//   NSLog(@"数据库测试:%@",[NetvoxDb getMsgCacheSize]);
    
}

#pragma mark--callback
-(void)callbackMsgNotice:(NSNotification *)notification
{
    NSDictionary *msg= notification.userInfo;
    NSLog(@"callback=%@",msg);
    
    NSString *type = [NSString stringWithFormat:@"%d",[[msg objectForKey:@"type"] intValue]];
    //告警消息处理
    if ([type intValue] == 20001) {
        NSLog(@"告警消息内容:%@",[NetvoxDb query:TABLE_MSG addArr:nil orArr:nil orderDic:nil limitDic:nil]);
    }
    
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark-- 网络状态监听
//网络状态变化
-(void)reachabilityChanged:(NSNotification *)noti
{
    
    
    NetvoxReachability *reach = [noti object];
    
    //    NSParameterAssert([reach isKindOfClass:[Reachability class]]);
    if ([reach isKindOfClass:[NetvoxReachability class]]) {
        [self changeAlongWithReachability:reach];
    }
    
    
}

//网络判断
-(void)changeAlongWithReachability:(NetvoxReachability *)reach
{
    NetvoxNetworkStatus sta = [reach currentReachabilityStatus];
    
    switch (sta) {
        case ReachableViaWiFi:
            //wifi
            NSLog(@"wifi");
            
            break;
        case ReachableViaWWAN:
            //蜂窝数据
            NSLog(@"蜂窝数据");
            
            break;
            
        default:
            //无网络
           NSLog(@"无网络");
            
            break;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)English:(id)sender {
    //解析xml
//    NSMutableArray * array = [NSMutableArray arrayWithCapacity:1];
//    [NetvoxNetwork getDeviceListDetailWithRoomid:@"-1" devicetype:@"" dev_ids:@[@"-1"] pagenum:1 pagesize:100 cache:false CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"设备详情列表=%@",result);
//        //            [array addObject:result[@"result"]];
//        [array addObjectsFromArray:result[@"result"]];
//    }];
    [NetvoxNetwork changeApplicationWithAppid:@"cc6aef73d578492f82708e0c7e2179e5" andHouseieee:@"" CompletionHandler:^(NSDictionary *result) {
        NSLog(@"%@",result);
    }];
    
    
}

- (IBAction)jianti:(id)sender {
    NetvoxUserInfo * user = [NetvoxUserInfo shareInstance];
    
//    [NetvoxNetwork addLocationAreaWithImgData:nil andAreaid:@"-1" andAppid:@"cc6aef73d578492f82708e0c7e2179e5" andName:@"6.25tst" progress:^(NSProgress *progress) {
//        NSLog(@"%@",progress);
//    } CompletionHandler:^(NSDictionary *result) {
//        NSLog(@"%@",result);
//    }];
    [NetvoxNetwork updateLocationAreaWithWithImgData:nil andAreaid:@"204a6fa86ee443539fc1a5349a6c77be" andAppid:@"cc6aef73d578492f82708e0c7e2179e5" andName:@"6.25的test" progress:^(NSProgress *progress) {
        NSLog(@"%@",progress);
    } CompletionHandler:^(NSDictionary *result) {
        NSLog(@"%@ ",result);
    }];
    
//    [user changeNowLanguage:1];
//    msgLab.text = [[NetvoxUserInfo shareInstance] getStringForKey:@"二" withTable:@"Localizable"];
   
//    NSMutableArray * addArr = [NSMutableArray arrayWithCapacity:1];
//
//    [addArr addObject:@{@"key":@"request_time",@"value":@"2019-03",@"op":@"="}];
//
//    //按照时间取出
//    NSDictionary * orderDic = @{@"key":@"request_time",@"op":@"asc"};
//
//    NSDictionary * dic = [NetvoxDb query:TABLE_REPORT addArr:addArr orderDic:orderDic];
//    NSLog(@"%@",dic);
//
//    NSDictionary * result = dic[@"result"];
//    NSArray * array = result[@"value"];
//    for (int i = 0; i<= array.count; i++) {
//        NSLog(@"%@",array[i]);
//    }
    
    
    
}

- (IBAction)fanti:(id)sender {
    NetvoxUserInfo * user = [NetvoxUserInfo shareInstance];
//    [user changeNowLanguage:2];
//    msgLab.text = [[NetvoxUserInfo shareInstance] getStringForKey:@"一" withTable:@"Localizable"];
//
//    [NetvoxNetwork getWarnMsgFromCloudWithHouseIeee:@"00137A0000010136" startTime:@"2019-03-20" endTime:@"2019-03-22" pagenum:0 pagesize:100 CompletionHandler:^(NSDictionary *result) {
//
//
//
//    }];
    
    DictionAction * dic = [[DictionAction alloc]init];
    
    
    
    
    
    
    
    
    
    
}
- (IBAction)gethouse:(id)sender {
    [NetvoxNetwork getHouseListWithUser:@"475566949@qq.com" pagenum:@0 pagesize:@0 Cache:NO CompletionHandler:^(NSDictionary *result) {
        NSLog(@"获取所有的家结果:%@",result);
        
//        [NetvoxNetwork shareHouseFromCloudWithHouseIeee:@"00137A0000010136" andInitiator:@"15606903130" andPermission:@{@"devices":@{@"all":@"1"},@"functions":@{@"all":@"1"}} CompletionHandler:^(NSDictionary *result) {
//            NSLog(@"REULT %@",result);
//        }];
    
//        DictionAction * dict = [[DictionAction alloc]init];
//        [dict request];
        
        
    }];
    
    
}


-(void)convertHexDataForString:(NSString *)data{
    
    

}

@end
