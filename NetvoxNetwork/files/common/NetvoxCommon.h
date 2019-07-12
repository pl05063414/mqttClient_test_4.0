//
//  NetvoxCommon.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/22.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  公用方法

#import <Foundation/Foundation.h>


@interface NetvoxCommon : NSObject

//获取毫秒数
+ (NSString *)getMs;

//md5加密
+ (NSString *) md5:(NSString *) input;

//字典转json数据
+(NSData *)dicToJsonData:(NSDictionary *)dict;

//请求返回字符串处理
+(NSDictionary *)screenData:(NSString *)str;


//生成唯一标识符
+(NSString *) getUuid;

//字符串数组转json格式字符串
+(NSString *)strToJsonStr:(NSArray *)aArr;

//字符串数组转json格式int
+(NSString *)strToJsonInt:(NSArray *)aArr;

//crc16转换
+(int16_t)crc16With:(NSData *)data;

//打印控制
+(void)print:(NSString *)format, ...;



//gzip压缩
+(NSData *)gzipCompress:(NSData *)data;

//gzip解压
+(NSData *)gzipDecompress:(NSData *)data;
//tar解压
+(BOOL)tarDecompress:(NSData *)data Path:(NSString *)path;
//tar压缩
+(BOOL)tarCompress:(NSString *)tarFromPath Topath:(NSString *)path;

//字符串data转NSData
+ (NSData *)convertHexStrToData:(NSString *)str;

//NSData变成不带<>和空格的字符串
+(NSString *)convertNSDataToNSString:(NSData *)data;

//判断是否是中文
+(BOOL)isChinese:(NSString *)str;

//判断是否含有中文
+(BOOL)includeChinese:(NSString *)str;

//更新本地皮肤数据
+(void)updateSkin:(NSArray *)array;

//十六进制异或解密
+(void)xorDecode:(NSData *)file andIntoPath:(NSString *)path;

//删除指定文件或文件夹
+(BOOL)deleteFileWithName:(NSString *)fileName;



/**判断是否ipv6连接网络*/
+ (BOOL)isIpv6;
/**根据传进来的dev_id判断是什么设备返回单个设备详情**/
+ (NSDictionary *)resultDeviceDetail:(NSString *)dev_id;
/**根据传进来的aResult返回设备详情**/
+ (NSArray *)arrayForDeviceListDictionary;


/**异或加密解密*/
+(NSString *)checkWithBCC:(NSString *)checkStr;

/**字典转化字符串*/
+(NSString*)dictionaryToJson:(NSDictionary *)dic;
/**字符串转字典*/
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
