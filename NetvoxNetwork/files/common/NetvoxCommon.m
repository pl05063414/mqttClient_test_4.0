//
//  NetvoxCommon.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/5/22.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import "NetvoxCommon.h"
#import <CommonCrypto/CommonDigest.h>
#import "NetvoxUserInfo.h"
#import "NetvoxTar.h"
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <UIKit/UIKit.h>

@implementation NetvoxCommon
#pragma mark--获取当前毫秒数(时间戳与时区无关)
+ (NSString *)getMs
{
    NSString *ms = @"";
    
    NSDate *date = [NSDate date];
   
    ms = [NSString stringWithFormat:@"%.f",date.timeIntervalSince1970*1000];
    return ms;
}

#pragma mark--MD5加密(以后单独封装文件)
+ (NSString *) md5:(NSString *) input {
    
    const char *cStr = [input UTF8String];
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        
        [output appendFormat:@"%02x", digest[i]];
    
    
    
    return  output;
    
}

#pragma mark--字典转json数据
+(NSData *)dicToJsonData:(NSDictionary *)dict
{
    // 如果数组或者字典中存储了  NSString, NSNumber, NSArray, NSDictionary, or NSNull 之外的其他对象,就不能直接保存成文件了.也不能序列化成 JSON 数据.
    
    //    NSString *strData = @"";
    NSData * jsonData = [[NSData alloc] init];
    // 1.判断当前对象是否能够转换成JSON数据.
    // YES if obj can be converted to JSON data, otherwise NO
    BOOL isYes = [NSJSONSerialization isValidJSONObject:dict];
    
    if (isYes) {
        //        NSLog(@"可以转换");
        
        /* JSON data for obj, or nil if an internal error occurs. The resulting data is a encoded in UTF-8.
         */
        jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:NULL];
        
        /*
         Writes the bytes in the receiver to the file specified by a given path.
         YES if the operation succeeds, otherwise NO
         */
        // 将JSON数据写成文件
        // 文件添加后缀名: 告诉别人当前文件的类型.
        // 注意: AFN是通过文件类型来确定数据类型的!如果不添加类型,有可能识别不了! 自己最好添加文件类型.
        
        //        strData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    } else {
        
        NSLog(@"JSON数据生成失败，请检查数据格式");
        
    }
    
    //    NSData *sendData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    return jsonData;
}
#pragma mark--字符串操作
//字符串操作
+(NSDictionary *)screenData:(NSString *)str
{
    NSDictionary *obj = nil;
    
    long m = -1,n = [str length];
    
    for (long i = 0; i < [str length]; i++) {
        NSString *sub = [str substringWithRange:NSMakeRange(i, 1)];
        if([sub isEqualToString:@"{"]){
            
            break;
            
        }
        
        if ([sub isEqualToString:@"("]) {
            m = i;
            break;
        }
    }
    
    NSString *newStr = [str substringFromIndex:m + 1];
    
    for (long j = [newStr length] - 1; j < [newStr length]; j--) {
        
        if (m == -1) {
            
            break;
            
        }
        
        NSString *sub = [newStr substringWithRange:NSMakeRange(j, 1)];
        if ([sub isEqualToString:@")"]) {
            n = j;
            break;
        }
    }
    
    
    //    if (newStr.length-1<n) {
    //        return nil;
    //    }
    NSString *subStr = [newStr substringToIndex:n];
    
    //将括号里的部分转换成data
    NSData *response = [subStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //将data转换成dic
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:nil];
    
    obj = dic;
    
    return obj;
}

#pragma mark--生成唯一标识符
//生成唯一标识符
+(NSString *) getUuid
{
    CFUUIDRef ref = CFUUIDCreate(NULL);
    CFStringRef stringRef= CFUUIDCreateString(NULL, ref);
    CFRelease(ref);
    
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)stringRef];
    CFRelease(stringRef);
    return uuid;
}

