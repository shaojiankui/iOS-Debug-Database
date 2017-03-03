//
//  SFDebugDBManager.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "SFDebugDBManager.h"
@interface SFDebugDBManager()

@end

@implementation SFDebugDBManager
+ (SFDebugDBManager*)sharedManager
{
    static SFDebugDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
#pragma mark --CRUD
-(NSString*)implode_field_value:(NSDictionary*)data split:(NSString*)split{
    if(!split){
        split = @",";
    }
    NSMutableString *sql = [NSMutableString string];
    NSString *comma = @"";
    for (NSString *key in data) {
        [sql appendString:[NSString stringWithFormat:@"%@%@ = '%@'",comma,key,[data valueForKey:key]]];
        comma = split;
    }
    return sql;
}
-(BOOL)update:(NSString*)table data:(NSDictionary*)data where:(id)condition{
    NSString *sql = [self implode_field_value:data split:nil];
    NSString *where = @"";
    if (!condition) {
        where = @"1";
    } else if ([condition  isKindOfClass:[NSDictionary class]])
    {
        where = [self implode_field_value:condition split:@" AND "];
    } else {
        where = condition;
    }
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE \"%@\" SET %@ WHERE %@",table,sql,where];
    NSLog(@"update: %@",sqlString);
    return [self executeUpdate:sqlString];
}
/**
 *  删除表记录
 *
 *  @param table     表名
 *  @param condition where条件,字符串,或者是数据字典
 *  @param limit     删除记录条数
 *
 *  @return 删除结果
 */
-(BOOL)delete:(NSString*)table where:(id)condition limit:(NSString*)limit{
    NSString *where;
    NSString *limitString =@"";
    if (limit) {
        limitString = [NSString stringWithFormat:@"LIMIT %@",limit];
    }
    if (!condition) {
        where = @"1";
    }else if ([condition  isKindOfClass:[NSDictionary class]]) {
        where = [self implode_field_value:condition split:@" AND "];
    } else {
        where = condition;
    }
    NSString *sqlString =[NSString stringWithFormat:@"DELETE FROM \"%@\" WHERE %@ %@",table,where,limitString];
    NSLog(@"delete %@",sqlString);
    return [self executeUpdate:sqlString];
}
- (NSArray*)getTableData:(sqlite3 *)db sql:(NSString*)sql tableName:(NSString*)tableName{
   return [self executeQuery:sql rowType:SFDebugDBRowTypeObjectWithColumInfo];
}
#pragma mark --other
- (BOOL)openDatabase:(NSString*)databasePath{
    if (self.dbPath && _db && ![databasePath isEqualToString:self.dbPath])
    {
        [self close];
    }
    self.dbPath = databasePath;
    //多线程模式
    sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
    //串行
    //sqlite3_config(SQLITE_CONFIG_SERIALIZED);
    //单线程
    // sqlite3_config(SQLITE_CONFIG_SINGLETHREAD);
    NSString *dbDir = [self.dbPath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbDir]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:dbDir withIntermediateDirectories:YES attributes:nil error:NULL];
        return NO;
    }
    
    if (sqlite3_open([self.dbPath UTF8String], &_db) != SQLITE_OK)
    {
        [self close];
        NSLog(@"Open Database faild。");
        return NO;
    }
    char *errorMsg = nil;
    if (sqlite3_exec(_db, "PRAGMA journal_mode=WAL;", NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSLog(@"Failed to set WAL mode: %s",errorMsg);
    }
    sqlite3_wal_checkpoint(_db, NULL);
    //NSLog(@"Open Database success。");
    return YES;
    
}
- (NSArray*)allTables{
    NSArray *descs = [self executeQuery:@"SELECT tbl_name FROM sqlite_master WHERE type = 'table'" rowType:SFDebugDBRowTypeObject];
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *row in descs) {
        NSString *tblName = [row objectForKey:@"tbl_name"];
        [result addObject:tblName];
    }
    return result;
}
//表
- (NSArray*)infoForTable:(NSString *)table
{
    char *sql = sqlite3_mprintf("PRAGMA table_info(%q)", [table UTF8String]);
    NSString *query = [NSString stringWithUTF8String:sql];
    sqlite3_free(sql);
    return [self executeQuery:query rowType:SFDebugDBRowTypeObject];
}
//表列数
- (NSUInteger)columnsInTable:(NSString *)table
{
    char *sql = sqlite3_mprintf("PRAGMA table_info(%q)", [table UTF8String]);
    NSString *query = [NSString stringWithUTF8String:sql];
    sqlite3_free(sql);
    return [[self executeQuery:query rowType:SFDebugDBRowTypeObject] count];
}
//所有表头
-(NSArray *)columnTitlesInTable:(NSString *)table
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ROWID ASC LIMIT 1",table];
    NSDictionary *result = [[self executeQuery:query rowType:SFDebugDBRowTypeObject] lastObject];
    return [result allKeys];
}
#pragma mark - execute methods
/**
 *  无结果集执行更新
 *
 *  @param sql 完整sql语句
 *
 *  @return 操作结果
 */
