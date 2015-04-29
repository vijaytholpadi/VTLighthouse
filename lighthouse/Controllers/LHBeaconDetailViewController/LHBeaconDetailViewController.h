//
//  LHBeaconDetailViewController.h
//  lighthouse
//
//  Created by Vijay Tholpadi on 4/27/15.
//  Copyright (c) 2015 InteractionOne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHBeaconDetailViewController : UIViewController

@property (nonatomic, strong)NSUUID *beaconUUID;
@property (nonatomic, strong)NSNumber *beaconMajor;
@property (nonatomic, strong)NSNumber *beaconMinor;

@end
