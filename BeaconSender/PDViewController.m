//
//  PDViewController.m
//  BeaconSender
//
//  Created by nanao on 2014/04/21.
//  Copyright (c) 2014年 punchdrunker. All rights reserved.
//

#import "PDViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface PDViewController ()

@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _textView.text = @"";
    
    _proximityUUID = [[NSUUID alloc] initWithUUIDString:@"772BAE40-C984-4D8A-B4C8-2BD2F3A3E6CB"];
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self startAdvertising];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startAdvertising {
    // CLBeaconRegionを作成してアドバタイズするデータを取得
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                                           major:1
                                                                           minor:2
                                                                      identifier:@"org.punchdrunker.beacon"];
    NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:nil];
    
    // アドバタイズを開始
    [self.peripheralManager startAdvertising:beaconPeripheralData];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        [self sendLocalNotificationForMessage:[NSString stringWithFormat:@"%@", error]];
    } else {
        [self sendLocalNotificationForMessage:@"Start Advertising"];
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *message;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            message = @"PoweredOff";
            break;
        case CBPeripheralManagerStatePoweredOn:
            message = @"PoweredOn";
            [self startAdvertising];
            break;
        case CBPeripheralManagerStateResetting:
            message = @"Resetting";
            break;
        case CBPeripheralManagerStateUnauthorized:
            message = @"Unauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            message = @"Unknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            message = @"Unsupported";
            break;
            
        default:
            break;
    }
    
    [self sendLocalNotificationForMessage:[@"PeripheralManager did update state: " stringByAppendingString:message]];
}

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    NSString *string = [NSString stringWithFormat:@"%@\n%@", _textView.text, message];
    _textView.text = string;
}
@end
