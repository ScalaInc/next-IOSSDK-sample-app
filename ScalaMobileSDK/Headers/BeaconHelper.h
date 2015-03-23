//
//  BeaconHelper.h
//  ScalaMobileSDKIOS
//
//  Created by Wenyao Hu on 10/13/14.
//  Copyright (c) 2014 scala. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "DataHelper.h"

@class BeaconHelper;
@protocol BeaconHelperDelegate <NSObject>

-(void)beaconHelper:(BeaconHelper*) beaconHelper didRetrieveBeaconData:(NSArray*)beaconDataNodes;
-(void)beaconHelper:(BeaconHelper*) beaconHelper didSetCustomer:(NSDictionary*) customer forIdentifier:(NSString*) identifier;
@end

@interface BeaconHelper : NSObject <DataHelperDelegate>

@property (nonatomic, assign)id<BeaconHelperDelegate> delegate;
@property(nonatomic,retain) NSMutableSet* unregisteredBeacons;

-(id) initWithAccessToken:(NSString*) accessToken andApiSite:(NSString *)apiSite;
-(void) retrieveBeaconsInfo:(NSString *)identifierList;
-(NSMutableArray*) sortBeaconArrayUsingRssi:(NSMutableArray*) beaconArray;
-(NSArray*) getBeaconArray:(NSArray*) beacons fromDetectedBeacon:(NSDictionary*) detectedBeacons withStoredNodes:(NSDictionary*) storedNodes;
-(NSDictionary*) getClosestBeacon:(NSMutableArray*)closestBeaconArray WithType:(NSString *)beaconTypes fromBeacons:(NSArray*)beaconArray;
-(NSArray*) getCustomerArray:(NSArray*) customerBeacons fromCustomers:(NSMutableDictionary*) detectedCustomers withDesiredProximity:(NSInteger) desiredProximity;
@end
