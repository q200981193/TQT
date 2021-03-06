//
//  TQTWeiboRequest.m
//  TQT
//
//  Created by lishunnian on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import "SBJsonParser.h"
#import "TQTApiUrl.h"
#import "QWeiboRequest.h"
#import "TQTWeiboRequest.h"
#import "TQTWeiBo.h"
#import "TQTApiUrl.h"
#import "QOauthKey.h"
#import "TQTAppDelegate.h"
@implementation TQTWeiboRequest

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (int)postWeiboText:(NSString *)text
{
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"json" forKey:@"format"];
    [dict setObject:text forKey:@"content"];
    [dict setObject:[self myIP] forKey:@"clientip"];
    [dict setObject:@"1" forKey:@"jing"];
    [dict setObject:@"1" forKey:@"wei"];
    QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    NSString *response = [request syncRequestWithUrl:kAddWeiboUrl
                                          httpMethod:@"POST" 
                                            oauthKey:oauthKey
                                          parameters:dict files:nil];
    if (!response) {
        return -1;
    }
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *retDict = [parser objectWithString:response];
    if (retDict && [[retDict objectForKey:@"ret"] intValue] == 0) {
        return [[retDict objectForKey:@"errcode"] intValue];
    }
    return -1;
}

- (int)postWeiboText:(NSString *)text withPicture:(NSString *)picPath
{
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"json" forKey:@"format"];
    [dict setObject:text forKey:@"content"];
    [dict setObject:[self myIP] forKey:@"clientip"];
    [dict setObject:@"" forKey:@"jing"];
    [dict setObject:@"" forKey:@"wei"];
    NSString *response = nil;
    QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    if (picPath) {
        NSMutableDictionary *picDict = [NSMutableDictionary dictionary];
        [picDict setObject:picPath forKey:@"pic"];
        response = [request syncRequestWithUrl:kAddPicWeiboUrl httpMethod:@"POST" oauthKey:oauthKey parameters:dict files:picDict];
    }
    else
    {
        response = [request syncRequestWithUrl:kAddWeiboUrl
                                    httpMethod:@"POST" 
                                      oauthKey:oauthKey
                                    parameters:dict files:nil];
    }
    if (!response) {
        return -1;
    }
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *retDict = [parser objectWithString:response];
    if (retDict && [[retDict objectForKey:@"ret"] intValue] == 0) {
        return [[retDict objectForKey:@"errcode"] intValue];
    }
    return -1;
}

- (NSMutableArray *)homeTimeLines
{
    return [self homeTimeLinesWithType:0 OfTimeStamp:0];
}

- (NSMutableArray *)homeTimeLinesWithType:(int)type OfTimeStamp:(long)timeStamp
{
    
    QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:[NSString stringWithFormat:@"%d", type] forKey:@"pageflag"];
    [parameters setObject:[NSString stringWithFormat:@"%ld", timeStamp] forKey:@"pagetime"];
    NSString *response = [request syncRequestWithUrl:kHomeTimeLineUrl httpMethod:@"GET" oauthKey:oauthKey parameters:parameters files:nil];
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *dict = [parser objectWithString:response];
    if (dict && [[dict objectForKey:@"msg"] isEqualToString:@"ok"])
    {
        NSArray *dicts = [[dict objectForKey:@"data"] objectForKey:@"info"];
        NSMutableArray *weibos = [NSMutableArray arrayWithCapacity:[dicts count]];
        for (id aDict in dicts)
        {
            [weibos addObject:[TQTWeiBo weiBoFromDict:aDict]];
        }
        return weibos;
    }
    return nil;
}

- (NSMutableArray *)publicTimeLinesWithType:(int)type ofTimeStamp:(long)timeStamp reqNum:(int)number
{
 	QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:[NSString stringWithFormat:@"%ld", timeStamp] forKey:@"pos"];
	[parameters setObject:[NSString stringWithFormat:@"%d", number] forKey:@"reqnum"];
    NSString *response = [request syncRequestWithUrl:kPublicTimeLineUrl httpMethod:@"GET" oauthKey:oauthKey parameters:parameters files:nil];
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *dict = [parser objectWithString:response];
    if (dict && [[dict objectForKey:@"msg"] isEqualToString:@"ok"])
    {
        NSArray *dicts = [[dict objectForKey:@"data"] objectForKey:@"info"];
        NSMutableArray *weibos = [NSMutableArray arrayWithCapacity:[dicts count]];
        for (id aDict in dicts)
        {
            [weibos addObject:[TQTWeiBo weiBoFromDict:aDict]];
        }
        return weibos;
    }   
	return nil;
}

- (int)reAdd:(NSString *)content weiboId:(long long)weiboId
{
    QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:content forKey:@"content"];
    [parameters setObject:[self myIP] forKey:@"clientip"];
    [parameters setObject:[NSString stringWithFormat:@"%lld", weiboId] forKey:@"reid"];
    NSString *response = [request syncRequestWithUrl:kReAddWeiboUrl
                                          httpMethod:@"POST"
                                            oauthKey:oauthKey 
                                          parameters:parameters
                                               files:nil];
    if (!response) {
        return -1;
    }
    
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *retDict = [parser objectWithString:response];
    if (retDict && [[retDict objectForKey:@"ret"] intValue] == 0) {
        return [[retDict objectForKey:@"errcode"] intValue];
    }
    return -1;
}

