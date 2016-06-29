//
//  WebServiceUtil.m
//  BusinessClass
//
//  Created by 李阳 on 16/6/29.
//  Copyright © 2016年 liyang. All rights reserved.
//

#import "WebServiceUtil.h"
#import "AFHTTPRequestOperationManager.h"
#import "BusinessClassAPI.h"

@implementation WebServiceUtil

+ (void) getHttpRequestWithMethodName:(NSString *)MethodName params:(NSString *)params success:(void (^)(NSDictionary *dict))success failure:(void (^)(NSDictionary *dict))failure {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 30;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    NSLog(@"MethodName====%@ 传入参数========%@",MethodName,params);
    params = [params stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/%@",Head_Url,MethodName,params];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/javascript", @"application/json",@"text/plain",nil];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSDictionary *  dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"返回参数:%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        success(dict);
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        NSLog(@"信息发送失败\n %@",error);
        NSDictionary *dict;
        if (error.code == NSURLErrorNotConnectedToInternet) {
            dict = @{@"info":@"无法链接到网络"};
        } else  {
            dict = @{@"info":My_HttpServicefailure};
        }
    }];
}

+ (void)getDataFromSoapWithMethodName:(NSString *)methodName params:(NSString *)parameter success:(void (^)(NSDictionary *dict))success failure:(void (^)(NSDictionary *dict))failed{
    
    NSArray *methodNameArray = [methodName componentsSeparatedByString:@"/"];
    NSString *soapMessage = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                             "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                             "<soap:Body>\n"
                             "<ns1:%@ xmlns:ns1=\"%@\">\n"
                             "<arg0>%@</arg0>\n"
                             "<arg1>%@</arg1>\n"
                             "</ns1:%@>\n"
                             "</soap:Body>\n"
                             "</soap:Envelope>\n", methodNameArray[0], My_NameSpace, methodNameArray[1] ,parameter ,methodNameArray[0]];
    NSURL *url = [NSURL URLWithString:MyWSDL_prefix];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request ];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:@"(?<=return\\>).*(?=</return)" options:NSRegularExpressionCaseInsensitive error:nil];
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        result = [result stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        //        NSLog(@"%@",result);
        NSDictionary *dict = [NSDictionary dictionary];
        for (NSTextCheckingResult *checkingResult in [regular matchesInString:result options:0 range:NSMakeRange(0, result.length)]) {
            
            // 得到字典
            dict = [NSJSONSerialization JSONObjectWithData:[[result substringWithRange:checkingResult.range] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            
        }
        // 请求成功并且结果有值把结果传出去
        success(dict);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        NSLog(@"%@",error);
        NSDictionary *dict;
        if (error.code == NSURLErrorNotConnectedToInternet) {
            dict = @{@"info":@"无法链接到网络"};
        } else  {
            dict = @{@"info":My_HttpServicefailure};
        }
        failed(dict);
    }];
    [operation start];
}

@end
