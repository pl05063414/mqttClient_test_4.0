//
//  NetvoxNetworkModel.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/7/4.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  请求模型

#import <Foundation/Foundation.h>
#import "NetvoxUserInfo.h"





@interface NetvoxNetworkModel : NSObject

typedef NS_OPTIONS(NSUInteger, netvoxNetworkType) {
    
    netvoxNetworkTypeCGI               = 1 << 0,//CGI请求
    netvoxNetworkTypeHttpGet           = 1 << 1,//http/https Get请求
    netvoxNetworkTypeHttpPost          = 1 << 2, //http/https Post请求
    netvoxNetworkTypeYSHttpGet         = 1 << 3, //萤石http/https Get请求
    netvoxNetworkTypeYSHttpPost        = 1 << 4, //萤石http/https Post请求
    netvoxNetworkTypeUpload            = 1 << 5,  //上传请求到云端
    netvoxNetworkTypeCGIUpload         = 1 << 6  //上传文件到CGI
    
};

typedef void (^ uploadProgress)(NSProgress *progress);

//请求url
@property (nonatomic,strong)NSString *url;

//请求方式
@property (nonatomic,assign)netvoxNetworkType networkType;

//type
@property (nonatomic,assign)int type;

//是否不加密(默认加密)
@property (nonatomic,assign)BOOL isNotEncrypt;

//用户模型
@property (nonatomic,strong)NetvoxUserInfo *user;


//参数(NSString)
@property (nonatomic,strong)NSString *param;

//参数(NSDictionary)
@property (nonatomic,strong)NSDictionary *params;

//file(上传到网关接口)
@property (nonatomic,strong)NSString *file;

//fileName(上传云端接口)
@property (nonatomic,strong)NSMutableArray * fileNameArray;

//formData1(上传云端接口)
@property (nonatomic,strong)NSMutableArray * formDataArray;

//mimeType(上传云端接口)
@property (nonatomic,strong)NSMutableArray *mimeTypeArray;

//上传进度(上传云端接口)
@property (nonatomic,copy)uploadProgress progress;

@end
