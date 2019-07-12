//
//  NetvoxDb.m
//  NetvoxNetwork
//
//  Created by netvox-ios6 on 17/6/2.
//  Copyright © 2017年 netvox-ios6. All rights reserved.
//

#import "NetvoxDb.h"
#import "NetvoxUserInfo.h"
#import "NetvoxFMDatabaseAdditions.h"
#import "NetvoxFMDatabase.h"
#import "NetvoxFMDatabaseQueue.h"
#import "NetvoxCommon.h"

//沙盒路径
#define DbSandPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Netvox"]

//ID
#define DATABASEID @"id"

@interface NetvoxDb ()
{
    
}

//数据库
@property (nonatomic,strong)NetvoxFMDatabase *nDb;

@end
@implementation NetvoxDb

//用户
NetvoxUserInfo *user;

//初始化标记
BOOL isInit;

//记录设备值(对于某些要保持不变数据库使用)
NSMutableArray *deviceArr;
//版本号 int形式字符串
NSString *dbVersionNo;

#pragma mark--初始化方法

//单例
+(NetvoxDb *)shareInstance
{
        static NetvoxDb *obj = nil;
        static dispatch_once_t onceToken;
    
        dispatch_once(&onceToken, ^{
    
            obj = [[self alloc]initNetvoxDb];
            deviceArr =[[NSMutableArray alloc] initWithCapacity:1];
            //数据库版本迁移，需要增加版本
            dbVersionNo = @"24";
            [self tableUpdate:dbVersionNo];
    
        });
        return obj;
}

//初始化数据库
-(NetvoxDb *)initNetvoxDb
{
    self=[super init];
    if (self) {
        user = [NetvoxUserInfo shareInstance];
        
        NSString *dbPath = [NetvoxDb getDBPath];
        self.nDb=[NetvoxFMDatabase databaseWithPath:dbPath];
        [NetvoxCommon print:[NSString stringWithFormat:@"数据库为:%@",dbPath]];
    
        
        if (![self isTableOK:TABLE_VERSION]) {
            [self createTable:TABLE_VERSION];
        }
        
        if (![self isTableOK:TABLE_DEVICE]) {
        [self createTable:TABLE_DEVICE];
        }
        
        
        if (![self isTableOK:TABLE_ROOM]) {
            [self createTable:TABLE_ROOM];
        }
        
        if (![self isTableOK:TABLE_MSG]) {
            [self createTable:TABLE_MSG];
        }
        
        if (![self isTableOK:TABLE_REPORT])
        {
            [self createTable:TABLE_REPORT];
        }
       
        
        
        isInit = YES;
        
    }
    return self;
}

//判断表是否存在
- (BOOL) isTableOK:(NSString *)tableName
{
    BOOL isOpen=NO;
    if ([self.nDb open]) {
        
        
        NetvoxFMResultSet *rs = [self.nDb executeQuery:@"SELECT count(*) as 'count' FROM sqlite_master WHERE type ='table' and name = ?", tableName];
        while ([rs next])
        {
            // just print out what we've got in a number of formats.
            NSInteger count = [rs intForColumn:@"count"];
            //        WILog(@"isTableOK %d", count);
            
            if (0 == count)
            {
                isOpen=NO;
            }
            else
            {
                isOpen=YES;
            }
        }
        [self.nDb close];
    }
    return isOpen;
}


#pragma mark--参数方法
//获取数据库文件路径
+(NSString *)getDBPath
{
    //    获得数据库文件的路径
    NSString *doc=DbSandPath;
    NSString *dbName = [NSString stringWithFormat:@"%@.sqlite",user.userName];
    NSString *fileName=[doc stringByAppendingPathComponent:dbName];
   
    
    return fileName;
    
}

//字典取值,如果未取得,赋予空字符串作为初值
+(NSString *)getValue:(NSDictionary *)dic key:(NSString *)key
{
    //彩灯模式
    if([dic[key] isKindOfClass:[NSArray class]])
    {
        NSArray * array = dic[key];
        NSString * str = @"";
       
        for (NSDictionary * tempDic in array)
        {
            for (int i = 0; i<tempDic.count; i++) {
                str = [NSString stringWithFormat:@"%@%@:",str,tempDic.allValues[i]];
            }
            str = [str substringToIndex:str.length-1];
            str = [NSString stringWithFormat:@"%@,,",str];
        }
        if(str.length>0)
        {
            str = [str substringToIndex:str.length-2];
        }
        NSLog(@"%@",str);
        return str;
    }
    return dic[key] ? dic[key] : @"";
}

//321,1178

#pragma mark--建表
//创表
-(BOOL)createTable:(NSString *)tableName
{
    BOOL res=NO;
    
    //sql 语句
    if ([self.nDb open]) {
        NSString *sqlCreateTable =[NetvoxDb getSQLCreateTable:tableName];
        //        为空不再创建
        if (sqlCreateTable) {
            res = [self.nDb executeUpdate:sqlCreateTable];
        }
        if (!res) {
            [NetvoxCommon print:@"error when creating db table"];
           
        } else {
            [NetvoxCommon print:@"success to creating db table"];
        }
        [self.nDb close];
    }
    return res;
}
//获取创建表的key
+(NSString *)getSQLCreateTable:(NSString *)tableName
{
        //    设备table
    if ([tableName isEqualToString:TABLE_DEVICE]) {
        
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (uid TEXT DEFAULT '',devicetype TEXT DEFAULT '',detailsUid TEXT DEFAULT '',name TEXT DEFAULT '',pic TEXT DEFAULT '',roomid TEXT DEFAULT '',status TEXT DEFAULT '',udeviceid TEXT DEFAULT '',arm_status TEXT DEFAULT '',current TEXT DEFAULT '',ieee TEXT DEFAULT '',ep TEXT DEFAULT '',energy TEXT DEFAULT '',onoff_status TEXT DEFAULT '',power TEXT DEFAULT '',voltage TEXT DEFAULT '',update_flag TEXT DEFAULT '0',house_ieee TEXT DEFAULT '',humidity TEXT DEFAULT '0',temperature TEXT DEFAULT '0',water_temperature TEXT DEFAULT '0',enable TEXT DEFAULT '',sunlight_intensity TEXT DEFAULT '',soil_moisture TEXT DEFAULT '',update_time TEXT DEFAULT '0',alarm1 TEXT DEFAULT '',alarm2 TEXT DEFAULT '',fre TEXT DEFAULT '0',ep_mode_id TEXT DEFAULT '',level TEXT DEFAULT '',zone_type TEXT DEFAULT '',ir_sensor_status TEXT DEFAULT '',o3 TEXT DEFAULT '',co TEXT DEFAULT '',no TEXT DEFAULT '',no2 TEXT DEFAULT '',so2 TEXT DEFAULT '',noise TEXT DEFAULT '',colormode TEXT DEFAULT '',lux TEXT DEFAULT '',pm2_5 TEXT DEFAULT '',sn TEXT DEFAULT '',verify_code TEXT DEFAULT '',main_device_type TEXT DEFAULT '',ip TEXT DEFAULT '',ipcamip TEXT DEFAULT '',water1_leak TEXT DEFAULT '',water2_leak TEXT DEFAULT '',ADC_raw_value1 TEXT DEFAULT '',ADC_raw_value2 TEXT DEFAULT '',onoff_status1 TEXT DEFAULT '',onoff_status2 TEXT DEFAULT '',temperature1 TEXT DEFAULT '',temperature2 TEXT DEFAULT '',ipcamport TEXT DEFAULT '',flip TEXT DEFAULT '',nwkaddr TEXT DEFAULT '',nvr_channel TEXT DEFAULT '',nvr_sn TEXT DEFAULT '',nvr_verify_code TEXT DEFAULT '',onoff_dir TEXT DEFAULT '',baudrate TEXT DEFAULT '',parity TEXT DEFAULT '',sunlight_level TEXT DEFAULT '',sampling_period TEXT DEFAULT '',stopbit TEXT DEFAULT '',actual_fanspeed TEXT DEFAULT '',indoortemp TEXT DEFAULT '',mode TEXT DEFAULT '',preset_fanspeed TEXT DEFAULT '',settemp TEXT DEFAULT '',report_status_period TEXT DEFAULT '',username TEXT DEFAULT '',password TEXT DEFAULT '',value TEXT DEFAULT '',attr TEXT DEFAULT '',setting_temperature TEXT DEFAULT '',unit TEXT DEFAULT '',attributes TEXT DEFAULT '',a_current TEXT DEFAULT '',a_energy TEXT DEFAULT '',a_power TEXT DEFAULT '',a_voltage TEXT DEFAULT '',b_current TEXT DEFAULT '',b_energy TEXT DEFAULT '',b_power TEXT DEFAULT '',b_voltage TEXT DEFAULT '',c_current TEXT DEFAULT '',c_energy TEXT DEFAULT '',c_power TEXT DEFAULT '',c_voltage TEXT DEFAULT '',windspeed TEXT DEFAULT '',mirror TEXT DEFAULT '',PRIMARY KEY (uid))",tableName];
        
        return sqlCreateTable;
    }
    
    
    //    房间table
    if ([tableName isEqualToString:TABLE_ROOM]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (uid TEXT DEFAULT '',name TEXT DEFAULT '',picture TEXT DEFAULT '',update_flag TEXT DEFAULT '0',house_ieee TEXT DEFAULT '',PRIMARY KEY (uid))",tableName];
        return sqlCreateTable;
    }
    
    //    消息table
    if ([tableName isEqualToString:TABLE_MSG]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (id TEXT DEFAULT '',type TEXT DEFAULT '',time TEXT DEFAULT '',update_flag TEXT DEFAULT '0',mark TEXT DEFAULT '0',house_ieee TEXT DEFAULT '',warn_type TEXT DEFAULT '',msg_type TEXT DEFAULT 'warn',dev_id TEXT DEFAULT '',username TEXT DEFAULT '',cmd_type TEXT DEFAULT '',data TEXT DEFAULT '',devname TEXT DEFAULT '',areaid TEXT DEFAULT '',areaname TEXT DEFAULT '',singal TEXT DEFAULT '',ext TEXT DEFAULT '',message TEXT DEFAULT '',desc TEXT DEFAULT '',roomid TEXT DEFAULT '',PRIMARY KEY (id))",tableName];
        return sqlCreateTable;
    }

    
    //数据库版本更新(version 从1开始,依次累加,默认0版本)
    if ([tableName isEqualToString:TABLE_VERSION]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT,version TEXT DEFAULT '0')",tableName,DATABASEID];
        
        return sqlCreateTable;
    }

    //报表数据(report )
    if ([tableName isEqualToString:TABLE_REPORT]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (avg_value TEXT DEFAULT '',curr_value TEXT DEFAULT '',max_value TEXT DEFAULT '',min_value TEXT DEFAULT '',unit TEXT DEFAULT '',value TEXT DEFAULT '',request_time TEXT DEFAULT '',total_value TEXT DEFAULT '',PRIMARY KEY (request_time))",tableName];
        
        return sqlCreateTable;
    }
    
   
    
    return nil;
}