#pragma mark--字符串数组转json格式
//字符串数组转json格式字符串
+(NSString *)strToJsonStr:(NSArray *)aArr
{
    NSMutableString *mStr = [[NSMutableString alloc]initWithCapacity:2];
    
    for (NSString *str in aArr) {
        
        [mStr appendFormat:@"\"%@\",",str];
        
    }
    NSString *aStr=@"";
    if (mStr.length!=0) {
        aStr =[mStr substringToIndex:mStr.length - 1];
    }
    return aStr;
}

//字符串数组转json格式int
+(NSString *)strToJsonInt:(NSArray *)aArr
{
    NSMutableString *mStr = [[NSMutableString alloc]initWithCapacity:2];
    
    for (NSString *str in aArr) {
        
        [mStr appendFormat:@"%@,",str];
        
    }
    NSString *aStr=@"";
    if (mStr.length!=0) {
        aStr =[mStr substringToIndex:mStr.length - 1];
    }
    return aStr;
 
}

#pragma mark--crc16转换

static const unsigned short crc16tab[256] = { 0x0000, 0x1021, 0x2042, 0x3063,
    0x4084, 0x50a5, 0x60c6, 0x70e7, 0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c,
    0xd1ad, 0xe1ce, 0xf1ef, 0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294,
    0x72f7, 0x62d6, 0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff,
    0xe3de, 0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
    0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d, 0x3653,
    0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4, 0xb75b, 0xa77a,
    0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc, 0x48c4, 0x58e5, 0x6886,
    0x78a7, 0x0840, 0x1861, 0x2802, 0x3823, 0xc9cc, 0xd9ed, 0xe98e, 0xf9af,
    0x8948, 0x9969, 0xa90a, 0xb92b, 0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71,
    0x0a50, 0x3a33, 0x2a12, 0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58,
    0xbb3b, 0xab1a, 0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60,
    0x1c41, 0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
    0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70, 0xff9f,
    0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78, 0x9188, 0x81a9,
    0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f, 0x1080, 0x00a1, 0x30c2,
    0x20e3, 0x5004, 0x4025, 0x7046, 0x6067, 0x83b9, 0x9398, 0xa3fb, 0xb3da,
    0xc33d, 0xd31c, 0xe37f, 0xf35e, 0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235,
    0x5214, 0x6277, 0x7256, 0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f,
    0xd52c, 0xc50d, 0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424,
    0x4405, 0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
    0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634, 0xd94c,
    0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab, 0x5844, 0x4865,
    0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3, 0xcb7d, 0xdb5c, 0xeb3f,
    0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a, 0x4a75, 0x5a54, 0x6a37, 0x7a16,
    0x0af1, 0x1ad0, 0x2ab3, 0x3a92, 0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa,
    0xad8b, 0x9de8, 0x8dc9, 0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83,
    0x1ce0, 0x0cc1, 0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9,
    0x9ff8, 0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0 };


//crc16转换
+(int16_t)crc16With:(NSData *)data
{
    unsigned int    crc;
    
    
    
    crc = 0x0;
    
    
    
    uint8_t byteArray[[data length]];
    
    //    [self getBytes:&byteArray];
    [data getBytes:&byteArray length:sizeof(byteArray)];
    
    
    
    for (int i = 0; i<[data length]; i++) {
        
        Byte byte = byteArray[i];
        
        crc = (crc << 8) ^ crc16tab[((crc>>8)^ byte) & 0x00FF];
        
    }
    
    return (int16_t)crc;

}

#pragma mark-- 打印控制
//打印控制
+(void)print:(NSString *)format, ...
{
    if ([NetvoxUserInfo shareInstance].isPrint) {
        NSLog(@"%@", format);
    }
}


#pragma mark-- Gzip压缩及解压
//gzip压缩
+(NSData *)gzipCompress:(NSData *)data
{
    return [NetvoxTar gzipCompress:data];
}

//gzip解压
+(NSData *)gzipDecompress:(NSData *)data
{
    return [NetvoxTar gzipDecompress:data];
}

