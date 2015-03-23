//
//  BeaconTransmitter.h
//  ScalaMobileSDK
//
//  Created by Wenyao Hu on 4/10/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BeaconTransmitter : NSObject <CBPeripheralManagerDelegate, CLLocationManagerDelegate>
- (id) initWithProximity:(NSString *)proximityUUID andIdentiifer:(NSString *)identifier andMajor:(NSString*)major andMinor:(NSString*)minor;
- (void) stopTransmitting;
- (void) startTransmitting;
@end