#pragma mark--版本更新
//版本更新(从1版本开始累加,toVersion比原先最大版本大1)
+(void)tableUpdate:(NSString *)toVersion
{
    int toV = [toVersion intValue];
    NSArray *arrVersion = [NetvoxDb query:TABLE_VERSION addArr:nil orArr:nil orderDic:nil limitDic:nil];
    if (arrVersion.count != 0) {
        NSDictionary *versionDic = arrVersion[0];
        int version = [versionDic[@"version"] intValue];
        if (version == 0) {
            [NetvoxDb del:TABLE_VERSION addArr:nil orArr:nil];
            [NetvoxDb insert:TABLE_VERSION data:@{@"version":toVersion}];

        }
        else if (version == toV || version>toV)
        {
            //版本一样或者版本倒退(容错处理)不做处理
        }
        else
        {
//            for (int i = version; i<toV; i++) {
    //            [NetvoxDb updateToVersion:version+1];
//            }
            [NetvoxDb updateToVersion:toV];
            [NetvoxDb del:TABLE_VERSION addArr:nil orArr:nil];
            [NetvoxDb insert:TABLE_VERSION data:@{@"version":toVersion}];
        }
    }
    else
    {
        [NetvoxDb insert:TABLE_VERSION data:@{@"version":toVersion}];
    }
}
//版本迁移处理(这里写需要更新的表单)
+(void)updateToVersion:(int)toV
{
    [NetvoxDb updateTable:TABLE_DEVICE toVersion:toV];
    [NetvoxDb updateTable:TABLE_ROOM toVersion:toV];
    [NetvoxDb updateTable:TABLE_MSG toVersion:toV];
    [NetvoxDb updateTable:TABLE_REPORT toVersion:toV];
}

+(void)updateTable:(NSString *)tableName toVersion:(int)toV
{
    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inTransaction:^(NetvoxFMDatabase *db, BOOL *rollback) {
        @try {
            //将原始表改名(就是拷贝一份原始表用于复制数据操作）
            NSString *renameTable = [NSString stringWithFormat:@"alter table %@ rename to k%@",tableName,tableName];
            [db executeUpdate:renameTable];
            
            //创建新表(新版本要更新的表)
            [db executeUpdate:[NetvoxDb getSQLCreateTable:tableName]];
            
            //迁移数据
            NSString *toSql = [NetvoxDb updateTableSql:tableName toVersion:toV FMDatabase:db];
            [db executeUpdate:toSql];
            
            //删除临时表（就是删掉刚才改过名字的表）
            NSString *dropTableSql = [NSString stringWithFormat:@"drop table k%@",tableName];
            [db executeUpdate:dropTableSql];
            
        } @catch (NSException *exception) {
            *rollback = YES;
        } @finally {
            
        }
    }];
}

//获取表中所有字段名称（不包含id）
+(NSArray *)getFieldNameFormTable:(NSString *)tableName FMDatabase:(NetvoxFMDatabase *)queryDb
{
    NSMutableArray * fieldArray = [[NSMutableArray alloc] init];
    NSString * sql = [NSString stringWithFormat:
                      @"PRAGMA table_info(%@)",tableName];
    NetvoxFMResultSet * rs1 = [queryDb executeQuery:sql];
    while ([rs1 next]) {
        NSString *name=[rs1 stringForColumn:@"name"];
        if(![name isEqualToString:@"id"])
        {
            [fieldArray addObject:name];
        }
    }
    return fieldArray;
}

//迁移数据(历史版本更新都写在这)
+(NSString *)updateTableSql:(NSString *)tableName toVersion:(int)toV FMDatabase:(NetvoxFMDatabase *)queryDb
{
    NSString * originTableName = [NSString stringWithFormat:@"k%@",tableName];
    NSArray *originFieldArray = [NetvoxDb getFieldNameFormTable:originTableName FMDatabase:queryDb]; //原表字段
    NSArray *newFieldArray = [NetvoxDb getFieldNameFormTable:tableName FMDatabase:queryDb]; //新表字段
    NSMutableArray *operationArray = [[NSMutableArray alloc] init];//操作移动数据的字段
    for (NSString *fieldStr in originFieldArray)//操作的字段必须2个表（原表和新表）中都存在
    {
        if([newFieldArray containsObject:fieldStr])
        {
            [operationArray addObject:fieldStr];
        }
    }
    
    NSString *sql=@"insert into ";
    sql = [NSString stringWithFormat:@"%@%@(",sql,tableName];
    for(int i = 0;i < operationArray.count; i++)
    {
        sql = [sql stringByAppendingFormat:@"%@,",operationArray[i]];
    }
    sql = [sql substringToIndex:sql.length-1];
    sql = [sql stringByAppendingString:@") select "];
    for(int i = 0;i < operationArray.count; i++)
    {
        sql = [sql stringByAppendingFormat:@"%@,",operationArray[i]];
    }
    sql = [sql substringToIndex:sql.length-1];
    sql = [sql stringByAppendingFormat:@" from k%@",tableName];
    //字符串是insert into 新表名(字段1,字段2,字段3...) select 字段1,字段2,字段3... from 旧表名
    //表示从旧表中找出需要移动的字段数据到新表对应的字段中去
    
    
    //相当于类似以下字符串
//    if ([tableName isEqualToString:TABLE_DEVICE]) {
//        sql = [NSString stringWithFormat:@"%@ %@(uid,name,devicetype,pic,roomid,status,udeviceid,arm_status,current,ieee,ep,energy,onoff_status,power,voltage,update_flag) select uid,name,devicetype,pic,roomid,status,udeviceid,arm_status,current,ieee,ep,energy,onoff_status,power,voltage,update_flag from k%@",sql,tableName,tableName];
//    }
    return sql;
}

#pragma mark--增
+(BOOL)insert:(NSString *)tableName data:(NSDictionary *)insertDic
{
   __block BOOL res = NO;
    if (!isInit) {
        return res;
    }
    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inDatabase:^(NetvoxFMDatabase *db) {
        if ([db open]) {
            NSString * sql = [NetvoxDb getInsertSql:tableName data:insertDic db:db];
            if (sql) {
                res = [db executeUpdate:sql];
            }
            if (!res) {
                [NetvoxCommon print:@"error when insert db table"];
               
            } else {
             
                [NetvoxCommon print:@"success to insert db table"];
            }
            
            [db close];
        }
        
    }];

    
    return res;
}

