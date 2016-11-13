//
//  LHBeaconMonitoringViewController.m
//  lighthouse
//
//  Created by Vijay Tholpadi on 4/29/15.
//  Copyright (c) 2015 InteractionOne. All rights reserved.
//

#import "LHBeaconMonitoringViewController.h"
#import "LHDefaults.h"

@import CoreLocation;

@interface LHBeaconMonitoringViewController () <CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UISwitch *enabledSwitch;

@property (nonatomic, weak) IBOutlet UITextField *uuidTextField;

@property (nonatomic, weak) IBOutlet UITextField *majorTextField;
@property (nonatomic, weak) IBOutlet UITextField *minorTextField;

@property (nonatomic, weak) IBOutlet UISwitch *notifyOnEntrySwitch;
@property (nonatomic, weak) IBOutlet UISwitch *notifyOnExitSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *notifyOnDisplaySwitch;

@property BOOL enabled;
@property NSUUID *uuid;
@property NSNumber *major;
@property NSNumber *minor;
@property BOOL notifyOnEntry;
@property BOOL notifyOnExit;
@property BOOL notifyOnDisplay;

@property UIBarButtonItem *doneButton;

@property (nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) CLLocationManager *locationManager;

- (void)updateMonitoredRegion;

@end

@implementation LHBeaconMonitoringViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:BeaconIdentifier];
    region = [self.locationManager.monitoredRegions member:region];
    
    if(region)
    {
        self.enabled = YES;
        self.uuid = region.proximityUUID;
        self.major = region.major;
        self.majorTextField.text = [self.major stringValue];
        self.minor = region.minor;
        self.minorTextField.text = [self.minor stringValue];
        self.notifyOnEntry = region.notifyOnEntry;
        self.notifyOnExit = region.notifyOnExit;
        self.notifyOnDisplay = region.notifyEntryStateOnDisplay;
    }
    else
    {
        // Default settings.
        self.enabled = NO;
        
        self.uuid = [LHDefaults sharedDefaults].defaultProximityUUID;
        self.major = self.minor = nil;
        self.notifyOnEntry = self.notifyOnExit = YES;
        self.notifyOnDisplay = NO;
    }
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.uuidTextField.text = [self.uuid UUIDString];
    
    self.enabledSwitch.on = self.enabled;
    self.notifyOnEntrySwitch.on = self.notifyOnEntry;
    self.notifyOnExitSwitch.on = self.notifyOnExit;
    self.notifyOnDisplaySwitch.on = self.notifyOnDisplay;
}

#pragma mark - Toggling state

- (IBAction)toggleEnabled:(UISwitch *)sender
{
    self.enabled = sender.on;
    
    [self updateMonitoredRegion];
}

- (IBAction)toggleNotifyOnEntry:(UISwitch *)sender
{
    self.notifyOnEntry = sender.on;
    [self updateMonitoredRegion];
}

- (IBAction)toggleNotifyOnExit:(UISwitch *)sender
{
    self.notifyOnExit = sender.on;
    [self updateMonitoredRegion];
}

- (IBAction)toggleNotifyOnDisplay:(UISwitch *)sender
{
    self.notifyOnDisplay = sender.on;
    [self updateMonitoredRegion];
}

#pragma mark - Text editing

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if(textField == self.uuidTextField)
//    {
//        [self performSegueWithIdentifier:@"selectUUID" sender:self];
//        return NO;
//    }
//    
//    return YES;
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == self.majorTextField)
    {
        self.major = [self.numberFormatter numberFromString:textField.text];
    }
    else if(textField == self.minorTextField)
    {
        self.minor = [self.numberFormatter numberFromString:textField.text];
    }
    
    self.navigationItem.rightBarButtonItem = nil;
    
    [self updateMonitoredRegion];
}

#pragma mark - Managing editing

- (IBAction)doneEditing:(id)sender
{
    [self.majorTextField resignFirstResponder];
    [self.minorTextField resignFirstResponder];
    
    [self.tableView reloadData];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if([[segue identifier] isEqualToString:@"selectUUID"])
//    {
//        APLUUIDViewController *uuidSelector = [segue destinationViewController];
//        
//        uuidSelector.uuid = self.uuid;
//    }
//}
//
//- (IBAction)unwindUUIDSelector:(UIStoryboardSegue*)sender
//{
//    APLUUIDViewController *uuidSelector = [sender sourceViewController];
//    
//    self.uuid = uuidSelector.uuid;
//    [self updateMonitoredRegion];
//}

- (void)updateMonitoredRegion
{
    // if region monitoring is enabled, update the region being monitored
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:BeaconIdentifier];
    
    if(region != nil)
    {
        [self.locationManager stopMonitoringForRegion:region];
    }
    
    if(self.enabled)
    {
        region = nil;
        if(self.uuid && self.major && self.minor)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid major:[self.major shortValue] minor:[self.minor shortValue] identifier:BeaconIdentifier];
        }
        else if(self.uuid && self.major)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid major:[self.major shortValue]  identifier:BeaconIdentifier];
        }
        else if(self.uuid)
        {
            region = [[CLBeaconRegion alloc] initWithProximityUUID:self.uuid identifier:BeaconIdentifier];
        }
        
        if(region)
        {
            region.notifyOnEntry = self.notifyOnEntry;
            region.notifyOnExit = self.notifyOnExit;
            region.notifyEntryStateOnDisplay = self.notifyOnDisplay;
            
            [self.locationManager startMonitoringForRegion:region];
        }
    }
    else
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:BeaconIdentifier];
        [self.locationManager stopMonitoringForRegion:region];
    }
}


@end
