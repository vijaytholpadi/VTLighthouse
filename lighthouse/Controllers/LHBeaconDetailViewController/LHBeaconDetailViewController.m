//
//  LHBeaconDetailViewController.m
//  lighthouse
//
//  Created by Vijay Tholpadi on 4/27/15.
//  Copyright (c) 2015 InteractionOne. All rights reserved.
//

#import "LHBeaconDetailViewController.h"

#import "VTNetworkingHelper.h"

@interface LHBeaconDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *beaconImageView;
@property (weak, nonatomic) IBOutlet UITextView *beaconTextView;
@end

@implementation LHBeaconDetailViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
//    VTNetworkingHelper *helper = [[VTNetworkingHelper alloc] init];
    [[VTNetworkingHelper sharedInstance] performRequestWithPath:@"http://192.168.1.9:3002/beacons/123456789\?proximity\=1" withAuth:NO forMethod:@"GET" withRequestJSONSerialized:YES withParams:nil withCompletionHandler:^(VTNetworkResponse *response) {
        if (response.isSuccessful) {
            NSString *message = [[response.data objectForKey:@"message"] objectForKey:@"message"];
            [self.beaconTextView setText:[NSString stringWithFormat:@"%@ %@ %@ %@", [self.beaconUUID UUIDString], self.beaconMajor, self.beaconMinor, message]];
            [self.beaconTextView sizeToFit];
        } else {
        
        }
    }];
    
}
@end