//获取插入语句
+(NSString *)getInsertSql:(NSString *)tableName data:(NSDictionary *)dataDic db:(NetvoxFMDatabase *)db
{
    //    如果传入的dicData不为字典
    if (![dataDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if ([tableName isEqualToString:TABLE_DEVICE] ) {
        //设备列表
        NSString *uid =[self getValue:dataDic key:@"id"];
        NSString *devicetype =[self getValue:dataDic key:@"devicetype"];
        NSString *name =[self getValue:dataDic key:@"name"];
        NSString *pic =[self getValue:dataDic key:@"pic"];
        NSString *roomid =[self getValue:dataDic key:@"roomid"];
        NSString *status =[self getValue:dataDic key:@"status"];
        NSString *udeviceid =[self getValue:dataDic key:@"udeviceid"];
        NSString *house_ieee =[[self getValue:dataDic key:@"house_ieee"] isEqualToString:@""] ? user.currentHouseIeee :[self getValue:dataDic key:@"house_ieee"];
        
        // details 处理
        //detail 里面数据
        NSString *ieee = @"";
        NSString *ep = @"";
        NSString *arm_status = @"";
        NSString *current = @"";
        NSString *energy = @"";
        NSString *onoff_status =@"";
        NSString *power = @"";
        NSString *voltage= @"";
        NSString *humidity= @"";
        NSString *temperature= @"";
        NSString *water_temperature= @"";
        NSString *enable= @"";
        NSString *sunlight_intensity=@"";
        NSString *soil_moisture=@"";
        NSString *update_time= @"";
        NSString *alarm1= @"";
        NSString *alarm2= @"";
        NSString *ep_mode_id= @"";
        NSString *level= @"";
        NSString *zone_type= @"";
        NSString *ir_sensor_status= @"";
        NSString *o3 = @"";
        NSString *co = @"";
        NSString *no = @"";
        NSString *no2 = @"";
        NSString *so2 = @"";
        NSString *noise = @"";
        NSString *colormode = @"";
        NSString *lux= @"";
        NSString *pm2_5= @"";
        NSString *sn= @"";
        NSString *verify_code= @"";
        NSString *main_device_type = @"";
        NSString *ip = @"";
        NSString *ipcamip = @"";
        NSString *ipcamport = @"";
        NSString *flip = @"";
        NSString *username = @"";
        NSString *password = @"";
        NSString *mirror = @"";
        NSString *detailsUid =@"";
        NSString *water1_leak =@"";
        NSString *water2_leak =@"";
        NSString *temperature1 =@"";
        NSString *temperature2 =@"";
        NSString *ADC_raw_value1 =@"";
        NSString *ADC_raw_value2 =@"";
        NSString *onoff_status1 =@"";
        NSString *onoff_status2 =@"";
        NSString *value = @"";
        NSString *attr = @"";
        NSString *unit = @"";
        NSString *attributes = @"";
        NSString * windspeed = @"";
        NSString * setting_temperature = @"";
        
        NSString *nwkaddr =@"";
        NSString *nvr_channel =@"";
        NSString *nvr_sn =@"";
        NSString *nvr_verify_code =@"";
        NSString *onoff_dir =@"";
        
        
        NSString * baudrate = @"";
        NSString * parity = @"";
        NSString * stopbit = @"";
        NSDictionary * comport_param = @{};
        
        NSString * sampling_period = @"";
        NSString * sunlight_level = @"";
        
        //温控器 z100ba
        NSString * actual_fanspeed = @"";
        NSString * indoortemp = @"";
        NSString * mode = @"";
        NSString * preset_fanspeed = @"";
        NSString * settemp = @"";
        NSString * report_status_period = @"";
        
        //zl01k三相
        NSString * a_current = @"";
        NSString * a_energy = @"";
        NSString * a_power = @"";
        NSString * a_voltage = @"";
        NSString * b_current = @"";
        NSString * b_energy = @"";
        NSString * b_power = @"";
        NSString * b_voltage = @"";
        NSString * c_energy = @"";
        NSString * c_current = @"";
        NSString * c_power = @"";
        NSString * c_voltage = @"";
        
        
        NSDictionary *details = dataDic[@"details"];
        if (details) {
            ieee = [self getValue:details key:@"ieee"];
            ep = [self getValue:details key:@"ep"];
            arm_status = [self getValue:details key:@"arm_status"];
            current = [self getValue:details key:@"current"];
            energy = [self getValue:details key:@"energy"];
            onoff_status = [self getValue:details key:@"onoff_status"];
            power = [self getValue:details key:@"power"];
            voltage = [self getValue:details key:@"voltage"];
            humidity = [self getValue:details key:@"humidity"];
            temperature = [self getValue:details key:@"temperature"];
            water_temperature = [self getValue:details key:@"water_temperature"];
            enable = [self getValue:details key:@"enable"];
            sunlight_intensity = [self getValue:details key:@"sunlight_intensity"];
            soil_moisture = [self getValue:details key:@"soil_moisture"];
            update_time = [self getValue:details key:@"update_time"];
            alarm1 = [self getValue:details key:@"alarm1"];
            alarm2 = [self getValue:details key:@"alarm2"];
            ep_mode_id = [self getValue:details key:@"ep_mode_id"];
            level = [self getValue:details key:@"level"];
            zone_type = [self getValue:details key:@"zone_type"];
            ir_sensor_status = [self getValue:details key:@"ir_sensor_status"];
            o3 = [self getValue:details key:@"o3"];
            co = [self getValue:details key:@"co"];
            no = [self getValue:details key:@"no"];
            no2 = [self getValue:details key:@"no2"];
            so2 = [self getValue:details key:@"so2"];
            noise = [self getValue:details key:@"noise"];
            colormode = [self getValue:details key:@"colormode"];
            lux = [self getValue:details key:@"lux"];
            pm2_5 = [self getValue:details key:@"pm2_5"];
            sn = [self getValue:details key:@"sn"];
            verify_code = [self getValue:details key:@"verify_code"];
            ip = [self getValue:details key:@"ip"];
            ipcamip = [self getValue:details key:@"ipcamip"];
            ipcamport = [self getValue:details key:@"ipcamport"];
            flip = [self getValue:details key:@"flip"];
            username = [self getValue:details key:@"username"];
            password = [self getValue:details key:@"password"];
            mirror = [self getValue:details key:@"mirror"];
            detailsUid = [self getValue:details key:@"uid"];
            //Lora设备特有字段
            water1_leak = [NSString stringWithFormat:@"%@",[self getValue:details key:@"water1_leak"]] ;
            water2_leak = [NSString stringWithFormat:@"%@",[self getValue:details key:@"water2_leak"]];
            onoff_status1 = [self getValue:details key:@"onoff_status1"];
            onoff_status2 = [self getValue:details key:@"onoff_status2"];
            ADC_raw_value1 = [NSString stringWithFormat:@"%@",[self getValue:details key:@"ADC_raw_value1"]] ;
            ADC_raw_value2 = [NSString stringWithFormat:@"%@",[self getValue:details key:@"ADC_raw_value2"]];
            temperature1 = [NSString stringWithFormat:@"%@",[self getValue:details key:@"temperature1"]] ;
            temperature2 = [NSString stringWithFormat:@"%@",[self getValue:details key:@"temperature2"]];
            value = [NSString stringWithFormat:@"%@",[self getValue:details key:@"value"]];
            attr = [NSString stringWithFormat:@"%@",[self getValue:details key:@"attr"]];
            unit = [NSString stringWithFormat:@"%@",[self getValue:details key:@"unit"]];
            
            //lora字段
            NSArray * attributesArray = details[@"attributes"];
            NSMutableArray * arr = [NSMutableArray arrayWithCapacity:1];
            NSMutableString * dicStr = [NSMutableString string];
            if (attributesArray)
            {
                for (NSDictionary * dic in attributesArray) {
                    dicStr = [[NetvoxCommon dictionaryToJson:dic] mutableCopy];
                    [arr addObject:dicStr];
                }
            }
            
            attributes = [arr componentsJoinedByString:@",,"];
            
            
            
            nwkaddr = [self getValue:details key:@"nwkaddr"];
            nvr_channel = [self getValue:details key:@"nvr_channel"];
            nvr_sn = [self getValue:details key:@"nvr_sn"];
            nvr_verify_code = [self getValue:details key:@"nvr_verify_code"];
            onoff_dir = [self getValue:details key:@"onoff_dir"];
            
            //可以设置波导率的设备有的字段
            comport_param = details[@"comport_param"];
            if (comport_param) {
                baudrate = [NSString stringWithFormat:@"%@",[self getValue:comport_param key:@"baudrate"]];
                parity = [NSString stringWithFormat:@"%@",[self getValue:comport_param key:@"parity"]];
                stopbit = [NSString stringWithFormat:@"%@",[self getValue:comport_param key:@"stopbit"]];
            }
            
            setting_temperature = [NSString stringWithFormat:@"%@",[self getValue:details key:@"setting_temperature"]];
            windspeed = [NSString stringWithFormat:@"%@",[self getValue:details key:@"windspeed"]];
            
            sampling_period = [self getValue:details key:@"sampling_period"];
            sunlight_level =  [self getValue:details key:@"sunlight_level"];
            
            
            //温控器 z100ba
            actual_fanspeed = [NSString stringWithFormat:@"%@",[self getValue:details key:@"actual_fanspeed"]];
            indoortemp = [NSString stringWithFormat:@"%@",[self getValue:details key:@"indoortemp"]];
            mode = [NSString stringWithFormat:@"%@",[self getValue:details key:@"mode"]];
            preset_fanspeed = [NSString stringWithFormat:@"%@",[self getValue:details key:@"preset_fanspeed"]];
            settemp = [NSString stringWithFormat:@"%@",[self getValue:details key:@"settemp"]];
            report_status_period = [NSString stringWithFormat:@"%@",[self getValue:details key:@"report_status_period"]];
            
            //三相
            a_current = [NSString stringWithFormat:@"%@",[self getValue:details key:@"a_current"]];
            a_energy = [NSString stringWithFormat:@"%@",[self getValue:details key:@"a_energy"]];
            a_power = [NSString stringWithFormat:@"%@",[self getValue:details key:@"a_power"]];
            a_voltage = [NSString stringWithFormat:@"%@",[self getValue:details key:@"a_voltage"]];
            b_current = [NSString stringWithFormat:@"%@",[self getValue:details key:@"b_current"]];
            b_energy = [NSString stringWithFormat:@"%@",[self getValue:details key:@"b_energy"]];
            b_power = [NSString stringWithFormat:@"%@",[self getValue:details key:@"b_power"]];
            b_voltage = [NSString stringWithFormat:@"%@",[self getValue:details key:@"b_voltage"]];
            c_current = [NSString stringWithFormat:@"%@",[self getValue:details key:@"c_current"]];
            c_energy = [NSString stringWithFormat:@"%@",[self getValue:details key:@"c_energy"]];
            c_power = [NSString stringWithFormat:@"%@",[self getValue:details key:@"c_power"]];
            c_voltage = [NSString stringWithFormat:@"%@",[self getValue:details key:@"c_voltage"]];
            
            //判断设备是否显示在首页的字段main_device_type 赋值
            if([devicetype isEqualToString: @"1004001"])
            {
                main_device_type = @"music";
            }
            else if([devicetype isEqualToString: @"1003001"])
            {
                NSArray *strArr = [udeviceid componentsSeparatedByString:@"_"];
                if(strArr.count > 2)
                {
                    NSString * deviceId = strArr[1];
                    if([deviceId isEqualToString: @"00"] && ![arm_status isEqualToString:@""])
                    {
                        //网关
                        main_device_type = @"gateway";
                    }
                    else if(([deviceId isEqualToString: @"0E"] || [deviceId isEqualToString: @"0e"])&& ![onoff_status isEqualToString:@""])
                    {
                        //智能插座
                        main_device_type = @"mainsPowerOutlet";
                    }
                    else if(![[NSString stringWithFormat:@"%@",ir_sensor_status] isEqualToString:@""])
                    {
                        //红外
                        main_device_type = @"occupySensor";
                    }
                    else if(![[NSString stringWithFormat:@"%@",power] isEqualToString:@""] && ![[NSString stringWithFormat:@"%@",current] isEqualToString:@""] && ![[NSString stringWithFormat:@"%@",voltage] isEqualToString:@""]  && ![[NSString stringWithFormat:@"%@",energy] isEqualToString:@""] && [[NSString stringWithFormat:@"%@",onoff_status] isEqualToString:@""])
                    {
                        //电能统计
                        main_device_type = @"powerStatic";
                    }
                    else if(([deviceId isEqualToString: @"01"] || [deviceId isEqualToString: @"08"] || [deviceId isEqualToString: @"13"] || [deviceId isEqualToString: @"0B"] || [deviceId isEqualToString: @"0b"] || [deviceId isEqualToString:@"16"]) && (![[NSString stringWithFormat:@"%@",temperature] isEqualToString:@""] || ![[NSString stringWithFormat:@"%@",humidity] isEqualToString:@""] || [[NSString stringWithFormat:@"%@",water_temperature] isEqualToString:@""]))
                    {
                        //温湿度
                        main_device_type = @"temperature";
                    }
                    else if([deviceId isEqualToString: @"04"] && ![[NSString stringWithFormat:@"%@",lux] isEqualToString:@""])
                    {
                        //光照感应
                        main_device_type = @"lightSensor";
                    }
                    else if([deviceId isEqualToString: @"03"] || [deviceId isEqualToString: @"07"] || [deviceId isEqualToString: @"0c"] || [deviceId isEqualToString: @"0C"] || [deviceId isEqualToString: @"1C"] || [deviceId isEqualToString: @"1c"] || [deviceId isEqualToString: @"36"] || [deviceId isEqualToString: @"09"] || [deviceId isEqualToString: @"0D"] || [deviceId isEqualToString: @"0d"] || [deviceId isEqualToString: @"35"] || [deviceId isEqualToString: @"37"] || [deviceId isEqualToString: @"05"])
                    {
                        //                      ZB11E
                        if(![[NSString stringWithFormat:@"%@",ir_sensor_status] isEqualToString:@""])
                        {
                            main_device_type = @"ZB11E";
                        }
                        //Z726 Z727 ZA05
                        else if([deviceId isEqualToString: @"09"] || [deviceId isEqualToString: @"0D"] || [deviceId isEqualToString: @"0d"] || [deviceId isEqualToString: @"35"] || [deviceId isEqualToString: @"37"] || [deviceId isEqualToString: @"05"])
                        {
                            main_device_type =@"臭氧";
                        }
                        //含有土壤水分
                        else if(![[NSString stringWithFormat:@"%@",soil_moisture] isEqualToString:@""])
                        {
                            main_device_type = @"土壤水分";
                        }
                        //温度、湿度、紫外线
                        else if(![[NSString stringWithFormat:@"%@",temperature] isEqualToString:@""]&&![[NSString stringWithFormat:@"%@",humidity] isEqualToString:@""])
                        {
                            main_device_type = @"温度、湿度";
                            if(![[NSString stringWithFormat:@"%@",pm2_5] isEqualToString:@""])
                            {
                                //空净
                                main_device_type = @"simpleSensor_airCleaner";
                            }
                            //
                        }
                    }
                    else if (![water1_leak isEqualToString:@""] && ![water2_leak isEqualToString:@""])
                    {
                        //311w
                        main_device_type = @"water12_leak";
                    }
                    else if ((([deviceId isEqualToString:@"1D"] ||[deviceId isEqualToString:@"1d"] || [deviceId isEqualToString:@"02"])&& ![onoff_status isEqualToString:@""]) || [deviceId isEqualToString: @"3e"]|| [deviceId isEqualToString: @"3E"] ) //LORA_3E    R718F2
                    {
                        //lora 门磁
                        main_device_type = @"zone_contactSwitch";
                    }
                    else if ([deviceId isEqualToString:@"1A"] ||[deviceId isEqualToString:@"1a"] ||[deviceId isEqualToString:@"2F"] ||[deviceId isEqualToString:@"2f"])
                    {
                        //lora 贵重物品 震动
                        main_device_type = @"zone_vibrationMovementSensor";
                    }
                    else if ([deviceId isEqualToString:@"31"] || [deviceId isEqualToString:@"1B"] || [deviceId isEqualToString:@"1b"])
                    {
                        //lora 个人紧急
                        main_device_type = @"zone_personalEmergercy";
                    }
//                    //r718ib2  LORA_42 41
                    else if (![ADC_raw_value1 isEqualToString:@""] && ![ADC_raw_value2 isEqualToString:@""])
                    {
                        //R718IB2 lora检测电压
                        //电能统计
                        main_device_type = @"powerStatic";
                    }

                    
                }
            }
            else if(udeviceid != nil)
            {
                NSArray *strArr = [udeviceid componentsSeparatedByString:@"_"];
                if(strArr.count > 2)
                {
                    NSString * deviceId = strArr[1];
                    
                    
                    if([deviceId isEqualToString: @"0007"] && ![arm_status isEqualToString:@""])
                    {
                        //网关
                        main_device_type = @"gateway";
                    }
                    else if([deviceId isEqualToString: @"0200"] && ![[NSString stringWithFormat:@"%@",level] isEqualToString:@""])
                    {
                        //窗帘
                        main_device_type = @"shade";
                    }
                    else if([deviceId isEqualToString: @"0101"] && ![[NSString stringWithFormat:@"%@",level] isEqualToString:@""])
                    {
                        if([udeviceid containsString:@"z815p"] || [udeviceid containsString:@"Z815P"] || [udeviceid containsString:@"Z815p"] || [udeviceid containsString:@"z815P"])
                        {
                            //风扇
                            main_device_type = @"fan";
                        }
                        else
                        {
                            //可调灯
                            main_device_type = @"dimmableLight";
                        }
                    }
                    else if([deviceId isEqualToString: @"0009"] && ![onoff_status isEqualToString:@""])
                    {
                        //智能插座
                        main_device_type = @"mainsPowerOutlet";
                    }
                    else if(![[NSString stringWithFormat:@"%@",ir_sensor_status] isEqualToString:@""])
                    {
                        //红外
                        main_device_type = @"occupySensor";
                    }
                    else if(![[NSString stringWithFormat:@"%@",power] isEqualToString:@""] && ![[NSString stringWithFormat:@"%@",current] isEqualToString:@""] && ![[NSString stringWithFormat:@"%@",voltage] isEqualToString:@""]  && ![[NSString stringWithFormat:@"%@",energy] isEqualToString:@""] && [[NSString stringWithFormat:@"%@",onoff_status] isEqualToString:@""])
                    {
                        //电能统计
                        main_device_type = @"powerStatic";
                    }
                    else if([deviceId isEqualToString: @"0302"] && (![[NSString stringWithFormat:@"%@",temperature] isEqualToString:@""] || ![[NSString stringWithFormat:@"%@",humidity] isEqualToString:@""] || [[NSString stringWithFormat:@"%@",water_temperature] isEqualToString:@""]))
                    {
                        //温湿度
                        main_device_type = @"temperature";
                    }
                    else if([deviceId isEqualToString: @"0403"])
                    {
                        //IASwarning
                        main_device_type = @"IASwarning";
                    }
                    else if([deviceId isEqualToString: @"000A"] || [deviceId isEqualToString: @"000a"])
                    {
                        //门锁
                        main_device_type = @"doorLock";
                    }
                    else if([deviceId isEqualToString: @"0106"] && ![[NSString stringWithFormat:@"%@",lux] isEqualToString:@""])
                    {
                        //光照感应
                        main_device_type = @"lightSensor";
                    }
                    else if([deviceId isEqualToString: @"000C"] || [deviceId isEqualToString: @"000c"])
                    {
//                      ZB11E
                        if(![[NSString stringWithFormat:@"%@",ir_sensor_status] isEqualToString:@""])
                        {
                            //Zb11e
                            main_device_type = @"ZB11E";
                        }
//                      Z726
                        else if([udeviceid containsString:@"Z726"] || [udeviceid containsString:@"Z727"] || [udeviceid containsString:@"ZA07"])
                        {
                            //Z726
                            main_device_type =@"臭氧";
                        }
                        //含有土壤水分
                        else if(![[NSString stringWithFormat:@"%@",soil_moisture] isEqualToString:@""])
                        {
                            //含土壤水分
                            main_device_type = @"土壤水分";
                            //含土壤水分、温度、电导率
//                            if(![[NSString stringWithFormat:@"%@",土壤温度] isEqualToString:@""] && ![[NSString stringWithFormat:@"%@",电导率] isEqualToString:@""])
//                            {
//                                main_device_type = @"土壤水分、温度、电导率";
//                            }
                        }
//                        温度、湿度、紫外线
                        else if(![[NSString stringWithFormat:@"%@",temperature] isEqualToString:@""]&&![[NSString stringWithFormat:@"%@",humidity] isEqualToString:@""])
                        {
                            //温度、湿度、紫外线
                            main_device_type = @"温度、湿度";
//                            if(![[NSString stringWithFormat:@"%@",紫外线] isEqualToString:@""])
//                            {
//                                main_device_type = @"温度、湿度、紫外线";
//                                if(![[NSString stringWithFormat:@"%@",sunlight_intensity])
//                                 {
//                                     main_device_type = @"温度、湿度、紫外线、日照强度";
//                                 }
//                            }
//                            else
                            if(![[NSString stringWithFormat:@"%@",pm2_5] isEqualToString:@""])
                            {
                                //空净
                                main_device_type = @"simpleSensor_airCleaner";
                            }
//
                        }
                        
                    }
                    else if(([deviceId isEqualToString: @"000D"] && [udeviceid containsString:@"ZL01K"]) || ([deviceId isEqualToString: @"000d"] && [udeviceid containsString:@"ZL01K"]))
                    {
                        //三相电能转换器
                        main_device_type = @"三相";
                    }
                    else if(([deviceId isEqualToString: @"0002"] && ![onoff_status isEqualToString:@""]) || ([deviceId isEqualToString: @"0100"]  && ![onoff_status isEqualToString:@""]))
                    {
                        //选择开关
                        main_device_type = @"onOffOutput";
                    }
                    else if([deviceId isEqualToString: @"0102"])
                    {
                        //彩灯
                        main_device_type = @"colorLight";
                    }
                    else if([deviceId isEqualToString: @"0402"] && ![zone_type isEqualToString:@""])
                    {
                        if([zone_type isEqualToString:@"contact_switch"])
                        {
                            //zone 门磁
                            main_device_type = @"zone_contactSwitch";
                        }
                        else if([zone_type isEqualToString:@"key_fob"])
                        {
                            //zone 按键
                            main_device_type = @"zone_keyFob";
                        }
                        else if([zone_type isEqualToString:@"gas_sensor"])
                        {
                            //zone 气体
                            main_device_type = @"zone_gasSensor";
                        }
                        else if([zone_type isEqualToString:@"fire_sensor"])
                        {
                            //zone 火警
                            main_device_type = @"zone_fireSensor";
                        }
                        else if([zone_type isEqualToString:@"motion_sensor"])
                        {
                            //zone 红外
                            main_device_type = @"zone_motionSensor";
                        }
                        else if([zone_type isEqualToString:@"personal_emergency_device"])
                        {
                            //zone 个人紧急
                            main_device_type = @"zone_personalEmergercy";
                        }
                        else if([zone_type isEqualToString:@"vibration/movement sensor"] || [zone_type isEqualToString:@"vibration_movement_sensor"])
                        {
                            //zone 贵重物品
                            main_device_type = @"zone_vibrationMovementSensor";
                        }
                        else if([zone_type isEqualToString:@"water_sensor"])
                        {
                            //zone 液体
                            main_device_type = @"zone_waterSensor";
                        }
  
                    }
                    else if ([deviceId isEqualToString:@"0301"] && ![[NSString stringWithFormat:@"%@",actual_fanspeed] isEqualToString:@""])
                    {
                        main_device_type = @"Thermostat";
                    }
                }
            }
          
            

        }
        
        //更新标识符
        NSString *update_flag = @"0";
        
        //频率统计
        NSString *fre = @"0";
    
        //根据需要,编写不改变的值
        for (NSDictionary *oldDic in deviceArr) {
            if ([oldDic[@"uid"] isEqualToString:uid]) {
                //赋予不需改变的值
                fre = oldDic[@"fre"];
                break;
            }
        }

        NSString *sqlStr1 = [NSString stringWithFormat:@"REPLACE INTO '%@'('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",tableName,@"uid",@"devicetype",@"name",@"pic",@"roomid",@"status",@"udeviceid",@"ieee",@"ep",@"arm_status",@"current",@"energy",@"onoff_status",@"power",@"voltage",@"update_flag",@"house_ieee",@"humidity",@"temperature",@"water_temperature",@"enable",@"sunlight_intensity",@"soil_moisture",@"update_time",@"alarm1",@"fre",@"alarm2",@"ep_mode_id",@"level",@"zone_type",@"ir_sensor_status",@"o3",@"co",@"no",@"no2",@"so2",@"noise",@"lux",@"pm2_5",@"sn",@"verify_code",@"main_device_type",@"ip",@"colormode",@"ipcamip",@"ipcamport",@"flip",@"username",@"password",@"mirror",@"detailsUid",@"water1_leak",@"water2_leak",@"temperature1",@"temperature2",@"ADC_raw_value1",@"ADC_raw_value2",@"onoff_status1",@"onoff_status2",@"nwkaddr",@"nvr_channel",@"nvr_sn",@"nvr_verify_code",@"onoff_dir",@"baudrate",@"parity",@"stopbit",@"sampling_period",@"sunlight_level",@"actual_fanspeed",@"indoortemp",@"mode",@"preset_fanspeed",@"settemp",@"report_status_period",@"unit",@"attr",@"value",@"attributes",@"setting_temperature",@"windspeed",@"a_current",@"a_energy",@"a_power",@"a_voltage",@"b_current",@"b_energy",@"b_power",@"b_voltage",@"c_current",@"c_energy",@"c_power",@"c_voltage"];
        

        NSString *sqlStr2 = [NSString stringWithFormat:@" VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",uid,devicetype,name,pic,roomid,status,udeviceid,ieee,ep,arm_status,current,energy,onoff_status,power,voltage,update_flag,house_ieee,humidity,temperature,water_temperature,enable,sunlight_intensity,soil_moisture,update_time,alarm1,fre,alarm2,ep_mode_id,level,zone_type,ir_sensor_status,o3,co,no,no2,so2,noise,lux,pm2_5,sn,verify_code,main_device_type,ip,colormode,ipcamip,ipcamport,flip,username,password,mirror,detailsUid,water1_leak,water2_leak,temperature1,temperature2,ADC_raw_value1,ADC_raw_value2,onoff_status1,onoff_status2,nwkaddr,nvr_channel,nvr_sn,nvr_verify_code,onoff_dir,baudrate,parity,stopbit,sampling_period,sunlight_level,actual_fanspeed,indoortemp,mode,preset_fanspeed,settemp,report_status_period,unit,attr,value,attributes,setting_temperature,windspeed,a_current,a_energy,a_power,a_voltage,b_current,b_energy,b_power,b_voltage,c_current,c_energy,c_power,c_voltage];
        
        NSString *sqlCreateTable=[NSString stringWithFormat:@"%@%@",sqlStr1,sqlStr2];
        
        return sqlCreateTable;

        
    }
    else if([tableName isEqualToString:TABLE_ROOM] )
    {
        //房间列表
        NSString *uid =[self getValue:dataDic key:@"id"];
        NSString *name =[self getValue:dataDic key:@"name"];
        NSString *picture =[self getValue:dataDic key:@"picture"];
        
        //更新标识符
        NSString *update_flag = @"0";
        
        //增加网关ieee
        NSString *house_ieee = user.currentHouseIeee ? user.currentHouseIeee : @"";
        
        NSString *sqlStr1 = [NSString stringWithFormat:@"REPLACE INTO '%@'('%@','%@','%@','%@','%@')",tableName,@"uid",@"name",@"picture",@"update_flag",@"house_ieee"];
        
        NSString *sqlStr2 = [NSString stringWithFormat:@" VALUES ('%@','%@','%@','%@','%@')",uid,name,picture,update_flag,house_ieee];
        
        NSString *sqlCreateTable=[NSString stringWithFormat:@"%@%@",sqlStr1,sqlStr2];
        
        return sqlCreateTable;
        
    }
    

    else if([tableName isEqualToString:TABLE_MSG] )
    {
        //消息列表
        NSString *Id =[self getValue:dataDic key:@"id"];
        NSString *type =[self getValue:dataDic key:@"type"];
        NSString *dev_id =[self getValue:dataDic key:@"dev_id"];
        NSString *warn_type =[self getValue:dataDic key:@"warn_type"];
        NSString *time =[self getValue:dataDic key:@"time"];
        NSString *username =[self getValue:dataDic key:@"user"];

        NSString * desc = [self getValue:dataDic key:@"desc"];
        NSString * roomid = [self getValue:dataDic key:@"roomid"];
        //在联动/模式动作中 添加了自定义消息相关联动/模式的告警消息  显示自定义内容 其callback字段为msg
        NSString *message = [self getValue:dataDic key:@"msg"];
        
        NSString *msg_type = @"warn";
        if([warn_type intValue] >200000)
        {
            msg_type = @"msg";
        }
        
        //串口消息(485 callback添加) 30001
        NSString * cmd_type = [self getValue:dataDic key:@"cmd_type"];
        NSString * data = [self getValue:dataDic key:@"data"];
        
        //网关位置更改 40001
        NSString * devname = [self getValue:dataDic key:@"devname"];
        NSString * areaid = [self getValue:dataDic key:@"areaid"];
        NSString * areaname = [self getValue:dataDic key:@"areaname"];
        NSString * singal = [self getValue:dataDic key:@"singal"];
        NSString * ext = [self getValue:dataDic key:@"ext"];
        
        
        //更新标识符
        NSString *update_flag = @"0";
        //标记
        NSString *mark = @"0";
        
        //增加网关ieee
        NSString *house_ieee = [[self getValue:dataDic key:@"house_ieee"] isEqualToString:@""] ? user.currentHouseIeee : [self getValue:dataDic key:@"house_ieee"];
        
        //            重复性检查
        NSString * sqlCheck = [NSString stringWithFormat:
                               @"SELECT COUNT(*) FROM %@ where %@='%@' and  %@='%@' and  %@='%@'",tableName,@"id",Id,@"time",time,@"dev_id",dev_id];
        int countCheck=[db intForQuery:sqlCheck];
        if (countCheck>0) {
            return nil;
        }

        
        NSString *sqlStr1 = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",tableName,@"id",@"type",@"dev_id",@"warn_type",@"time",@"update_flag",@"house_ieee",@"msg_type",@"mark",@"username",@"message",@"cmd_type",@"data",@"devname",@"areaid",@"areaname",@"singal",@"ext",@"desc",@"roomid"];
        
        NSString *sqlStr2 = [NSString stringWithFormat:@" VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",Id,type,dev_id,warn_type,time,update_flag,house_ieee,msg_type,mark,username,message,cmd_type,data,devname,areaid,areaname,singal,ext,desc,roomid];
        
        NSString *sqlCreateTable=[NSString stringWithFormat:@"%@%@",sqlStr1,sqlStr2];
        
        return sqlCreateTable;

    }
    
    else if([tableName isEqualToString:TABLE_VERSION] )
    {
        //版本控制
        NSString *version =[self getValue:dataDic key:@"version"];
        
        
        
        NSString *sqlStr1 = [NSString stringWithFormat:@"REPLACE INTO '%@'('%@')",tableName,@"version"];
        
        NSString *sqlStr2 = [NSString stringWithFormat:@" VALUES ('%@')",version];
        
        NSString *sqlCreateTable=[NSString stringWithFormat:@"%@%@",sqlStr1,sqlStr2];
        
        return sqlCreateTable;
        
    }
    //报表
    else if ([tableName isEqualToString:TABLE_REPORT])
    {
        //
        NSString * avg_value = [self getValue:dataDic[@"result"] key:@"avg_value"];
        //dataDic[@"result"][@"avg_value"];
        //[self getValue:dataDic key:@"avg_value"];
        
        NSString * curr_value = [self getValue:dataDic[@"result"] key:@"curr_value"];
        NSString * max_value = [self getValue:dataDic[@"result"] key:@"max_value"];
        NSString * min_value = [self getValue:dataDic[@"result"] key:@"min_value"];
        NSString * total_value = [self getValue:dataDic[@"result"] key:@"total_value"];
        NSString * unit = [self getValue:dataDic[@"result"] key:@"unit"];
        NSString * request_time = [self getValue:dataDic[@"result"] key:@"request_time"];
        NSArray * array = dataDic[@"result"][@"values"];
//        NSString * value = [array componentsJoinedByString:@","];
        
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:1];
        NSMutableString * dicStr = [NSMutableString string];
        for (NSDictionary * dic in array) {
            dicStr = [[NetvoxCommon dictionaryToJson:dic] mutableCopy];
            [arr addObject:dicStr];
        }
        
        NSString * value = [arr componentsJoinedByString:@",,"];

        NSString *sqlStr1 = [NSString stringWithFormat:@"REPLACE INTO '%@'('%@','%@','%@','%@','%@','%@','%@','%@')",tableName,@"avg_value",@"curr_value",@"max_value",@"min_value",@"unit",@"request_time",@"value",@"total_value"];
        
        NSString *sqlStr2 = [NSString stringWithFormat:@" VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')",avg_value,curr_value,max_value,min_value,unit,request_time,value,total_value];
        
        NSString *sqlCreateTable=[NSString stringWithFormat:@"%@%@",sqlStr1,sqlStr2];
        
        return sqlCreateTable;
    }

    
    return nil;
}



#pragma mark--删

//完全删除整个表(注:该方法会删除整个表!!!)
+(BOOL)drop:(NSString *)tableName
{
    __block BOOL res = NO;
    if (!isInit) {
        return res;
    }

    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inDatabase:^(NetvoxFMDatabase *db) {
        if ([db open]) {
            NSString * sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",tableName];
            if (sql) {
                res = [db executeUpdate:sql];
            }
            if (!res) {
               
                [NetvoxCommon print:@"error when insert db table"];
            } else {
    
                [NetvoxCommon print:@"success to insert db table"];
            }
            
            [db close];
        }
        
    }];
    
    
    return res;

}

