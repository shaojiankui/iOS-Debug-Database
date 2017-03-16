//
//  SFDebugDBQueryRespone.m
//  SFDebugDB
//
//  Created by Jakey on 2017/3/1.
//  Copyright © 2017年 www.skyfox.org. All rights reserved.
//

#import "SFDebugDBQueryRespone.h"
#import "SFDebugDBManager.h"
#import "SFDebugDBUtil.h"
//#import "SFDebugDB.h"
#import "SFDebugDBModel.h"
@implementation SFDebugDBQueryRespone

+ (NSString*)getTableListResponse:(NSString*)route databases:(NSDictionary*)databases{
    NSString *database = nil;
    NSDictionary *respone;
    NSMutableArray *list;
    if ([route rangeOfString:@"?database="].location != NSNotFound)
    {
        database = [[route substringFromIndex:[route rangeOfString:@"?"].location+1] sf_url_valueForParameter:@"database"];
    }
    NSLog(@"switch database:%@",database);

    if ([database isEqualToString:@"NSUserDefault"])
    {
        [[SFDebugDBManager sharedManager] close];
        [SFDebugDBManager sharedManager].dbName = @"NSUserDefault";

        NSDictionary *data = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
        list = [NSMutableArray array];
        for (NSString *row in [data allKeys]) {
            [list addObject:row];
        }
        respone  = @{@"rows":list?:[NSNull null]};
    }else
    {
        NSString *databasePath = [databases objectForKey:database];
        [[SFDebugDBManager sharedManager] openDatabase:databasePath];;
        list = [[[SFDebugDBManager sharedManager] allTables] copy];
    }
    respone  = @{@"rows":list?:[NSNull null]};
    return [respone sf_dic_JSONString];
}