- (int)reply:(NSString *)content weiboId:(long long)weiboId
{
    QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:content forKey:@"content"];
    [parameters setObject:[self myIP] forKey:@"clientip"];
    [parameters setObject:[NSString stringWithFormat:@"%lld", weiboId] forKey:@"reid"];
    NSString *response = [request syncRequestWithUrl:kReplyWeiboUrl
                                          httpMethod:@"POST"
                                            oauthKey:oauthKey 
                                          parameters:parameters
                                               files:nil];
    if (!response) {
        return -1;
    }
    
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *retDict = [parser objectWithString:response];
    if (retDict && [[retDict objectForKey:@"ret"] intValue] == 0) {
        return [[retDict objectForKey:@"errcode"] intValue];
    }
    return -1;
}

- (int)comment:(NSString *)content weiboId:(long long)weiboId
{
    QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:content forKey:@"content"];
    [parameters setObject:[self myIP] forKey:@"clientip"];
    [parameters setObject:[NSString stringWithFormat:@"%lld", weiboId] forKey:@"reid"];
    NSString *response = [request syncRequestWithUrl:kCommentWeiboUrl
                                          httpMethod:@"POST"
                                            oauthKey:oauthKey 
                                          parameters:parameters
                                               files:nil];
    if (!response) {
        return -1;
    }
    
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *retDict = [parser objectWithString:response];
    if (retDict && [[retDict objectForKey:@"ret"] intValue] == 0) {
        return [[retDict objectForKey:@"errcode"] intValue];
    }
    return -1; 
}

- (NSMutableArray *)replyListOfWeiboId:(long long) weiboId 
                                  type:(int)flag
                              pageFlag:(int)pageFlag
                              pageTime:(long)pageTime
                                reqNum:(int)reqNum 
                                   tId:(long long)tId
{
    QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:[NSString stringWithFormat:@"%lld", weiboId] forKey:@"rootid"];
    [parameters setObject:[NSString stringWithFormat:@"%d", flag] forKey:@"flag"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageFlag] forKey:@"pageflag"];
    [parameters setObject:[NSString stringWithFormat:@"%ld", pageTime] forKey:@"pagetime"];
    [parameters setObject:[NSString stringWithFormat:@"%d", reqNum] forKey:@"reqnum"];
    [parameters setObject:[NSString stringWithFormat:@"%lld", tId] forKey:@"twitterid"];
    NSString *response = [request syncRequestWithUrl:kReListUrl 
                                          httpMethod:@"GET" 
                                            oauthKey:oauthKey 
                                          parameters:parameters 
                                               files:nil];
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *dict = [parser objectWithString:response];
    if (dict && [[dict objectForKey:@"msg"] isEqualToString:@"ok"])
    {
        NSArray *dicts = [[dict objectForKey:@"data"] objectForKey:@"info"];
        NSMutableArray *weibos = [NSMutableArray arrayWithCapacity:[dicts count]];
        for (id aDict in dicts)
        {
            [weibos addObject:[TQTWeiBo weiBoFromDict:aDict]];
        }
        return weibos;
    }   
	return nil;
}



- (NSMutableArray *)publicTimeLines
{
	return [self publicTimeLinesWithType:0 ofTimeStamp:0 reqNum:20];
}

- (NSMutableArray *)userTimeLinesOfName:(NSString *)userName 
                               pageFlag:(int)pageFlag
                               pageTime:(long)pageTime
                                 reqNum:(int)reqNum 
                                 lastId:(long long)lastId
                               pullType:(int)pullType 
                            contentType:(int)contentType
                            accessLevel:(int)level
{
    QOauthKey *oauthKey = [(TQTAppDelegate *)[[NSApplication sharedApplication] delegate] oauthKey];
    QWeiboRequest *request = [[[QWeiboRequest alloc] init] autorelease];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"json" forKey:@"format"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageFlag] forKey:@"pageflag"];
    [parameters setObject:[NSString stringWithFormat:@"%ld", pageTime] forKey:@"pagetime"];
    [parameters setObject:[NSString stringWithFormat:@"%d", reqNum] forKey:@"reqnum"];
    [parameters setObject:[NSString stringWithFormat:@"%lld", lastId] forKey:@"lastid"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pullType] forKey:@"type"];
    [parameters setObject:userName forKey:@"name"];
    [parameters setObject:[NSString stringWithFormat:@"%d", contentType] forKey:@"contenttype"];
    [parameters setObject:[NSString stringWithFormat:@"%d", level] forKey:@"accesslevel"];
    NSString *response = [request syncRequestWithUrl:kUserTimeLineUrl 
                                          httpMethod:@"POST" 
                                            oauthKey:oauthKey 
                                          parameters:parameters 
                                               files:nil];
    SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
    NSMutableDictionary *dict = [parser objectWithString:response];
    if (dict && [[dict objectForKey:@"msg"] isEqualToString:@"ok"])
    {
        NSArray *dicts = [[dict objectForKey:@"data"] objectForKey:@"info"];
        NSMutableArray *weibos = [NSMutableArray arrayWithCapacity:[dicts count]];
        for (id aDict in dicts)
        {
            [weibos addObject:[TQTWeiBo weiBoFromDict:aDict]];
        }
        return weibos;
    }   
	return nil;
}

- (NSString *)myIP
{
    NSString *result = @"127.0.0.1";
    NSHost *currentHost = [NSHost currentHost];
    NSString *ad = [currentHost address];
    if (ad)
        return ad;
    return result;
}
@end