//删除(表名tableName必须传,其他参数均为可选参数,不传的时候传nil;addArr:与条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];orArr:或条件数组,数组中存放字典,字典样式和addArr一样)
+(BOOL)del:(NSString *)tableName addArr:(NSArray *)addArr orArr:(NSArray *)orArr
{
    __block BOOL res = NO;
    if (!isInit) {
        return res;
    }

    
    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inDatabase:^(NetvoxFMDatabase *db) {
        if ([db open]) {
            NSString * sql = [NSString stringWithFormat:@"delete from %@",tableName];
            
            //添加且条件
            sql = [NetvoxDb getAddFiled:sql addArr:addArr];
            
            //添加或条件
            sql = [NetvoxDb getOrFiled:sql orArr:orArr];
            
            
            res = [db executeUpdate:sql];
            
            [db close];
        }
        
    }];
    
    return res;

}

#pragma mark--查
//查询(表名tableName必须传,其他参数均为可选参数,不传的时候传nil;addArr:与条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];orArr:或条件数组,数组中存放字典,字典样式和addArr一样;orderDic:排序参数,字典key分别为key:排序的key,op:升序值为asc,降序为desc,例如@[@{@"key":@"ieee",@"op":@"asc"}];limitDic:分页参数,字典key分别为:index:起始页,size:取出指定条数)
+(NSMutableArray *)query:(NSString *)tableName addArr:(NSArray *)addArr orArr:(NSArray *)orArr orderDic:(NSDictionary *)orderDic limitDic:(NSDictionary *)limitDic
{
    __block NSMutableArray *arrQuery = [[NSMutableArray alloc]init];
    if (!isInit) {
        return arrQuery;
    }

    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inDatabase:^(NetvoxFMDatabase *db) {
        if ([db open]) {
            NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
            
            //添加且条件
            sql = [NetvoxDb getAddFiled:sql addArr:addArr];
            
            //添加或条件
            sql = [NetvoxDb getOrFiled:sql orArr:orArr];
            
            //添加排序条件
            sql = [NetvoxDb getOrderFiled:sql orderDic:orderDic];
            
            //添加取个数条件
            sql = [NetvoxDb getLimitFiled:sql limitDic:limitDic];
            
            NetvoxFMResultSet * rs = [db executeQuery:sql];
            while ([rs next]) {
                [arrQuery addObject:[NetvoxDb getData:rs andTableName:tableName FMDatabase:db]];
            }

            
            [db close];
        }
        
    }];
    
    
    return arrQuery;
}

