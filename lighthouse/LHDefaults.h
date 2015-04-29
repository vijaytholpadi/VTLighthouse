//
//  LHDefaults.h
//  lighthouse
//
//  Created by Vijay Tholpadi on 4/27/15.
//  Copyright (c) 2015 InteractionOne. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *BeaconIdentifier;

@interface LHDefaults : NSObject

+ (LHDefaults *)sharedDefaults;

@property (nonatomic, copy, readonly) NSArray *supportedProximityUUIDs;

@property (nonatomic, copy, readonly) NSUUID *defaultProximityUUID;
@property (nonatomic, copy, readonly) NSNumber *defaultPower;

@end