//tar解压
+(BOOL)tarDecompress:(NSData *)data Path:(NSString *)path
{
    return [NetvoxTar untarData:data toPath:path error:nil];
}

//tar压缩
+(BOOL)tarCompress:(NSString *)tarFromPath Topath:(NSString *)path
{
    return [NetvoxTar tarFileAtPath:tarFromPath toPath:path error:nil];
}

#pragma mark-- 字符串\data\NSData\进制转换\位运算加密
//字符串data转NSData
+ (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    
    return hexData;
}


//十六进制异或解密
+(void)xorDecode:(NSData *)file andIntoPath:(NSString *)path
{
    Byte * code = (Byte *)[[@"NeTvOx" dataUsingEncoding:NSUTF8StringEncoding] bytes];
    //遍历byte
    [file enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        //异或加密
        for (NSInteger i = 0; i < byteRange.length; i++) {
            dataBytes[i] = dataBytes[i]^code[i%6];
        }
        NSData * dat = [NSData dataWithBytes:dataBytes length:byteRange.length];
        NSFileManager * manager = [NSFileManager defaultManager];
        [manager createFileAtPath:path contents:dat attributes:nil];
        
    }];

}

//NSData变成不带<>和空格的字符串字符串
+(NSString *)convertNSDataToNSString:(NSData *)data
{
    NSMutableString *strTemp = [NSMutableString stringWithCapacity:[data length]*2];
    
    const unsigned char *szBuffer = [data bytes];

    for (NSInteger i=0; i < [data length]; ++i) {
        
        [strTemp appendFormat:@"%02lx",(unsigned long)szBuffer[i]];
        
    }
   
    return strTemp;
    
}

//判断是否是中文
+(BOOL)isChinese:(NSString *)str
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:str];
    
}



//判断是否含有中文
+(BOOL)includeChinese:(NSString *)str
{
    for(int i=0; i< [str length];i++)
    {
        int a =[str characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

//更新本地皮肤数据
+(void)updateSkin:(NSArray *)array
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"skinlist"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"skinlist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    
    NSMutableArray * skinDicLocal = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"skinlist"]];
    
    if(array != nil)
    {
        for (NSDictionary * dic in array) {
            NSString * skin_name = [dic objectForKey:@"skin_name"];
            if(skin_name != nil)
            {
                [self circulationWithArr:skinDicLocal andDic:dic andStr:skin_name];
            }
            
        }
        [[NSUserDefaults standardUserDefaults] setObject:skinDicLocal forKey:@"skinlist"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
}

+(void)circulationWithArr:(NSMutableArray *)skinDicLocal andDic:(NSDictionary *)dic andStr:(NSString *)skin_name
{
    NSArray * tempArr = [NSArray arrayWithArray:skinDicLocal];
    for (int i = 0 ; i<tempArr.count; i++)
    {
        NSDictionary * dicLocal = tempArr[i];
        NSString * nameLocal = [dicLocal objectForKey:@"skin_name"];
        if (nameLocal != nil && [nameLocal isEqualToString:skin_name]) {
            [skinDicLocal replaceObjectAtIndex:i withObject:dic];
            return;
        }
    }
    [skinDicLocal addObject:dic];
}

//删除指定文件或文件夹
+(BOOL)deleteFileWithName:(NSString *)fileName
{
    NSString *doc = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"];
    NSString * path = [doc stringByAppendingPathComponent:fileName];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path])
    {
        return [fileManager removeItemAtPath:path error:nil];
    }
    else
    {
        return NO;
    }
}