//查询(表名tableName必须传,其他参数均为可选参数,不传的时候传nil;addArr:与条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];orArr:或条件数组,数组中存放字典,字典样式和addArr一样;orderDic:排序参数,字典key分别为key:排序的key,op:升序值为asc,降序为desc,例如@[@{@"key":@"ieee",@"op":@"asc"}];limitDic:分页参数,字典key分别为:index:起始页,size:取出指定条数)   用于报表
+(NSMutableDictionary *)query:(NSString *)tableName addArr:(NSArray *)addArr orderDic:(NSDictionary *)orderDic
{
    __block NSMutableDictionary *dicQuery = [[NSMutableDictionary alloc]init];
    if (!isInit) {
        return dicQuery;
    }
    
    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inDatabase:^(NetvoxFMDatabase *db) {
        if ([db open]) {
            NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
            
            //添加且条件
            sql = [NetvoxDb getAddFiled:sql addArr:addArr];
            
            //添加或条件
//            sql = [NetvoxDb getOrFiled:sql orArr:orArr];
            
            //添加排序条件
            sql = [NetvoxDb getOrderFiled:sql orderDic:orderDic];
            
            //添加取个数条件
//            sql = [NetvoxDb getLimitFiled:sql limitDic:limitDic];
            
            NetvoxFMResultSet * rs = [db executeQuery:sql];
            while ([rs next]) {
//                [arrQuery addObject:[NetvoxDb getData:rs andTableName:tableName FMDatabase:db]];
                [dicQuery setDictionary:[NetvoxDb getData:rs andTableName:tableName FMDatabase:db]];
            }
            
            
            [db close];
        }
        
    }];
    NSArray * array = [dicQuery[@"value"] componentsSeparatedByString:@",,"];
    NSMutableArray * copyAry = [NSMutableArray arrayWithCapacity:1];
    for (NSString * str in array) {
        NSDictionary * dic = [NetvoxCommon dictionaryWithJsonString:str];
        [copyAry addObject:dic];
    }
    dicQuery[@"value"] = copyAry;
    return [[NSMutableDictionary alloc]initWithDictionary:@{@"seq":@1234,@"status_code":@0,@"result":dicQuery}];
}