+ (NSString*)getAllDataFromTheTableResponse:(NSString*)route {
    NSString *tableName = nil;
    if ([route rangeOfString:@"?tableName="].location != NSNotFound)
    {
        tableName = [route sf_query_valueForParameter:@"tableName"];
    }
    NSLog(@"switch table:%@",tableName);

    if ([[SFDebugDBManager sharedManager].dbName isEqualToString:@"NSUserDefault"])
    {
        NSDictionary *userData = [[NSUserDefaults standardUserDefaults]dictionaryRepresentation];
        NSMutableDictionary *tableData = [NSMutableDictionary dictionary];
        [tableData setObject:@(1) forKey:@"isSelectQuery"];
        [tableData setObject:@(1) forKey:@"isSuccessful"];
        
        NSMutableArray *tableInfoResult = [NSMutableArray array];
        //titles
        id item = [userData objectForKey:tableName];
        NSDictionary *tableInfo = @{@"isPrimary":@(false),@"title":tableName?:@"",@"dataType":@"String"};
        [tableInfoResult addObject:tableInfo];
        [tableData setObject:tableInfoResult forKey:@"tableInfos"];
        
        BOOL isEditable = tableName != nil && [tableData objectForKey:@"tableInfos"] != nil;
        [tableData setObject:@(isEditable) forKey:@"isEditable"];
        
        //rows
        NSMutableArray *rows = [NSMutableArray array];
        if ([item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSNumber class]]) {
            [rows addObject:@[@{@"value":item}]];
        }else  if([item isKindOfClass:[NSArray class]]){
            for (int i = 0; i < [item count]; i++) {
                NSMutableArray *row = [NSMutableArray array];
                id value = [item objectAtIndex:i];
                [row  addObject:@{@"value":value}];
                [rows addObject:row];
            }
        }
        [tableData setObject:rows forKey:@"rows"];
        return  [tableData sf_dic_JSONString];
    }else
    {
        if ([SFDebugDBManager sharedManager].db == NULL) {
            NSDictionary *respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"Please Reselect Database!"};
            return [respone sf_dic_JSONString];
        }
        NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
        NSDictionary *jsonD = [self getTableData:sql table:tableName];
        return  [jsonD sf_dic_JSONString];
    }
    return nil;
    
}
+ (NSString*)getTableNameFromQuery:(NSString*)selectQuery{
    NSArray *words = [selectQuery  componentsSeparatedByString:@" "];
    
    NSInteger fromIndex = 0;
    NSString *table;
    
    for (int i =0;i<[words count];i++) {
        NSString *word = [words objectAtIndex:i];
        if ([word isEqualToString:@"from"]) {
            fromIndex = i;
        }
        if (i == fromIndex+1) {
            if([word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0){
                fromIndex ++;
            }else{
                table = word;
            }
        }
    }
    return table;
}
+ (NSDictionary*)getTableData:(NSString *)sql table:(NSString*)tableName{
    if ([SFDebugDBManager sharedManager].db == NULL) {
        NSDictionary *respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"Please Reselect Database!"};
        return respone;
    }
    if (tableName == nil) {
        tableName = [self getTableNameFromQuery:sql];
    }
    
    if (![[SFDebugDBManager sharedManager] isExistTable:tableName]) {
        NSDictionary *respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"Database table not exist!"};
        return respone;
    }
    
    NSArray *response = [[SFDebugDBManager sharedManager] getTableData:nil sql:sql tableName:tableName];
    
    NSMutableDictionary *tableData = [NSMutableDictionary dictionary];
    [tableData setObject:@(1) forKey:@"isSelectQuery"];
    [tableData setObject:@(1) forKey:@"isSuccessful"];
    
    
    NSArray *tableInfoList = [[SFDebugDBManager sharedManager] infoForTable:tableName];
    //titles
    NSMutableArray *tableInfoResult = [NSMutableArray array];
    for (int i = 0; i < [tableInfoList count]; i++) {
        NSMutableDictionary *tableInfo = [NSMutableDictionary dictionary];
        NSDictionary *column = [tableInfoList objectAtIndex:i];
        if ([[column objectForKey:@"pk"] boolValue]) {
            [tableInfo setObject:@(true) forKey:@"isPrimary"];
        }else{
            [tableInfo setObject:@(false) forKey:@"isPrimary"];
        }
        [tableInfo setObject:[column objectForKey:@"name"]?:@"" forKey:@"title"];
        [tableInfoResult addObject:tableInfo];
    }
    [tableData setObject:tableInfoResult forKey:@"tableInfos"];
    
    BOOL isEditable = tableName != nil && [tableData objectForKey:@"tableInfos"] != nil;
    [tableData setObject:@(isEditable) forKey:@"isEditable"];
    //rows
    NSMutableArray *rows = [NSMutableArray array];
    for (int i = 0; i < [response count]; i++) {
        NSMutableArray *row = [NSMutableArray array];
        NSDictionary *one = [response objectAtIndex:i];
        
        for (int j = 0; j < [tableInfoList  count]; j++) {
            NSString *columeKey = [[tableInfoList objectAtIndex:j] objectForKey:@"name"];
            NSDictionary *columeInfo =  [one objectForKey:columeKey];
            
            NSMutableDictionary *columnData = [NSMutableDictionary dictionary];
            [columnData setObject:[columeInfo objectForKey:@"value"] forKey:@"value"];
            switch ([[columeInfo objectForKey:@"dataType"] integerValue]) {
                case SQLITE_INTEGER:
                    [columnData setObject:@"integer" forKey:@"dataType"];
                    break;
                case SQLITE_FLOAT:
                    [columnData setObject:@"float" forKey:@"dataType"];
                    break;
                case SQLITE_TEXT:
                    [columnData setObject:@"text" forKey:@"dataType"];
                    break;
                case SQLITE_BLOB:
                {
                    [columnData setObject:@"blob" forKey:@"dataType"];
                    [columnData setObject:@"blob" forKey:@"value"];
                }
                    break;
                case SQLITE_NULL:
                    [columnData setObject:@"null" forKey:@"dataType"];
                    break;
                    
                default:{
                    [columnData setObject:@"text" forKey:@"dataType"];
                    //                NSLog(@"[SQLITE] UNKNOWN DATATYPE");
                }
                    break;
            }
            [row  addObject:columnData];
        }
        [rows addObject:row];
    }
   
    [tableData setObject:rows forKey:@"rows"];
    return tableData;
}
//
+ (NSString*)executeQueryAndGetResponse:(NSString*)route {
    if ([SFDebugDBManager sharedManager].db == NULL)
    {
        NSDictionary *respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"Please Reselect Database!"};
        return [respone sf_dic_JSONString];
    }
    
    NSString *query;
    NSString *data;
    NSString *first;
    
    if ([route rangeOfString:@"?query="].location != NSNotFound)
    {
        query = [route sf_query_valueForParameter:@"query"];
    }
    
    if (query.length != 0)
    {
        first = [[[query componentsSeparatedByString:@" "] firstObject] lowercaseString];
        if ([first isEqualToString:@"select"])
        {
            NSDictionary *respone =  [self getTableData:query table:nil];
            data = [respone sf_dic_JSONString];
    
        } else
        {
            BOOL result =  [[SFDebugDBManager sharedManager] executeUpdate:query];
            NSDictionary *respone;
            if (result) {
                respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(true)};
            }else{
                respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"Database Opration faild!"};
            }
            data =[respone sf_dic_JSONString];
        }
    }
    
    if (data == nil) {
        data = [@{@"isSuccessful":@(false)} sf_dic_JSONString];
    }
    return data;
}
//

