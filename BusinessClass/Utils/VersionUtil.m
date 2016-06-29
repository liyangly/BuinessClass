//
//  VersionUtil.m
//  BusinessClass
//
//  Created by 李阳 on 16/6/29.
//  Copyright © 2016年 liyang. All rights reserved.
//

#import "VersionUtil.h"
#import "AFHTTPRequestOperationManager.h"

@implementation VersionUtil

+ (void)findVersionwithurl:(NSString *)url success:(void (^)(NSDictionary *dict))success {
    //通过URL返回到的是一个文件，通过解析文档内容来获取相关数据
    //注意AFHTTPRequestOperationManager在AFN2.6.3后就去掉了，所以注意AFN的版本
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/javascript", @"application/json",@"text/plain",@"text/json",nil];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [manager GET:url parameters:nil success: ^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary *dictResult = responseObject;
        //更新升级应用程序
        NSString * version=[dictResult objectForKey:@"appVersion"];
        NSString *appCurVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        
        float appCurVersion2 = [[appCurVersion stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue];
        
        float appNewVersion2 = [[version stringByReplacingOccurrencesOfString:@"." withString:@""] floatValue];
        
        if (appNewVersion2 >appCurVersion2) {
            
            
            NSString * appUrl = [dictResult objectForKey:@"appUrl"];
            NSString * alertTitle = @"版本更新";
            NSString * appInfo=[dictResult objectForKey:@"appInfo"];
            NSString * alertInfo=[NSString stringWithFormat:@"当前最新版本：%@ \n 更新内容：%@",version,appInfo];
            
            NSString * appImportant=[dictResult valueForKeyPath:@"appImportant"];
            
            if([appImportant isEqualToString:@"1"]){
                alertTitle = @"版本重要更新，必须升级才能操作！";
            }
            
            NSDictionary * dict = @{@"appUrl":appUrl,@"alertTitle":alertTitle,@"alertInfo":alertInfo};
            success(dict);
        }
        
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error){
        
        //        success(nil);
    }];
    
}

@end
