//
//  VTNetworkResponse.h
//
//  Created by Vijay Tholpadi on 9/29/14.
//  Copyright (c) 2014 TheGeekProjekt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VTNetworkResponse : NSObject
@property (nonatomic, assign) BOOL isSuccessful;
@property (nonatomic, retain) NSError * error;
@property (nonatomic, retain) id data;

@end