-(BOOL)executeUpdate:(NSString*)sql{
    char *err;
    if (sqlite3_exec(_db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        //        sqlite3_close(_db);
        NSLog(@"Database Opration faild!:%s",err);
        return NO;
    }else{
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        //            NSLog(@"Database Opration success!:%@",sql);
        //        });
        return YES;
    }
}
/**
 *  查询结果集
 *
 *  @param query sql语句
 *  @param type  row对象类型枚举,关联对象/关联数组
 *
 *  @return 结果集
 */
- (NSArray *)executeQuery:(NSString *)query rowType:(SFDebugDBRowType)type;
{
    __block NSMutableArray *result = [NSMutableArray array];
    [self executeQuery:query rowType:type withBlock:^(id row, NSError *error, BOOL finished) {
        if (!error)
        {
            if (!finished) {
                [result addObject:row];
            } else {
                // NSLog(@"Query finished!");
            }
        } else {
            NSLog(@"Query error!");
        }
    }];
    
    return result;
}
/**
 *  查询遍历器
 *
 *  @param query          sql语句
 *  @param type           ow对象类型,关联对象/关联数组
 *  @param fetchItemBlock 遍历block,id row为每一条记录对应的对象或者数组
 */
-(void)executeQuery:(NSString *)query rowType:(SFDebugDBRowType)type withBlock:(FetchItemBlock)fetchItemBlock{
    
    NSString *fixedQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    sqlite3_stmt *statement;
    const char *tail;
    __unused int resultCode = sqlite3_prepare_v2(_db, [fixedQuery UTF8String], -1, &statement, &tail);
    if (statement) {
        
        int num_cols, i, column_type;
        id value;
        id obj;

        NSString *key;
        NSMutableDictionary *row;
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            row = [NSMutableDictionary dictionary];
            num_cols = sqlite3_data_count(statement);
            for (i = 0; i < num_cols; i++) {
                obj = nil;
                value= nil;
                column_type = sqlite3_column_type(statement, i);
                
                switch (column_type) {
                    case SQLITE_INTEGER:
                        value = [NSNumber numberWithLongLong:sqlite3_column_int64(statement, i)];
                        break;
                    case SQLITE_FLOAT:
                        value = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
                        break;
                    case SQLITE_TEXT:
                        value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)];
                        break;
                    case SQLITE_BLOB:
                        value = [NSData dataWithBytes:sqlite3_column_blob(statement, i) length:sqlite3_column_bytes(statement, i)];
                        break;
                    case SQLITE_NULL:
                        value = [NSNull null];
                        break;
                    default:{
                        NSLog(@"[SQLITE] UNKNOWN DATATYPE");
                    }
                        break;
                }
                key = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];

                if(type == SFDebugDBRowTypeObjectWithColumInfo){
                    obj = [NSMutableDictionary dictionary];
                    [obj setObject:@(column_type) forKey:@"dataType"];
                    [obj setObject:value?:@"" forKey:@"value"];
                    [obj setObject:key?:@"" forKey:@"key"];
                    [row setObject:obj?:@{} forKey:key];
                }else{
                    [row setObject:value?:@"" forKey:key];
                }
       
            }
            if (fetchItemBlock) {
                if (type == SFDebugDBRowTypeArray) {
                    fetchItemBlock([row allValues], nil, NO);
                }else if(type == SFDebugDBRowTypeObject){
                    fetchItemBlock(row, nil, NO);
                }else{
                    fetchItemBlock(row, nil, NO);
                }
            }
            
        }
        
        sqlite3_finalize(statement);
        if(fetchItemBlock){
            fetchItemBlock(nil, nil, YES);
        }
        
    }else
    {
        NSLog(@"statement is NULL,sql:%@",fixedQuery);
        fetchItemBlock(nil, [NSError errorWithDomain:@"statement is NULL" code:21323 userInfo:@{@"statement为空": @"中文",@"stmt is NULL":@"English"}], YES);
        
    }
    
}

- (BOOL)close
{
    if (_db != NULL)
    {
        if(sqlite3_close(_db) == SQLITE_OK)
        {
            //NSLog(@"Close Database success。");
            return YES;;
        }
        else
        {
            NSLog(@"Close Database faild: %s",sqlite3_errmsg(_db));
            return NO;
        }
    }else{
        NSLog(@"Cannot close a database that is not open.");
    }
    return YES;
}

@end
