//
//  BeaconController.h
//  ScalaMobileSDK
//
//  Created by Wenyao Hu on 4/10/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLBeaconRegion.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class BeaconController;
@protocol BeaconControllerDelegate <NSObject>

-(void) didChangeLocationServiceAuthorizationStatus:(CLAuthorizationStatus)status;
-(void) didEnterRegion:(NSString*) proximityUuid;
-(void) didExitRegion:(NSString*) proximityUuid;
@end

@interface BeaconController : NSObject <CLLocationManagerDelegate>
@property (nonatomic, assign)id<BeaconControllerDelegate> delegate;
@property (nonatomic, retain) NSArray* _customers;

- (id) initWithLocationList:(NSSet*) locationList andSingnagePlayerList:(NSSet*) signagePlayerList andAccountUuid:(NSString*) accountUuid;
- (NSArray* ) getProximityHistoryForIdentifier:(NSString*) identifier;
- (NSArray*) getBeacons;
- (void) addNewLocation:(NSDictionary*) location;
- (void) removeLocation:(NSDictionary*) location;
- (void) addNewPlayer:(NSDictionary*) player;
- (void) removePlayer:(NSDictionary*) player;

@end
