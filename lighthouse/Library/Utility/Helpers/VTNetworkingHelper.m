//
//  VTNetworkingHelper.m
//
//  Created by Vijay Tholpadi on 9/29/14.
//  Copyright (c) 2014 TheGeekProjekt. All rights reserved.
//

#import "VTNetworkingHelper.h"
#import <AFNetworking.h>
#import "AppDelegate.h"

@implementation VTNetworkingHelper

-(id)init{
    
    if (self = [super init])
    {
        self.showLoadingView = YES;
    }
    return self;
}


+ (VTNetworkingHelper *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


- (void)performRequestWithPath:(NSString *)path withAuth:(BOOL)needsAuth withRequestJSONSerialized:(BOOL)reqJSONSerialized withCompletionHandler:(VTNetworkRequestCompletionHandler) handler {
    
    [self performRequestWithPath:path withAuth:needsAuth forMethod:@"GET" withRequestJSONSerialized:reqJSONSerialized withParams:nil withCompletionHandler:handler];
}


- (void)performRequestWithPath:(NSString *)path withAuth:(BOOL)needsAuth forMethod:(NSString *)method withRequestJSONSerialized:(BOOL)reqJSONSerialized withParams:(id)params withCompletionHandler:(VTNetworkRequestCompletionHandler) handler {
    
    self.isInternetViewVisible = NO;
    
    //Reachability detection
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                [self LoadNoInternetView:NO];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                [self LoadNoInternetView:NO];
                break;
            }
            case AFNetworkReachabilityStatusNotReachable: {
                break;
            }
            default: {
                break;
            }
        }
    }];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if(reqJSONSerialized == NO){
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        //        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    } else {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"very_secret_token" forHTTPHeaderField:@"x-access-token"];
    }
    
    if (needsAuth){
        [manager.requestSerializer clearAuthorizationHeader];
        //        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"#Username" password:@"#Password"];
    }
    
    manager.responseSerializer =[AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
    //Depending on the method type we proceed to the corresponding execution
    if([method isEqualToString:@"POST"]) {
        [manager POST:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if(handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
            
            if (self.showLoadingView)
                //            NSLog(@"%@:%@", path, responseObject);
                
                return ;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if(handler) {
                handler([self prepareResponseObject:FALSE withData:nil andError:error]);
            }
            
            if (error.code == -1009) {
                
                [self LoadNoInternetView:YES];
            }
        }];
        
    } else if ([method isEqualToString:@"GET"]) {
        [manager GET:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
            //            NSLog(@"%@:%@", path, responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(handler) {
                handler([self prepareResponseObject:TRUE withData:nil andError:error]);
            }
            //            NSLog(@"%@:%@", path, error);
        }];
        
    } else if ([method isEqualToString:@"PUT"]) {
        [manager PUT:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
            //            NSLog(@"%@:%@", path, responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(handler) {
                handler([self prepareResponseObject:TRUE withData:nil andError:error]);
            }
            //            NSLog(@"%@:%@", path, error);
        }];
        
    } else if ([method isEqualToString:@"DELETE"]) {
        [manager DELETE:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (handler) {
                handler([self prepareResponseObject:TRUE withData:responseObject andError:nil]);
            }
            //            NSLog(@"%@:%@", path, responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if(handler) {
                handler([self prepareResponseObject:TRUE withData:nil andError:error]);
            }
            //            NSLog(@"%@:%@", path, error);
        }];
    }
}


#pragma mark - Helper functions
- (VTNetworkResponse *)prepareResponseObject:(BOOL) success
                                    withData:(id)response
                                    andError: (NSError *)error{
    VTNetworkResponse *responseDetails = [[VTNetworkResponse alloc] init];
    responseDetails.isSuccessful = success;
    responseDetails.data = response;
    responseDetails.error = error;
    return responseDetails;
}


-(void)LoadNoInternetView:(BOOL)Show {
    
    if ([[[UIApplication sharedApplication] keyWindow].subviews containsObject: self.noInternetView] == Show) {
        return;
        
    }
    
    if (Show) {
        
        if (!self.noInternetView) {
            
            self.isInternetViewVisible = YES;
            UINib *nib = [UINib nibWithNibName:@"TNNoInternetView" bundle:nil];
            self.noInternetView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
            
            self.noInternetView.frame = [[UIApplication sharedApplication] keyWindow].frame;
            
            self.noInternetView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        }
        
        BOOL addinternetView = YES;
        
        AppDelegate *myAppDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        for(UIView *view in myAppDelegate.window.subviews)
        {
            if([view isKindOfClass:[VTNoInternetView class]])
            {
                addinternetView = NO;
            }
        }
        
        if (addinternetView) {
            [[[UIApplication sharedApplication] keyWindow] addSubview: self.noInternetView];
        }
    } else {
        self.isInternetViewVisible = NO;
        
        [self.noInternetView removeFromSuperview];
    }
}


- (void)dealloc {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}


@end