//
+ (NSString*)updateTableDataAndGetResponse:(NSString*)route{
    NSString *tableName = [route sf_query_valueForParameter:@"tableName"];
    NSString *updatedData = [route sf_query_valueForParameter:@"updatedData"];
    NSArray *rowDataRequests =   [updatedData sf_JSONObejctValue];
    NSMutableDictionary *updateRowResponse = [NSMutableDictionary dictionary];

    if ([[SFDebugDBManager sharedManager].dbName isEqualToString:@"NSUserDefault"])
    {
        NSMutableDictionary *record = [[rowDataRequests firstObject] mutableCopy];
        id userValue = [[NSUserDefaults standardUserDefaults] objectForKey:[record objectForKey:@"title"]];
      
        if ([userValue isKindOfClass:[NSArray class]]) {
//            NSMutableArray *userValues = [userValue mutableCopy];
//            for (id obj in userValue) {
//                if ([obj isEqualToString:[record objectForKey:@"value"]]) {
//                    break;
//                }
//            }
//            [[NSUserDefaults standardUserDefaults] setObject:userValues forKey:[record objectForKey:@"title"]];
//            [[NSUserDefaults standardUserDefaults] synchronize];
            [updateRowResponse setObject:@(false) forKey:@"isSuccessful"];

        }else if([userValue isKindOfClass:[NSString class]])  {
            [[NSUserDefaults standardUserDefaults]setObject:[record objectForKey:@"value"] forKey:[record objectForKey:@"title"]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [updateRowResponse setObject:@(true) forKey:@"isSuccessful"];
        }else{
           //.....
            [updateRowResponse setObject:@(false) forKey:@"isSuccessful"];
        }
        return [updateRowResponse sf_dic_JSONString];

    }else{
        if (rowDataRequests == nil || tableName.length==0)
        {
            [updateRowResponse setObject:@(false) forKey:@"isSuccessful"];
            return [updateRowResponse sf_dic_JSONString];
        }
        
        NSMutableDictionary *contentValues = [NSMutableDictionary dictionary];
        NSMutableDictionary *where = [NSMutableDictionary dictionary];
        for (id rowDataRequest in rowDataRequests) {
            if ([[rowDataRequest objectForKey:@"isPrimary"] boolValue]) {
                [where setObject:[rowDataRequest objectForKey:@"value"]?:[NSNull null] forKey:[rowDataRequest objectForKey:@"title"]];
            } else {
                [contentValues setObject:[rowDataRequest objectForKey:@"value"] forKey:[rowDataRequest objectForKey:@"title"]];
            }
        }
        
        BOOL result =  [[SFDebugDBManager sharedManager] update:tableName data:contentValues where:where];
        [updateRowResponse setObject:@(result?true:false) forKey:@"isSuccessful"];
        return [updateRowResponse sf_dic_JSONString];
    }
    return nil;
}
+ (NSString*)deleteTableDataAndGetResponse:(NSString*)route{
    NSString *tableName = [route sf_query_valueForParameter:@"tableName"];
    NSString *updatedData = [route sf_query_valueForParameter:@"deleteData"];
    NSArray *rowDataRequests =   [updatedData sf_JSONObejctValue];
    
    NSMutableDictionary *updateRowResponse = [NSMutableDictionary dictionary];
    
    if ([[SFDebugDBManager sharedManager].dbName isEqualToString:@"NSUserDefault"])
    {
        NSMutableDictionary *record = [[rowDataRequests firstObject] mutableCopy];
        id userValue = [[NSUserDefaults standardUserDefaults] objectForKey:[record objectForKey:@"title"]];
        
        if ([userValue isKindOfClass:[NSArray class]]) {
            NSMutableArray *userMutableValues = [userValue mutableCopy];
            for (id obj in userMutableValues) {
                if ([obj isEqualToString:[record objectForKey:@"value"]]) {
                    [userMutableValues removeObject:obj];
                    break;
                }
            }
            [[NSUserDefaults standardUserDefaults] setObject:userMutableValues forKey:[record objectForKey:@"title"]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else if([userValue isKindOfClass:[NSString class]])  {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[record objectForKey:@"title"]];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            //.....
        }
        [updateRowResponse setObject:@(true) forKey:@"isSuccessful"];
        return [updateRowResponse sf_dic_JSONString];

    }else
    {
        if (rowDataRequests == nil || tableName.length==0)
        {
            [updateRowResponse setObject:@(false) forKey:@"isSuccessful"];
            return [updateRowResponse sf_dic_JSONString];
        }
        
        NSMutableDictionary *where = [NSMutableDictionary dictionary];
        for (id rowDataRequest in rowDataRequests) {
            if ([[rowDataRequest objectForKey:@"isPrimary"] boolValue]) {
                [where setObject:[rowDataRequest objectForKey:@"value"]?:[NSNull null] forKey:[rowDataRequest objectForKey:@"title"]];
            }
        }
        
        BOOL result = [[SFDebugDBManager sharedManager] delete:tableName where:where limit:nil];
        [updateRowResponse setObject:@(result?true:false) forKey:@"isSuccessful"];
        return [updateRowResponse sf_dic_JSONString];
    }
    return nil;
}
+ (NSString*)getDBNameWithRoute:(NSString*)route{
    NSString *dbName = [route sf_query_valueForParameter:@"dbName"];
    if ([dbName isEqualToString:@"NSUserDefault"]) {
        dbName = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] stringByAppendingString:@".plist"];
    }
    return dbName;
}
+ (NSString*)getContenTypeWithRoute:(NSString*)route{
    NSString *dbName = [route sf_query_valueForParameter:@"dbName"];
    NSString *contentType;
    if ([dbName isEqualToString:@"NSUserDefault"]) {
       contentType =  @"";
    }else{
        contentType =  @"application/octet-stream";
    }
    return contentType;
}
+ (NSData*)getDatabase:(NSString*)route databases:(NSDictionary*)databases{
  
    NSString *dbName = [route sf_query_valueForParameter:@"dbName"];
    if (dbName.length<=0) {
        return nil;
    }
    NSData *data;
    if ([dbName isEqualToString:@"NSUserDefault"]) {
        NSString *bundleID = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] stringByAppendingString:@".plist"];
        NSString *plist = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Preferences"] stringByAppendingPathComponent:bundleID];
//        NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:plist];
        data =  [NSData dataWithContentsOfFile:plist];
    }else{
        data =  [NSData dataWithContentsOfFile:[SFDebugDBManager sharedManager].dbPath];
    }
    return data;
}
@end
