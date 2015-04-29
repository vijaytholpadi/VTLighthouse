//
//  LHRangingViewController.m
//  lighthouse
//
//  Created by Vijay Tholpadi on 4/27/15.
//  Copyright (c) 2015 InteractionOne. All rights reserved.
//

#import "LHRangingViewController.h"
#import "LHBeaconDetailViewController.h"

#import "LHDefaults.h"

#import <CoreLocation/CoreLocation.h>

@interface LHRangingViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitch;
@property (weak, nonatomic) IBOutlet UITableView *beaconsTableView;

@property NSMutableDictionary *beacons;
@property CLLocationManager *locationManager;
@property NSMutableDictionary *rangedRegions;
@end


@implementation LHRangingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.beaconsTableView setDelegate:self];
    [self.beaconsTableView setDataSource:self];
    
    UIAlertView *alertView = [[UIAlertView alloc]init];
    
    self.beacons = [[NSMutableDictionary alloc] init];
    
    // This location manager will be used to demonstrate how to range beacons.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Populate the regions we will range once.
    self.rangedRegions = [[NSMutableDictionary alloc] init];
    
    for (NSUUID *uuid in [LHDefaults sharedDefaults].supportedProximityUUIDs)
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
        self.rangedRegions[region] = [NSArray array];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Start ranging when the view appears.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager startRangingBeaconsInRegion:region];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Stop ranging when the view goes away.
    for (CLBeaconRegion *region in self.rangedRegions)
    {
        [self.locationManager stopRangingBeaconsInRegion:region];
    }
}


#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    /*
     CoreLocation will call this delegate method at 1 Hz with updated range information.
     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
     use a set instead of an array.
     */
    self.rangedRegions[region] = beacons;
    [self.beacons removeAllObjects];
    
    NSMutableArray *allBeacons = [NSMutableArray array];
    
    for (NSArray *regionResult in [self.rangedRegions allValues])
    {
        [allBeacons addObjectsFromArray:regionResult];
    }
    
    for (NSNumber *range in @[@(CLProximityUnknown), @(CLProximityImmediate), @(CLProximityNear), @(CLProximityFar)])
    {
        NSArray *proximityBeacons = [allBeacons filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"proximity = %d", [range intValue]]];
        if([proximityBeacons count])
        {
            self.beacons[range] = proximityBeacons;
        }
    }
    
    [self.beaconsTableView reloadData];
    
    if ([self.autoSwitch isOn]) {
        LHBeaconDetailViewController *beaconDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LHBeaconDetailViewController"];
        
        CLBeacon *firstBeacon;
        
        if ([self.beacons count] != 0) {
            
            NSArray *sectionKeys = [self.beacons allKeys];
            
            for (NSNumber *beaconKey in sectionKeys) {
                
                if ([beaconKey integerValue] == CLProximityImmediate) {
                    firstBeacon = self.beacons[beaconKey][0];
                    if (![firstBeacon.proximityUUID isEqual:nil] && ![firstBeacon.major isEqual:nil] && ![firstBeacon.major isEqual:nil]) {
                        beaconDetailVC.beaconUUID = firstBeacon.proximityUUID;
                        beaconDetailVC.beaconMajor = firstBeacon.major;
                        beaconDetailVC.beaconMinor = firstBeacon.minor;
                        [self.navigationController pushViewController:beaconDetailVC animated:YES];
                    }
                }
            }
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.beacons.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionValues = [self.beacons allValues];
    return [sectionValues[section] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    NSArray *sectionKeys = [self.beacons allKeys];
    
    // The table view will display beacons by proximity.
    NSNumber *sectionKey = sectionKeys[section];
    
    switch([sectionKey integerValue])
    {
        case CLProximityImmediate:
            title = NSLocalizedString(@"Immediate", @"Immediate section header title");
            break;
            
        case CLProximityNear:
            title = NSLocalizedString(@"Near", @"Near section header title");
            break;
            
        case CLProximityFar:
            title = NSLocalizedString(@"Far", @"Far section header title");
            break;
            
        default:
            title = NSLocalizedString(@"Unknown", @"Unknown section header title");
            break;
    }
    
    return title;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // Display the UUID, major, minor and accuracy for each beacon.
    NSNumber *sectionKey = [self.beacons allKeys][indexPath.section];
    CLBeacon *beacon = self.beacons[sectionKey][indexPath.row];
    cell.textLabel.text = [beacon.proximityUUID UUIDString];
    
    NSString *formatString = NSLocalizedString(@"Major: %@, Minor: %@, Acc: %.2fm", @"Format string for ranging table cells.");
    cell.detailTextLabel.text = [NSString stringWithFormat:formatString, beacon.major, beacon.minor, beacon.accuracy];
    
    return cell;
}
@end
