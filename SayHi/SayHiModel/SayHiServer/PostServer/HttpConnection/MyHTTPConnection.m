
#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

#import "MessageCenterManager.h"
#import "JsonParser.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_VERBOSE; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation MyHTTPConnection
{
    NSString *_currentCmd;
    MessageCenterManager *_msgCenterManager;
}
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
    _currentCmd = path;
    _msgCenterManager = [MessageCenterManager sharedInstance];
    NSLog(@"method:%@ path:%@",method,path);
    //return YES;
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/upload"])
		{
			return YES;
		}
        else if([path isEqualToString:@"/message"])
        {
            return YES;
        }
        //return YES;
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSLog(@"content type:%@",contentType);
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }

		// enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
    else if([method isEqualToString:@"POST"] && [path isEqualToString:@"/message"]){
        NSLog(@"request post message...");
        //NSLog(@"request body:%@",[[NSString alloc] initWithData:request.body encoding:NSUTF8StringEncoding]);
        return YES;
    }
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"])
	{

//		// this method will generate response with links to uploaded file
//		NSMutableString* filesStr = [[NSMutableString alloc] init];
//
//		for( NSString* filePath in uploadedFiles ) {
//			//generate links
//			[filesStr appendFormat:@"<a href=\"%@\"> %@ </a><br/>",filePath, [filePath lastPathComponent]];
//		}
//		NSString* templatePath = [[config documentRoot] stringByAppendingPathComponent:@"upload.html"];
//		NSDictionary* replacementDict = [NSDictionary dictionaryWithObject:filesStr forKey:@"MyFiles"];
//		// use dynamic file response to apply our links to response template
//		return [[HTTPDynamicFileResponse alloc] initWithFilePath:templatePath forConnection:self separator:@"%" replacementDictionary:replacementDict];
        NSLog(@"upload files:%@",uploadedFiles);
        if ([uploadedFiles count]>0) {
            [_msgCenterManager pushMessage:@{@"type":@"upload",@"file":uploadedFiles[1],@"serviceUUID":uploadedFiles[0]}];
        }
        
        NSData *response = [@"SUCCESS" dataUsingEncoding:NSUTF8StringEncoding];
        return [[HTTPDataResponse alloc] initWithData:response];
        
	}
	else if( [method isEqualToString:@"GET"] && [path hasPrefix:@"/upload/"] ) {
		// let download the uploaded files
		return [[HTTPFileResponse alloc] initWithFilePath: [[config documentRoot] stringByAppendingString:path] forConnection:self];
	}
    else if([method isEqualToString:@"POST"] && [path isEqualToString:@"/message"]){
        NSData *response = [@"SUCCESS" dataUsingEncoding:NSUTF8StringEncoding];
        return [[HTTPDataResponse alloc] initWithData:response];
    }
	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
    if ([_currentCmd isEqualToString:@"/upload"]) {
        NSLog(@"content length:%lld",contentLength);
        // set up mime parser
        NSString* boundary = [request headerField:@"boundary"];
        NSLog(@"boundary:%@",boundary);
        parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
        parser.delegate = self;

        uploadedFiles = [[NSMutableArray alloc] init];
    }
    
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    if ([_currentCmd isEqualToString:@"/upload"]) {
        [parser appendData:postDataChunk];
    }else{
        NSString *postDataStr = [[NSString alloc] initWithData:postDataChunk encoding:NSUTF8StringEncoding];
        NSLog(@"post data chunk:%@",postDataStr);
        NSDictionary *msgTempDict = [JsonParser parseJSonStr:postDataStr];
        NSMutableDictionary *msgDict = [[NSMutableDictionary alloc] initWithDictionary:msgTempDict];
        [msgDict setObject:@"message" forKey:@"type"];
        [_msgCenterManager pushMessage:msgDict];
    }
    
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate


- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
	// in this sample, we are not interested in parts, other then file parts.
	// check content disposition to find out filename

    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
	NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    NSLog(@"file name:%@",filename);
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
		// an empty form sent. we won't handle it.
		return;
	}
    NSString *serviceUUID = [disposition.params objectForKey:@"serviceUUID"];
    NSLog(@"[HttpConnection]service UUID:%@",serviceUUID);
    [uploadedFiles addObject:serviceUUID];
	//NSString* uploadDirPath = [[config documentRoot] stringByAppendingPathComponent:@"upload"];
    //NSString* uploadDirPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"StoreFolder"];
    NSString *uploadDirPath = [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) lastObject];
    
    //NSString* uploadDirPath = @"/vault/TestWinFolder";
    NSLog(@"upload path:%@",uploadDirPath);
    
	BOOL isDir = YES;
	if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
		[[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        //storeFile = nil;
        filePath = [uploadDirPath stringByAppendingFormat:@"/%@-%@",[NSUUID UUID],filename];
    }
    else {
		
    }
    
    HTTPLogVerbose(@"Saving file to %@", filePath);
    if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
        HTTPLogError(@"Could not create directory at path: %@", filePath);
    }
    if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
        HTTPLogError(@"Could not create file at path: %@", filePath);
    }
    storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [uploadedFiles addObject:filename];
}


- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header 
{
	// here we just write the output from parser to the file.
	if( storeFile ) {
		[storeFile writeData:data];
	}
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
	// as the file part is over, we close the file.
	[storeFile closeFile];
	storeFile = nil;
}

- (void) processPreambleData:(NSData*) data 
{
    // if we are interested in preamble data, we could process it here.

}

- (void) processEpilogueData:(NSData*) data 
{
    // if we are interested in epilogue data, we could process it here.

}

@end
