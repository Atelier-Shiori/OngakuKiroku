//
//  SharedHTTPManager.m
//  Hakuchou
//
//  Created by 香風智乃 on 3/6/19.
//  Copyright © 2019 MAL Updater OS X Group. All rights reserved.
//

#import "SharedHTTPManager.h"

@implementation SharedHTTPManager
+ (AFHTTPSessionManager*)jsonmanager {
    static dispatch_once_t jonceToken;
    static AFHTTPSessionManager *jmanager = nil;
    if (jmanager) {
        [jmanager.requestSerializer clearAuthorizationHeader];
        jmanager.requestSerializer = [SharedHTTPManager httprequestserializer];
        jmanager.responseSerializer =  [SharedHTTPManager jsonresponseserializer];
    }
    dispatch_once(&jonceToken, ^{
        jmanager = [AFHTTPSessionManager manager];
        jmanager.requestSerializer = [SharedHTTPManager httprequestserializer];
        jmanager.responseSerializer =  [SharedHTTPManager jsonresponseserializer];
    });
    return jmanager;
}
+ (AFHTTPSessionManager*)httpmanager {
    static dispatch_once_t hmonceToken;
    static AFHTTPSessionManager *hmanager = nil;
    if (hmanager) {
        [hmanager.requestSerializer clearAuthorizationHeader];
        hmanager.requestSerializer = [SharedHTTPManager httprequestserializer];
        hmanager.responseSerializer =  [SharedHTTPManager httpresponseserializer];
    }
    dispatch_once(&hmonceToken, ^{
        hmanager = [AFHTTPSessionManager manager];
        hmanager.requestSerializer = [SharedHTTPManager httprequestserializer];
        hmanager.responseSerializer =  [SharedHTTPManager httpresponseserializer];
    });
    return hmanager;
}
+ (AFHTTPSessionManager*)syncmanager {
    static dispatch_once_t synconceToken;
    static AFHTTPSessionManager *syncmanager = nil;
    if (syncmanager) {
        [syncmanager.requestSerializer clearAuthorizationHeader];
        syncmanager.requestSerializer = [SharedHTTPManager httprequestserializer];
        syncmanager.responseSerializer = [SharedHTTPManager jsonresponseserializer];
    }
    dispatch_once(&synconceToken, ^{
        syncmanager = [AFHTTPSessionManager manager];
        syncmanager.requestSerializer = [SharedHTTPManager httprequestserializer];
        syncmanager.responseSerializer = [SharedHTTPManager jsonresponseserializer];
        syncmanager.completionQueue = dispatch_queue_create("moe.ateliershiori.Shukofukurou", DISPATCH_QUEUE_CONCURRENT);
    });
    return syncmanager;
}
+ (AFJSONRequestSerializer *)jsonrequestserializer {
    static dispatch_once_t jronceToken;
    static AFJSONRequestSerializer *jsonrequest = nil;
    dispatch_once(&jronceToken, ^{
        jsonrequest = [AFJSONRequestSerializer serializer];
    });
    switch ((int)[NSUserDefaults.standardUserDefaults integerForKey:@"currentservice"]) {
        case 2:
            [jsonrequest setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
            break;
        default:
            [jsonrequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
    }
    return jsonrequest;
}
+ (AFHTTPRequestSerializer *)httprequestserializer {
    static dispatch_once_t hronceToken;
    static AFHTTPRequestSerializer *httprequest = nil;
    dispatch_once(&hronceToken, ^{
        httprequest = [AFHTTPRequestSerializer serializer];
    });
    return httprequest;
}
+ (AFJSONResponseSerializer *)jsonresponseserializer {
    static dispatch_once_t jonceToken;
    static AFJSONResponseSerializer *jsonresponse = nil;
    dispatch_once(&jonceToken, ^{
        jsonresponse = [AFJSONResponseSerializer serializer];
        jsonresponse.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"application/vnd.api+json", @"text/javascript", @"text/html", @"text/plain", nil];
    });
    return jsonresponse;
}
+ (AFHTTPResponseSerializer *)httpresponseserializer {
    static dispatch_once_t honceToken;
    static AFHTTPResponseSerializer *httpresponse = nil;
    dispatch_once(&honceToken, ^{
        httpresponse = [AFHTTPResponseSerializer serializer];
    });
    return httpresponse;
}
@end
