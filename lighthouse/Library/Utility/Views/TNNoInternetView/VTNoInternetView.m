//
//  VTNoInternetView.m
//
//  Created by Vijay Tholpadi on 9/29/14.
//  Copyright (c) 2014 TheGeekProjekt. All rights reserved.
//

#import "VTNoInternetView.h"
#import <AFNetworking/AFNetworking.h>

@implementation VTNoInternetView

-(void)awakeFromNib{
    [super awakeFromNib];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.containerView.layer.cornerRadius = 5.0f;
    self.tryAgainButton.layer.cornerRadius = 5.0f;
    
    [self.containerView setClipsToBounds:YES];
    [self.tryAgainButton setClipsToBounds:YES];
}

-(IBAction)tryAgain:(id)sender {
    if ([self connected]) {
        [self removeFromSuperview];
        
        [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    }
}


- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}
@end