#pragma mark - 判断是否是Ipv6
+ (BOOL)isIpv6{
    NSArray *searchArray =
    @[ IOS_VPN @"/" IP_ADDR_IPv6,
       IOS_VPN @"/" IP_ADDR_IPv4,
       IOS_WIFI @"/" IP_ADDR_IPv6,
       IOS_WIFI @"/" IP_ADDR_IPv4,
       IOS_CELLULAR @"/" IP_ADDR_IPv6,
       IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
//    NSLog(@"addresses: %@", addresses);
    
    __block BOOL isIpv6 = NO;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         
//         NSLog(@"---%@---%@---",key, addresses[key] );
         
         if ([key rangeOfString:@"ipv6"].length > 0  && ![[NSString stringWithFormat:@"%@",addresses[key]] hasPrefix:@"(null)"] ) {
             
             if ( ![addresses[key] hasPrefix:@"fe80"]) {
                 isIpv6 = YES;
             }
         }
         
     } ];
    
    return isIpv6;
}


+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                        
//                        NSLog(@"ipv4 %@",name);
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
//                        NSLog(@"ipv6 %@",name);
                        
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}


/**根据传进来的dev_id判断是什么设备返回单个设备详情**/
+ (NSDictionary *)resultDeviceDetail:(NSString *)dev_id
{
    NSDictionary * dic = [NSDictionary dictionary];
    
    NSArray * array = @[@{
                            @"devicetype" : @"1000001",
                            @"id" : @"00137A00000101360A",
                            @"name" : @"Combined Interface",
                            @"pic" : @"",
                            @"roomid" : @"0",
                            @"status" : @"online",
                            @"udeviceid" : @"Z103AE3C_0007_0A",
                            @"details":@{
                                    @"app_version":@"30",
                                    @"arm_status" : @"arm",
                                    @"current_power":@"1",
                                    @"ep" : @"0A",
                                    @"ep_mode_id" : @"000010000080",
                                    @"hw_version":@"0B",
                                    @"ieee" : @"00137A0000010136",
                                    @"manufacturer":@"netvox",
                                    @"modelid":@"Z103AE3C",
                                    @"nwkaddr":@"0000",
                                    @"power_mode":@"DC source",
                                    @"profileid":@"0104",
                                    @"stack_version":@"35",
                                    @"ver_date":@"20160918",
                                    @"warn_delay":@"8",
                                    @"zcl_version" : @"03",
                                    },
                            },@{
                            @"devicetype" : @"1000001",
                            @"id" : @"00137A000001130001",
                            @"name" : @"Dimmable Light",
                            @"pic" : @"",
                            @"roomid" : @"0",
                            @"status" : @"online",
                            @"udeviceid" : @"ZC06E0R_0101_01",
                            @"details":@{
                                    @"app_version":@"17",
                                    @"current_power" : @"1",
                                    @"ep_mode_id" : @"",
                                    @"hw_version":@"16",
                                    @"level" : @"0",
                                    @"ep" : @"01",
                                    @"onoff_status" : @"off",
                                    @"ieee" : @"00137A0000011300",
                                    @"manufacturer":@"netvox",
                                    @"nwkaddr":@"0033",
                                    @"modelid":@"ZC06E0R",
                                    @"power_mode" : @"Mains(single phase)",
                                    @"profileid" : @"0104",
                                    @"stack_version" : @"2E",
                                    @"update_time" : @"2018-05-17 10:28:06",
                                    @"ver_date" : @"20140505",
                                    @"zcl_version" : @"03",
                                    },
                            },@{
                            @"devicetype" : @"1000001",
                            @"id" : @"00137A0000006E0801",
                            @"name" : @"Dimmable Light",
                            @"pic" : @"",
                            @"roomid" : @"0",
                            @"status" : @"online",
                            @"udeviceid" : @"Z815ME3R_0101_01",
                            @"details":@{
                                    @"app_version":@"17",
                                    @"current_power" : @"1",
                                    @"current":@"126",
                                    @"ep_mode_id" : @"0101",
                                    @"energy":@"0.291",
                                    @"hw_version":@"0E",
                                    @"level" : @"186",
                                    @"ep" : @"01",
                                    @"onoff_status" : @"on",
                                    @"ieee" : @"00137A0000006E08",
                                    @"manufacturer":@"netvox",
                                    @"nwkaddr":@"3515",
                                    @"modelid":@"Z815ME3R",
                                    @"power_mode" : @"Mains(single phase)",
                                    @"profileid" : @"0104",
                                    @"stack_version" : @"2F",
                                    @"update_time" : @"2018-05-17 12:55:04",
                                    @"ver_date" : @"20130105",
                                    @"zcl_version" : @"03",
                                    @"power":@"27",
                                    @"voltage" : @"226",
                                    },
                            }];
    for (int i = 0; i<array.count; i++) {
        NSDictionary * dictionary = array[i];
        if ([dictionary[@"id"] isEqualToString:dev_id]) {
            dic = dictionary;
            break;
        }
    }
    return dic;
}
/**根据传进来的aResult返回设备详情**/
+ (NSArray *)arrayForDeviceListDictionary
{
    return @[@{
                        @"devicetype" : @"1000001",
                        @"fre" : @"0",
                        @"id" : @"00137A00000101360A",
                        @"name" : @"Combined Interface",
                        @"pic" : @"",
                        @"roomid" : @"0",
                        @"status" : @"online",
                        @"udeviceid" : @"Z103AE3C_0007_0A",
                        @"details":@{
                                @"arm_status" : @"arm",
                                @"ep" : @"0A",
                                @"ep_mode_id" : @"000010000080",
                                @"ieee" : @"00137A0000010136",
                                @"main_device_type" : @"gateway",
                                @"uid" : @"00137A00000101360A",
                                },
                        },@{
                        @"devicetype" : @"1000001",
                        @"fre" : @"0",
                        @"id" : @"00137A000001130001",
                        @"name" : @"Dimmable Light",
                        @"pic" : @"",
                        @"roomid" : @"0",
                        @"status" : @"online",
                        @"udeviceid" : @"ZC06E0R_0101_01",
                        @"details":@{
                                @"level" : @"0",
                                @"ep" : @"01",
                                @"onoff_status" : @"off",
                                @"ieee" : @"00137A0000011300",
                                @"main_device_type" : @"dimmableLight",
                                @"uid" : @"00137A000001130001",
                                },
                        },@{
                        @"devicetype" : @"1000001",
                        @"fre" : @"0",
                        @"id" : @"00137A0000006E0801",
                        @"name" : @"Dimmable Light",
                        @"pic" : @"",
                        @"roomid" : @"0",
                        @"status" : @"online",
                        @"udeviceid" : @"Z815ME3R_0101_01",
                        @"details":@{
                                @"level":@"186",
                                @"ep_mode_id":@"0101",
                                @"energy" : @"0.291",
                                @"current":@"126",
                                @"ep" : @"01",
                                @"onoff_status" : @"on",
                                @"power":@"27",
                                @"ieee" : @"00137A0000006E08",
                                @"main_device_type" : @"dimmableLight",
                                @"update_time":@"2018-05-17 12:55:04",
                                @"voltage":@"226",
                                @"uid" : @"00137A0000006E0801",
                                },
                        }] ;
}

#pragma mark-- 异或加密解密
/**异或加密解密*/
+(NSString *)checkWithBCC:(NSString *)checkStr
{
    NSString *str = @"";
    NSString *subStr1=[checkStr substringWithRange:NSMakeRange(0, 2)];
    NSString *a_subStr1=[NSString stringWithFormat:@"%lu", strtoul([subStr1 UTF8String], 0, 16)];
    int checkNum=[a_subStr1 intValue];
    for (int i=1; i<checkStr.length/2; i++) {
        NSString *subStr=[checkStr substringWithRange:NSMakeRange(i*2, 2)];
        NSString *a_subStr=[NSString stringWithFormat:@"%lu", strtoul([subStr UTF8String], 0, 16)];
        int k=[a_subStr intValue];
        checkNum = checkNum ^ k;
        
    }
    
    str = [[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%02x",checkNum]] uppercaseString];
    
    return str;
}

#pragma mark 字典转化字符串
+(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
//字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return @{};
    }
    return dic;
}

@end