//查询个数(表名tableName必须传,其他参数均为可选参数,不传的时候传nil;addArr:与条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];orArr:或条件数组,数组中存放字典,字典样式和addArr一样)
+(int)queryCount:(NSString *)tableName addArr:(NSArray *)addArr orArr:(NSArray *)orArr
{
   __block int count = 0;
    if (!isInit) {
        return count;
    }

    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inDatabase:^(NetvoxFMDatabase *db) {
        if ([db open]) {
            NSString * sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",tableName];
            
            //添加且条件
            sql = [NetvoxDb getAddFiled:sql addArr:addArr];
            
            //添加或条件
            sql = [NetvoxDb getOrFiled:sql orArr:orArr];
            
            
            count = [db intForQuery:sql];
            
            [db close];
        }
        
    }];

    return count;
}

//添加且条件
+(NSString *)getAddFiled:(NSString *)originSql addArr:(NSArray *)addArr
{
    NSString *sql = originSql;
    if (addArr) {
        sql = [NSString stringWithFormat:@"%@ where",sql];
        for (int i=0; i<addArr.count; i++) {
            NSDictionary *dic = addArr[i];
            NSString *key = dic[@"key"];
            NSString *value = dic[@"value"];
            NSString *op = dic[@"op"];
            if (i == 0) {
                if ([op isEqualToString:@"like"]) {
                    sql = [NSString stringWithFormat:@"%@ %@ %@ '%%%@%%'",sql,key,op,value];
                }
                else
                {
                    sql = [NSString stringWithFormat:@"%@ %@ %@ '%@'",sql,key,op,value];
                }
            }
            else
            {
                if ([op isEqualToString:@"like"]) {
                     sql = [NSString stringWithFormat:@"%@ and %@ %@ '%%%@%%'",sql,key,op,value];
                }
                else
                {
                    sql = [NSString stringWithFormat:@"%@ and %@ %@ '%@'",sql,key,op,value];
                }
            }
            
        }
        
    }
    
    return sql;
}

