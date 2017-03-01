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
@implementation SFDebugDBQueryRespone
+ (NSString*)getDBListResponse:(NSArray*)databaseDirectorys{
    NSMutableDictionary *databasePaths = [NSMutableDictionary dictionary];
    for (NSString *directory in databaseDirectorys) {
        NSArray *dirList = [[[NSFileManager defaultManager] subpathsAtPath:directory] pathsMatchingExtensions:@[@"sqlite",@"SQLITE"]];
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
        database = [route sf_url_valueForParameter:@"database"];
    }
    NSString *databasePath = [[[SFDebugDB shared] databases] objectForKey:database];
    
    [[SFDebugDBManager sharedManager] openDatabase:databasePath];;
    NSArray *list = [[SFDebugDBManager sharedManager] getAllTableName:[SFDebugDBManager sharedManager].db];
    NSDictionary *JSON   = @{@"rows":list?:[NSNull null]};

    return [JSON sf_dic_JSONString];
}
+ (NSString*)getAllDataFromTheTableResponse:(NSString*)route {
    
    NSString *tableName = nil;
    
    if ([route rangeOfString:@"?tableName="].location != NSNotFound){
//        tableName = route.substring(route.indexOf("=") + 1, route.length());
        tableName = [route substringWithRange:NSMakeRange([route rangeOfString:@"="].location+1, route.length)];

    }
    
//    NSDictionary *response;
//    
//    if (isDbOpened) {
//        NSString sql = "SELECT * FROM " + tableName;
//        response = [SFDebugDBManager sharedManager] getTableData(mDatabase, sql, tableName);
//    } else {
//        response = PrefHelper.getAllPrefData(mContext, tableName);
//    }
    
    return nil;
    
}
//
//private String executeQueryAndGetResponse(String route) {
//    String query = null;
//    String data = null;
//    String first;
//    try {
//        if (route.contains("?query=")) {
//            query = route.substring(route.indexOf("=") + 1, route.length());
//        }
//        try {
//            query = URLDecoder.decode(query, "UTF-8");
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        
//        if (query != null) {
//            first = query.split(" ")[0].toLowerCase();
//            if (first.equals("select")) {
//                TableDataResponse response = DatabaseHelper.getTableData(mDatabase, query, null);
//                data = mGson.toJson(response);
//            } else {
//                TableDataResponse response = DatabaseHelper.exec(mDatabase, query);
//                data = mGson.toJson(response);
//            }
//        }
//    } catch (Exception e) {
//        e.printStackTrace();
//    }
//    
//    if (data == null) {
//        Response response = new Response();
//        response.isSuccessful = false;
//        data = mGson.toJson(response);
//    }
//    
//    return data;
//}
//

//
//private String updateTableDataAndGetResponse(String route) {
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
//}
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
