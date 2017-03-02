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
#import "SFDebugDB.h"

#import "SFDebugDBModel.h"
@implementation SFDebugDBQueryRespone
+ (NSString*)getDBListResponse:(NSArray*)databaseDirectorys{
    NSMutableDictionary *databasePaths = [NSMutableDictionary dictionary];
    for (NSString *directory in databaseDirectorys) {
        NSArray *dirList = [[[NSFileManager defaultManager] subpathsAtPath:directory] pathsMatchingExtensions:@[@"sqlite",@"SQLITE",@"db",@"DB"]];
        for (int i=0;i<[dirList count];i++) {
            NSString *suffix = [dirList[i] lastPathComponent];
            [databasePaths setObject:[directory stringByAppendingPathComponent:suffix] forKey:suffix];
        }
    }
    
    NSDictionary *JSON   = @{@"rows":[databasePaths allKeys]?:[NSNull null]};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JSON
                                                       options:NSJSONWritingPrettyPrinted  error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}
+ (NSString*)getTableListResponse:(NSString*)route{
    NSString *database = nil;
    if ([route rangeOfString:@"?database="].location != NSNotFound){
        database = [[route substringFromIndex:[route rangeOfString:@"?"].location+1] sf_url_valueForParameter:@"database"];
    }
    NSString *databasePath = [[[SFDebugDB shared] databases] objectForKey:database];
    
    [[SFDebugDBManager sharedManager] openDatabase:databasePath];;
    NSArray *list = [[SFDebugDBManager sharedManager] allTables];
    NSDictionary *JSON   = @{@"rows":list?:[NSNull null]};

    return [JSON sf_dic_JSONString];
}

+ (NSString*)getAllDataFromTheTableResponse:(NSString*)route {
    if ([SFDebugDBManager sharedManager].db == NULL) {
        NSDictionary *respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"请重新选择数据库"};
        return [respone sf_dic_JSONString];
    }
    NSString *tableName = nil;
    
    if ([route rangeOfString:@"?tableName="].location != NSNotFound){
        tableName = [route sf_query_valueForParameter:@"tableName"];

    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
    return  [self getTableData:sql table:tableName];
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
+ (NSString*)getTableData:(NSString *)sql table:(NSString*)tableName{
    if ([SFDebugDBManager sharedManager].db == NULL) {
        NSDictionary *respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"请重新选择数据库"};
        return [respone sf_dic_JSONString];
    }
    if (tableName == nil) {
        tableName = [self getTableNameFromQuery:sql];
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
    return [tableData sf_dic_JSONString];
}
//
+ (NSString*)executeQueryAndGetResponse:(NSString*)route {
    if ([SFDebugDBManager sharedManager].db == NULL) {
        NSDictionary *respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"请重新选择数据库"};
        return [respone sf_dic_JSONString];
    }
    
    NSString *query;
    NSString *data;
    NSString *first;
    
    if ([route rangeOfString:@"?query="].location != NSNotFound){
        query = [route sf_query_valueForParameter:@"query"];
    }
    
    
    if (query.length != 0) {
        first = [[[query componentsSeparatedByString:@" "] firstObject] lowercaseString];
        if ([first isEqualToString:@"select"]) {
            NSString *respone =  [self getTableData:query table:nil];
            data = respone;
        } else {
            BOOL result =  [[SFDebugDBManager sharedManager] executeUpdate:query];
            NSDictionary *respone;
            if (result) {
                respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(true)};
            }else{
                respone = @{@"isSelectQuery":@(true),@"isSuccessful":@(false),@"errorMessage":@"数据库操作失败"};
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
//    Uri uri = Uri.parse(URLDecoder.decode(route, "UTF-8"));
//    String tableName = uri.getQueryParameter("tableName");
    
    NSString *tableName = [route sf_query_valueForParameter:@"tableName"];
    NSString *updatedData = [route sf_query_valueForParameter:@"updatedData"];

//    id item =   [updatedData sf_dictionaryValue];
    
//    List<RowDataRequest> rowDataRequests = mGson.fromJson(updatedData, new TypeToken<List<RowDataRequest>>() {
//    }.getType());
//    if (Constants.APP_SHARED_PREFERENCES.equals(mSelectedDatabase)) {
//        response = PrefHelper.updateRow(mContext, tableName, rowDataRequests);
//    } else {
//        response = DatabaseHelper.updateRow(mDatabase, tableName, rowDataRequests);
//    }
    
    
    return nil;
    
    
//    UpdateRowResponse response;
//    try {
//        Uri uri = Uri.parse(URLDecoder.decode(route, "UTF-8"));
//        String tableName = uri.getQueryParameter("tableName");
//        String updatedData = uri.getQueryParameter("updatedData");
//        List<RowDataRequest> rowDataRequests = mGson.fromJson(updatedData, new TypeToken<List<RowDataRequest>>() {
//        }.getType());
//        if (Constants.APP_SHARED_PREFERENCES.equals(mSelectedDatabase)) {
//            response = PrefHelper.updateRow(mContext, tableName, rowDataRequests);
//        } else {
//            response = DatabaseHelper.updateRow(mDatabase, tableName, rowDataRequests);
//        }
//        return mGson.toJson(response);
//    } catch (Exception e) {
//        e.printStackTrace();
//        response = new UpdateRowResponse();
//        response.isSuccessful = false;
//        return mGson.toJson(response);
//    }
}
//
//
//private String deleteTableDataAndGetResponse(String route) {
//    UpdateRowResponse response;
//    try {
//        Uri uri = Uri.parse(URLDecoder.decode(route, "UTF-8"));
//        String tableName = uri.getQueryParameter("tableName");
//        String updatedData = uri.getQueryParameter("deleteData");
//        List<RowDataRequest> rowDataRequests = mGson.fromJson(updatedData, new TypeToken<List<RowDataRequest>>() {
//        }.getType());
//        if (Constants.APP_SHARED_PREFERENCES.equals(mSelectedDatabase)) {
//            response = PrefHelper.deleteRow(mContext, tableName, rowDataRequests);
//        } else {
//            response = DatabaseHelper.deleteRow(mDatabase, tableName, rowDataRequests);
//        }
//        return mGson.toJson(response);
//    } catch (Exception e) {
//        e.printStackTrace();
//        response = new UpdateRowResponse();
//        response.isSuccessful = false;
//        return mGson.toJson(response);
//    }
//}
@end