//添加或条件
+(NSString *)getOrFiled:(NSString *)originSql orArr:(NSArray *)orArr
{
    NSString *sql = originSql;
    if (orArr) {
        //查询是否有where 字段
        NSRange range = [sql rangeOfString:@"where"];
        if (range.location == NSNotFound) {
            sql = [NSString stringWithFormat:@"%@ where",sql];
        }
    
        for (int i=0; i<orArr.count; i++) {
            NSDictionary *dic = orArr[i];
            NSString *key = dic[@"key"];
            NSString *value = dic[@"value"];
            NSString *op = dic[@"op"];
            if (i == 0) {
                if ([op isEqualToString:@"like"]) {
                    sql = [NSString stringWithFormat:@"%@ %@ %@ '%%%@%%'",sql,key,op,value];
                }
                else
                {
                    sql = [NSString stringWithFormat:@"%@ %@ %@ '%@'",sql,key,op,value];
                }
            }
            else
            {
                if ([op isEqualToString:@"like"]) {
                    sql = [NSString stringWithFormat:@"%@ or %@ %@ '%%%@%%'",sql,key,op,value];
                }
                else
                {
                    sql = [NSString stringWithFormat:@"%@ or %@ %@ '%@'",sql,key,op,value];
                }
            }
            
        }
        
    }
    
    return sql;
}


//添加排序
+(NSString *)getOrderFiled:(NSString *)originSql orderDic:(NSDictionary *)orderDic
{
    NSString *sql = originSql;
    if (orderDic) {
        NSString *key = orderDic[@"key"];
        NSString *op = orderDic[@"op"];
         sql = [NSString stringWithFormat:@"%@ order by %@ %@",sql,key,op];
    }
    
    return sql;
}

//添加个数
+(NSString *)getLimitFiled:(NSString *)originSql limitDic:(NSDictionary *)limitDic{
    NSString *sql = originSql;
    if (limitDic) {
        NSString *index = limitDic[@"index"];
        NSString *size = limitDic[@"size"];
        sql = [NSString stringWithFormat:@"%@ limit %@,%@",sql,index,size];
    }
    
    return sql;
}

//获取取得的数据
+(NSMutableDictionary *)getData:(NetvoxFMResultSet *)rs andTableName:(NSString *)tableName FMDatabase:(NetvoxFMDatabase *)queryDb
{
    NSMutableDictionary *dicGetData=[[NSMutableDictionary alloc]initWithCapacity:1];
    //    NSNumber *ipcamID=[NSNumber numberWithInteger:[rs intForColumn:DATABASEID]];
    //    [dicGetData setObject:ipcamID forKey:DATABASEID];
    
    NSString * sql = [NSString stringWithFormat:
                      @"PRAGMA table_info(%@)",tableName];
    NetvoxFMResultSet * rs1 = [queryDb executeQuery:sql];
    while ([rs1 next]) {
        NSString *name=[rs1 stringForColumn:@"name"];
        NSString *type=[rs1 stringForColumn:@"type"];
        if ([type isEqualToString:@"BOOLEAN"]) {
            NSNumber *value=[NSNumber numberWithBool:[rs boolForColumn:name]];
            if (value==nil) {
                value=[NSNumber numberWithBool:NO];
            }
            [dicGetData setObject:value forKey:name];
            
        }
        else if ([type isEqualToString:@"INTEGER"])
        {
            NSNumber *value=[NSNumber numberWithInteger:[rs intForColumn:name]];
            if (value==nil) {
                value=[NSNumber numberWithInteger:0];
            }
            [dicGetData setObject:value forKey:name];
            
        }
        else
        {
            NSString *value=[rs stringForColumn:name];
            if (value==nil) {
                value=@"";
            }
            [dicGetData setObject:value forKey:name];
        }
        
    }
    
    
    return dicGetData;
}


#pragma mark--改

