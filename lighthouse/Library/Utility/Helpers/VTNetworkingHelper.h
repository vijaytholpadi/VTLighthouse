//
//  VTNetworkingHelper.h
//
//  Created by Vijay Tholpadi on 9/29/14.
//  Copyright (c) 2014 TheGeekProjekt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VTNetworkResponse.h"

#import "VTNoInternetView.h"

typedef void (^VTNetworkRequestCompletionHandler) (VTNetworkResponse * response);
//typedef void (^BIError) (NSError *error);

@interface VTNetworkingHelper : NSObject

// Base server URL relative to which all other URLs will be called
@property (nonatomic, strong) NSString *serverURLPath;
@property (nonatomic, strong) NSURL *serverURL;
@property (assign, nonatomic) BOOL showLoadingView;
@property (assign, nonatomic) BOOL isInternetViewVisible;
@property (strong, nonatomic) VTNoInternetView *noInternetView;

// Network operation functions
/*
- For GET requests the performRequestWithPath should be called as there is
 no need to send parameters.
- For POST, PUT and DELETE requests the performRequestWithPath:withParams needs
 to be called with the necessary parameters.
 */
- (void)performRequestWithPath:(NSString *)path withAuth:(BOOL)needsAuth withRequestJSONSerialized:(BOOL)reqJSONSerialized withCompletionHandler:(VTNetworkRequestCompletionHandler)handler;

- (void)performRequestWithPath:(NSString *)path withAuth:(BOOL)needsAuth forMethod:(NSString *)method withRequestJSONSerialized:(BOOL)reqJSONSerialized withParams:(id)params withCompletionHandler:(VTNetworkRequestCompletionHandler)handler;


//Class methods - Shared Instance
+ (VTNetworkingHelper *)sharedInstance;
@end
