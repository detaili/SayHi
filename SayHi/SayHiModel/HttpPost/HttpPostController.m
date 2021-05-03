//
//  HttpPostController.m
//  SayHiClientTest
//
//  Created by weidongcao on 2020/8/21.
//  Copyright © 2020 weidongcao. All rights reserved.
//

#import "HttpPostController.h"

static NSString *boundary=@"MacPostRequest";

@implementation HttpPostController

-(NSString *)uploadTo:(NSString *)serverUrl
             withFile:(NSString *)filePath
              timeout:(NSTimeInterval )to
                error:(NSError *__strong*)err{
    NSLog(@"upload file start...");
    *err = NULL;
    //用post上传文件
    //url
    NSURL *url=[NSURL URLWithString:serverUrl];
    //post请求
    NSString *fileName = [filePath lastPathComponent];
    NSLog(@"file name:%@",fileName);
    NSMutableURLRequest *request=[self requestWithURL:url andFilenName:fileName andLocalFilePath:filePath timeout:to];
    NSString *responseStr = [self executeQuery:request error:err];
    NSLog(@"upload file finish");
    return responseStr;
}

-(NSString *)sendMessageTo:(NSString *)serverUrl
                   message:(NSString *)msg
                   timeout:(NSTimeInterval )to
                     error:(NSError *__strong*)err{
    NSLog(@"send msg start...");
    *err = NULL;
    //用post上传文件
    //url
    NSURL *url=[NSURL URLWithString:serverUrl];
    //post请求
    NSMutableURLRequest *request=[self requestWithURL:url withMsg:msg timeout:to];
    NSString *responseStr = [self executeQuery:request error:err];
    NSLog(@"send msg finish");
    return responseStr;
}

-(NSString *)executeQuery:(NSURLRequest *)request error:(NSError *__strong*)err{
    NSLog(@"task start");
    *err = NULL;
    //创建信号量,实现同步请求
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString static *responseStr = @"";
    //连接(NSURLSession)
    NSURLSession *session=[NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (data) {
            //id result=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"post = %@ text = %@",response.URL,responseStr);

        }else{
            NSLog(@"query failure!");
            *err = error;
        }
        //发送
        dispatch_semaphore_signal(semaphore);
    }];
    
    [dataTask resume];
    //等待(阻塞线程)
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"task finish");
    return responseStr;
}

-(NSMutableURLRequest *)requestWithURL:(NSURL *)url andFilenName:(NSString *)fileName andLocalFilePath:(NSString *)localFilePath timeout:(NSTimeInterval )to{

    //post请求
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    request.HTTPMethod=@"POST";//设置请求方法是POST
    request.timeoutInterval=to;//设置请求超时
    
    //拼接请求体数据(1-6步)
    NSMutableData *requestMutableData=[NSMutableData data];
    /*--------------------------------------------------------------------------*/
    //1.\r\n--Boundary+72D4CD655314C423\r\n   // 分割符，以“--”开头，后面的字随便写，只要不写中文即可
    NSMutableString *myString=[NSMutableString stringWithFormat:@"\r\n--%@\r\n",boundary];
    
    //2. Content-Disposition: form-data; name="uploadFile"; filename="001.png"\r\n  // 这里注明服务器接收图片的参数（类似于接收用户名的userName）及服务器上保存图片的文件名
    [myString appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"; serviceUUID=\"%@\"\r\n",fileName,self.SERV_UUID]];

    //3. Content-Type:image/png \r\n  // 图片类型为png
    [myString appendString:[NSString stringWithFormat:@"Content-Type:%@\r\n",@"text/plain"]];
    
    //4. Content-Transfer-Encoding: binary\r\n\r\n  // 编码方式
    [myString appendString:@"Content-Transfer-Encoding: utf-8\r\n\r\n"];
    
    //转换成为二进制数据
    [requestMutableData appendData:[myString dataUsingEncoding:NSUTF8StringEncoding]];

    //5.文件数据部分
    NSData *fileData = [[NSData alloc] initWithContentsOfFile:localFilePath];
    NSLog(@"file data:%@",fileData);
    //转换成为二进制数据
    [requestMutableData appendData:fileData];
    
    //6. \r\n--Boundary+72D4CD655314C423--\r\n  // 分隔符后面以"--"结尾，表明结束
    [requestMutableData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    /*--------------------------------------------------------------------------*/
    //设置请求体
    request.HTTPBody=requestMutableData;
    
    //设置请求头
    NSString *headStr=[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:headStr forHTTPHeaderField:@"Content-Type"];

    return request;
}
-(NSMutableURLRequest *)requestWithURL:(NSURL *)url withMsg:(NSString *)msg timeout:(NSTimeInterval )to{
    
    //post请求
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:2.0f];
    request.HTTPMethod=@"POST";//设置请求方法是POST
    request.timeoutInterval=to;//设置请求超时
    
    //拼接请求体数据
    NSString *bodyStr = [NSString stringWithFormat:@"{\"content\":\"%@\",\"serviceUUID\":\"%@\"}",msg,self.SERV_UUID];

    //设置请求体
    request.HTTPBody=[bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    //设置请求头
    NSString *headStr=[NSString stringWithFormat:@"application/json;charset=utf-8; boundary=%@",boundary];
    [request setValue:headStr forHTTPHeaderField:@"Content-Type"];

    return request;
}
@end
