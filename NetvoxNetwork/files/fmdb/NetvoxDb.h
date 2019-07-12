//
//  NetvoxDb.h
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/6/2.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//  注:数据库命名为:用户名.sqlite,对于内网shcadmin账号登陆,切换网关取本地数据会有数据不正确的问题

#import <Foundation/Foundation.h>


//版本控制
#define TABLE_VERSION @"version"

//设备table
#define TABLE_DEVICE @"Device"

//房间table
#define TABLE_ROOM @"Room"

//消息table
#define TABLE_MSG @"Msg"

//报表的table
#define TABLE_REPORT @"Report"


@interface NetvoxDb : NSObject

/*
              初始化
 
 **/

//单例
+(NetvoxDb *)shareInstance;

//初始化数据库
-(NetvoxDb *)initNetvoxDb;






/*
                 建表
 
 **/

/*
                 版本更新
 
 **/



/*
                 增

**/

//插入数据库
+(BOOL)insert:(NSString *)tableName data:(NSDictionary *)insertDic;



/*
                  删

**/

//完全删除整个表(注:该方法会删除整个表!!!)
+(BOOL)drop:(NSString *)tableName;

//删除(表名tableName必须传,其他参数均为可选参数,不传的时候传nil;addArr:与条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];orArr:或条件数组,数组中存放字典,字典样式和addArr一样)
+(BOOL)del:(NSString *)tableName addArr:(NSArray *)addArr orArr:(NSArray *)orArr;


/*
                  查

**/

//查询(表名tableName必须传,其他参数均为可选参数,不传的时候传nil;addArr:与条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];orArr:或条件数组,数组中存放字典,字典样式和addArr一样;orderDic:排序参数,字典key分别为key:排序的key,op:升序值为asc,降序为desc,例如@[@{@"key":@"ieee",@"op":@"asc"}];limitDic:分页参数,字典key分别为:index:起始页,size:取出指定条数)
+(NSMutableArray *)query:(NSString *)tableName addArr:(NSArray *)addArr orArr:(NSArray *)orArr orderDic:(NSDictionary *)orderDic limitDic:(NSDictionary *)limitDic;

//查询个数(表名tableName必须传,其他参数均为可选参数,不传的时候传nil;addArr:与条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];orArr:或条件数组,数组中存放字典,字典样式和addArr一样)
+(int)queryCount:(NSString *)tableName addArr:(NSArray *)addArr orArr:(NSArray *)orArr;


//查询(表名tableName必须传,其他参数均为可选参数,不传的时候传nil;addArr:与条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];orArr:或条件数组,数组中存放字典,字典样式和addArr一样;orderDic:排序参数,字典key分别为key:排序的key,op:升序值为asc,降序为desc,例如@[@{@"key":@"ieee",@"op":@"asc"}];limitDic:分页参数,字典key分别为:index:起始页,size:取出指定条数)   用于报表
+(NSMutableDictionary *)query:(NSString *)tableName addArr:(NSArray *)addArr orderDic:(NSDictionary *)orderDic;
/*
                    改
 
 **/

//更新(表名tableName,所有参数必须传,条件更新只考虑与条件更新;conditions:条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];updates:更新数组,数组中存放字典,字典key分别为key:更新的key,value:更新的value,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136"}])
+(BOOL)update:(NSString *)tableName conditions:(NSArray *)conditions updates:(NSArray *)updates;

//多线程事务更新(该方法专门用于处理插入设备列表,房间列表的请求数据,该方法会将多余的数据清除,因此要传入完整的数据)
+(BOOL)update:(NSString *)tableName data:(NSDictionary *)dataDic;


/*
                 其他
 
 **/

//获取消息数据所占数据的大小(单位为M)
+(float)getMsgCacheSize;

//设置消息数据缓存天数(默认15天)
+(void)setMsgCacheSaveWithDays:(int)days;

@end