//更新(表名tableName,所有参数必须传,条件更新只考虑与条件更新;conditions:条件数组,数组中存放字典,字典key分别为key:查询的key,value:查询的value,op:查询的条件,有三种=,!=,like,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136",@"op":@"="}];updates:更新数组,数组中存放字典,字典key分别为key:更新的key,value:更新的value,例如@[@{@"key":@"ieee",@"value":@"00137A0000010136"}])
+(BOOL)update:(NSString *)tableName conditions:(NSArray *)conditions updates:(NSArray *)updates
{
    __block BOOL res = NO;
    if (!isInit) {
        return res;
    }

    
    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inDatabase:^(NetvoxFMDatabase *db) {
        if ([db open]) {
            NSString * sql = [NSString stringWithFormat:@"UPDATE %@ SET",tableName];
            
            //添加动作
            sql = [NetvoxDb getUpdates:sql updates:updates];
            
            //添加条件
            sql = [NetvoxDb getUpdateConditions:sql conditions:conditions];
            
            
            res = [db executeUpdate:sql];
            
            [db close];
        }
        
    }];
    
    return res;

}

//多线程事务更新(该方法专门用于处理插入设备列表,房间列表的请求数据,该方法会将多余的数据清除,因此要传入完整的数据)
+(BOOL)update:(NSString *)tableName data:(NSDictionary *)dataDic
{
    __block BOOL res = NO;
    
    if (!isInit) {
        return res;
    }
    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inTransaction:^(NetvoxFMDatabase *db, BOOL *rollback) {
        @try {
            if (dataDic && [dataDic[@"status_code"] intValue] ==0 ) {
                
               
                
                NSArray *resultArr=dataDic[@"result"];
                
                //记录旧数据
                NSMutableArray *oldDataArr =[[NSMutableArray alloc]initWithCapacity:1];
                NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
                NetvoxFMResultSet * rs = [db executeQuery:sql];
                while ([rs next]) {
                    [oldDataArr addObject:[NetvoxDb getData:rs andTableName:tableName FMDatabase:db]];
                }

                
                if ([tableName isEqualToString:TABLE_DEVICE]) {
                    //设备列表
                    deviceArr = [oldDataArr mutableCopy];
                    
                }
                else if ([tableName isEqualToString:TABLE_ROOM])
                {
                    //房间列表
                }

                if ([tableName isEqualToString:TABLE_REPORT]) {
                    //表不同.请求方式不同
//                    for (NSDictionary * resultDic in dataDic) {
                        NSString * sql = [NetvoxDb getInsertSql:tableName data:dataDic db:db];
                        if (sql) {
                            res = [db executeUpdate:sql];
                        }
                        if (!res) {
                            [NetvoxCommon print:@"error when insert db table"];
                            
                        } else {
                            
                            [NetvoxCommon print:@"success to insert db table"];
                        }
//                    }
                }
                else{
                    for (NSDictionary *resultDic in resultArr) {
                        
                        NSString * sql = [NetvoxDb getInsertSql:tableName data:resultDic db:db];
                        if (sql) {
                            res = [db executeUpdate:sql];
                        }
                        if (!res) {
                            [NetvoxCommon print:@"error when insert db table"];
                            
                        } else {
                            
                            if ([tableName isEqualToString:TABLE_DEVICE]) {
                                //设备列表
                                [NetvoxDb delArrData:@"uid" value:resultDic[@"id"] arr:oldDataArr];
                            }
                            else if ([tableName isEqualToString:TABLE_ROOM])
                            {
                                //房间列表
                                [NetvoxDb delArrData:@"uid" value:resultDic[@"id"] arr:oldDataArr];
                            }
                            
                            [NetvoxCommon print:@"success to insert db table"];
                        }
                        
                        
                    }
                }
                
                
                
                //删除多余的数据(告警消息不处理)
                if (![tableName isEqualToString:TABLE_MSG]) {
                    for (NSDictionary *moreData in oldDataArr) {
                        NSString *delSql = @"";
                        if ([tableName isEqualToString:TABLE_DEVICE]) {
                            //设备列表
                            delSql = [NSString stringWithFormat:@"delete from %@ where uid = '%@' and house_ieee = '%@'",tableName,moreData[@"uid"],user.currentHouseIeee];
                        }
                        else if ([tableName isEqualToString:TABLE_ROOM])
                        {
                            //房间列表
                            delSql = [NSString stringWithFormat:@"delete from %@ where uid = '%@' and house_ieee = '%@'",tableName,moreData[@"uid"],user.currentHouseIeee];
                        }
                        
                        
                        
                        [db executeUpdate:delSql];
                        
                    }

                }
                
                
            }
            
            
            res = YES;
        } @catch (NSException *exception) {
            *rollback = YES;
        } @finally {
            
        }
    }];
    
    return res;
}

//根据条件删除数组数据
+(void)delArrData:(NSString *)key value:(NSString *)value arr:(NSMutableArray *)arr
{
    [arr enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[key] isEqualToString:value]) {
            *stop = YES;
        }
        
        if (*stop == YES) {
            [arr removeObjectAtIndex:idx];
        }
        
    }];

}
//拼接更新条件
+(NSString *)getUpdateConditions:(NSString *)originSql conditions:(NSArray *)conditions
{
    NSString *sql = originSql;
 
        sql = [NSString stringWithFormat:@"%@ WHERE",sql];
        for (int i=0; i<conditions.count; i++) {
            NSDictionary *dic = conditions[i];
            NSString *key = dic[@"key"];
            NSString *value = dic[@"value"];
            NSString *op = dic[@"op"];
            if (i == conditions.count-1) {
                if ([op isEqualToString:@"like"]) {
                    sql = [NSString stringWithFormat:@"%@ %@ %@ '%%%@%%'",sql,key,op,value];
                }
                else
                {
                    sql = [NSString stringWithFormat:@"%@ %@ %@ '%@'",sql,key,op,value];
                }
            }
            else
            {
                if ([op isEqualToString:@"like"]) {
                    sql = [NSString stringWithFormat:@"%@ %@ %@ '%%%@%%' and",sql,key,op,value];
                }
                else
                {
                    sql = [NSString stringWithFormat:@"%@ %@ %@ '%@' and",sql,key,op,value];
                }
            }
            
        }
        
    
    
    return sql;
}

//拼接更新的动作
+(NSString *)getUpdates:(NSString *)originSql updates:(NSArray *)updates
{
    NSString *sql = originSql;
    
    
    for (int i=0; i<updates.count; i++) {
        NSDictionary *dic = updates[i];
        NSString *key = dic[@"key"];
        NSString *value = dic[@"value"];
       
        if (i == updates.count-1) {
           
                sql = [NSString stringWithFormat:@"%@ %@ = %@",sql,key,value];
           
        }
        else
        {
            
                sql = [NSString stringWithFormat:@"%@ %@ = %@ ,",sql,key,value];
            
        }
        
    }
    
    
    
    return sql;
}

#pragma mark --其他
//获取消息数据所占大小(大概大小,非精确,采用统计方法,每条数据大概占82B)
+(float)getMsgCacheSize
{
//   __block float size = 0.0;
    
//    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
//    [queue inDatabase:^(NetvoxFMDatabase *db) {
//        if ([db open]) {
//            //sum 里面列出所有的字段
//            NSString * sql = [NSString stringWithFormat:@" select sum( length(uid))/100.0/1024.0 from %@ ",TABLE_MSG];
//            
//            
//            
//            size = [db intForQuery:sql];
//            
//            
//            [db close];
//        }
//        
//    }];
    
    int msgCount = [NetvoxDb queryCount:TABLE_MSG addArr:nil orArr:nil];
    int deviceCount = [NetvoxDb queryCount:TABLE_DEVICE addArr:nil orArr:nil];
    int roomCount = [NetvoxDb queryCount:TABLE_ROOM addArr:nil orArr:nil];
    int reportCount = [NetvoxDb queryCount:TABLE_REPORT addArr:nil orArr:nil];
    float size = (82.0*msgCount/1024) + (82.0*deviceCount/1024) + (82.0*roomCount/1024) + (82.0*reportCount/1024);
    
    return size;
}

//设置消息数据缓存天数(默认15天)
+(void)setMsgCacheSaveWithDays:(int)days
{
    user.msgSaveDays = days;
}
//清除消息数据库缓存数据(消息数据库写好后在初始化后,调用该方法)
+(void)clearMsgCache
{
    int nowTime =(int)[NSDate date].timeIntervalSince1970;
    
    
    NetvoxFMDatabaseQueue *queue=[NetvoxFMDatabaseQueue databaseQueueWithPath:[NetvoxDb getDBPath]];
    [queue inDatabase:^(NetvoxFMDatabase *db) {
        if ([db open]) {
            NSString * sql = [NSString stringWithFormat:@"delete from %@ (where timestamp-%d)<3600*24*%d",TABLE_MSG,nowTime,user.msgSaveDays];
            
             [db executeUpdate:sql];
            
            [db close];
        }
        
    }];
    
   

}


@end
